#ifndef SILENT_SCREENSHOT_H_
#define SILENT_SCREENSHOT_H_

#include <string>

// C-style interface for silent screenshot capture
extern "C" {
    __declspec(dllexport) const char* CaptureSilentScreenshot();
}

#endif  // SILENT_SCREENSHOT_H_
