// Silent Screenshot Implementation for Windows
// Uses Desktop Duplication API for completely invisible screen capture
// No flashing, no blinking, no visual feedback

#include "silent_screenshot.h"
#include <d3d11.h>
#include <dxgi1_2.h>
#include <wincodec.h>
#include <wrl/client.h>
#include <sstream>
#include <iomanip>
#include <chrono>

#pragma comment(lib, "d3d11.lib")
#pragma comment(lib, "dxgi.lib")
#pragma comment(lib, "windowscodecs.lib")

using Microsoft::WRL::ComPtr;

class SilentScreenshot {
private:
    ComPtr<ID3D11Device> d3d_device_;
    ComPtr<ID3D11DeviceContext> d3d_context_;
    ComPtr<IDXGIOutputDuplication> duplication_;
    bool initialized_ = false;

public:
    bool Initialize() {
        if (initialized_) return true;

        // Create D3D11 device
        D3D_FEATURE_LEVEL feature_level;
        HRESULT hr = D3D11CreateDevice(
            nullptr,
            D3D_DRIVER_TYPE_HARDWARE,
            nullptr,
            0,
            nullptr,
            0,
            D3D11_SDK_VERSION,
            &d3d_device_,
            &feature_level,
            &d3d_context_
        );

        if (FAILED(hr)) return false;

        // Get DXGI device
        ComPtr<IDXGIDevice> dxgi_device;
        hr = d3d_device_.As(&dxgi_device);
        if (FAILED(hr)) return false;

        // Get DXGI adapter
        ComPtr<IDXGIAdapter> dxgi_adapter;
        hr = dxgi_device->GetAdapter(&dxgi_adapter);
        if (FAILED(hr)) return false;

        // Get output (monitor)
        ComPtr<IDXGIOutput> dxgi_output;
        hr = dxgi_adapter->EnumOutputs(0, &dxgi_output);
        if (FAILED(hr)) return false;

        // Get output1 interface
        ComPtr<IDXGIOutput1> dxgi_output1;
        hr = dxgi_output.As(&dxgi_output1);
        if (FAILED(hr)) return false;

        // Create desktop duplication
        hr = dxgi_output1->DuplicateOutput(d3d_device_.Get(), &duplication_);
        if (FAILED(hr)) return false;

        initialized_ = true;
        return true;
    }

    std::string CaptureScreen() {
        if (!initialized_ && !Initialize()) {
            return "";
        }

        // Acquire next frame
        ComPtr<IDXGIResource> desktop_resource;
        DXGI_OUTDUPL_FRAME_INFO frame_info;
        
        HRESULT hr = duplication_->AcquireNextFrame(500, &frame_info, &desktop_resource);
        
        if (hr == DXGI_ERROR_WAIT_TIMEOUT) {
            // No new frame, try to get current desktop
            return CaptureCurrentDesktop();
        }
        
        if (FAILED(hr)) {
            // Reset duplication on error
            duplication_.Reset();
            initialized_ = false;
            return "";
        }

        // Get texture from resource
        ComPtr<ID3D11Texture2D> desktop_texture;
        hr = desktop_resource.As(&desktop_texture);
        
        if (FAILED(hr)) {
            duplication_->ReleaseFrame();
            return "";
        }

        // Get texture description
        D3D11_TEXTURE2D_DESC desc;
        desktop_texture->GetDesc(&desc);

        // Create staging texture for CPU access
        D3D11_TEXTURE2D_DESC staging_desc = desc;
        staging_desc.Usage = D3D11_USAGE_STAGING;
        staging_desc.BindFlags = 0;
        staging_desc.CPUAccessFlags = D3D11_CPU_ACCESS_READ;
        staging_desc.MiscFlags = 0;

        ComPtr<ID3D11Texture2D> staging_texture;
        hr = d3d_device_->CreateTexture2D(&staging_desc, nullptr, &staging_texture);
        
        if (FAILED(hr)) {
            duplication_->ReleaseFrame();
            return "";
        }

        // Copy to staging texture
        d3d_context_->CopyResource(staging_texture.Get(), desktop_texture.Get());

        // Map staging texture to get pixel data
        D3D11_MAPPED_SUBRESOURCE mapped_resource;
        hr = d3d_context_->Map(staging_texture.Get(), 0, D3D11_MAP_READ, 0, &mapped_resource);
        
        if (FAILED(hr)) {
            duplication_->ReleaseFrame();
            return "";
        }

        // Save to file
        std::string filepath = SaveToFile(
            (BYTE*)mapped_resource.pData,
            desc.Width,
            desc.Height,
            mapped_resource.RowPitch
        );

        // Cleanup
        d3d_context_->Unmap(staging_texture.Get(), 0);
        duplication_->ReleaseFrame();

        return filepath;
    }

private:
    std::string CaptureCurrentDesktop() {
        // Fallback to GDI capture if duplication fails
        HDC hScreenDC = GetDC(NULL);
        HDC hMemoryDC = CreateCompatibleDC(hScreenDC);

        int width = GetSystemMetrics(SM_CXSCREEN);
        int height = GetSystemMetrics(SM_CYSCREEN);

        HBITMAP hBitmap = CreateCompatibleBitmap(hScreenDC, width, height);
        HBITMAP hOldBitmap = (HBITMAP)SelectObject(hMemoryDC, hBitmap);

        // Use CAPTUREBLT for silent capture
        BitBlt(hMemoryDC, 0, 0, width, height, hScreenDC, 0, 0, SRCCOPY | CAPTUREBLT);
        
        hBitmap = (HBITMAP)SelectObject(hMemoryDC, hOldBitmap);

        // Get bitmap data
        BITMAP bmp;
        GetObject(hBitmap, sizeof(BITMAP), &bmp);

        BITMAPINFOHEADER bi;
        bi.biSize = sizeof(BITMAPINFOHEADER);
        bi.biWidth = bmp.bmWidth;
        bi.biHeight = -bmp.bmHeight; // Top-down
        bi.biPlanes = 1;
        bi.biBitCount = 32;
        bi.biCompression = BI_RGB;
        bi.biSizeImage = 0;
        bi.biXPelsPerMeter = 0;
        bi.biYPelsPerMeter = 0;
        bi.biClrUsed = 0;
        bi.biClrImportant = 0;

        DWORD dwBmpSize = ((bmp.bmWidth * bi.biBitCount + 31) / 32) * 4 * bmp.bmHeight;
        BYTE* lpbitmap = new BYTE[dwBmpSize];

        GetDIBits(hScreenDC, hBitmap, 0, (UINT)bmp.bmHeight, lpbitmap, (BITMAPINFO*)&bi, DIB_RGB_COLORS);

        std::string filepath = SaveToFile(lpbitmap, bmp.bmWidth, bmp.bmHeight, bmp.bmWidth * 4);

        delete[] lpbitmap;
        DeleteDC(hMemoryDC);
        ReleaseDC(NULL, hScreenDC);
        DeleteObject(hBitmap);

        return filepath;
    }

    std::string SaveToFile(BYTE* data, UINT width, UINT height, UINT pitch) {
        // Generate filename with timestamp
        auto now = std::chrono::system_clock::now();
        auto time = std::chrono::system_clock::to_time_t(now);
        
        struct tm timeinfo;
        localtime_s(&timeinfo, &time);
        
        std::stringstream ss;
        ss << "screenshot_" << std::put_time(&timeinfo, "%Y%m%d_%H%M%S") << ".png";
        
        std::string filename = ss.str();
        std::wstring wfilename(filename.begin(), filename.end());

        // Initialize COM
        CoInitialize(nullptr);

        // Create WIC factory
        ComPtr<IWICImagingFactory> wic_factory;
        HRESULT hr = CoCreateInstance(
            CLSID_WICImagingFactory,
            nullptr,
            CLSCTX_INPROC_SERVER,
            IID_PPV_ARGS(&wic_factory)
        );

        if (FAILED(hr)) {
            CoUninitialize();
            return "";
        }

        // Create stream
        ComPtr<IWICStream> stream;
        hr = wic_factory->CreateStream(&stream);
        if (FAILED(hr)) {
            CoUninitialize();
            return "";
        }

        hr = stream->InitializeFromFilename(wfilename.c_str(), GENERIC_WRITE);
        if (FAILED(hr)) {
            CoUninitialize();
            return "";
        }

        // Create PNG encoder
        ComPtr<IWICBitmapEncoder> encoder;
        hr = wic_factory->CreateEncoder(GUID_ContainerFormatPng, nullptr, &encoder);
        if (FAILED(hr)) {
            CoUninitialize();
            return "";
        }

        hr = encoder->Initialize(stream.Get(), WICBitmapEncoderNoCache);
        if (FAILED(hr)) {
            CoUninitialize();
            return "";
        }

        // Create frame
        ComPtr<IWICBitmapFrameEncode> frame;
        hr = encoder->CreateNewFrame(&frame, nullptr);
        if (FAILED(hr)) {
            CoUninitialize();
            return "";
        }

        hr = frame->Initialize(nullptr);
        if (FAILED(hr)) {
            CoUninitialize();
            return "";
        }

        hr = frame->SetSize(width, height);
        if (FAILED(hr)) {
            CoUninitialize();
            return "";
        }

        WICPixelFormatGUID format = GUID_WICPixelFormat32bppBGRA;
        hr = frame->SetPixelFormat(&format);
        if (FAILED(hr)) {
            CoUninitialize();
            return "";
        }

        // Write pixels
        hr = frame->WritePixels(height, pitch, pitch * height, data);
        if (FAILED(hr)) {
            CoUninitialize();
            return "";
        }

        hr = frame->Commit();
        if (FAILED(hr)) {
            CoUninitialize();
            return "";
        }

        hr = encoder->Commit();
        if (FAILED(hr)) {
            CoUninitialize();
            return "";
        }

        CoUninitialize();
        return filename;
    }
};

// Global instance
static SilentScreenshot g_screenshot;

// C-style interface for use in monitoring_plugin.cpp
extern "C" {
    __declspec(dllexport) const char* CaptureSilentScreenshot() {
        static std::string result;
        result = g_screenshot.CaptureScreen();
        return result.c_str();
    }
}
