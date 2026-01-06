import { Request, Response } from 'express';
import { FileService } from '../services/file.service';
import { EncryptionService } from '../services/encryption.service';
import { S3Service } from '../services/s3.service';
import { VirusScanner } from '../services/virus.scanner';
import { AppError } from '../utils/errors';
import { validateFileUpload } from '../utils/validation';

export class FileController {
  private fileService: FileService;
  private encryptionService: EncryptionService;
  private s3Service: S3Service;
  private virusScanner: VirusScanner;

  constructor() {
    this.fileService = new FileService();
    this.encryptionService = new EncryptionService();
    this.s3Service = new S3Service();
    this.virusScanner = new VirusScanner();
  }

  async uploadFile(req: Request, res: Response): Promise<void> {
    try {
      const userId = req.user?.id;
      const departmentId = req.user?.departmentId;

      if (!userId) {
        throw new AppError('User not authenticated', 401);
      }

      const file = req.file;
      if (!file) {
        throw new AppError('No file provided', 400);
      }

      // Validate file
      const validationResult = validateFileUpload(file);
      if (!validationResult.isValid) {
        throw new AppError(`Invalid file: ${validationResult.errors.join(', ')}`, 400);
      }

      // Scan for viruses
      const scanResult = await this.virusScanner.scan(file.buffer);
      if (!scanResult.clean) {
        throw new AppError('File contains malicious content', 400);
      }

      // Process file metadata
      const fileMetadata = {
        originalName: file.originalname,
        mimeType: file.mimetype,
        size: file.size,
        userId,
        departmentId,
        uploadedAt: new Date(),
        category: req.body.category || 'general',
        tags: req.body.tags ? JSON.parse(req.body.tags) : [],
        privacyLevel: req.body.privacyLevel || 'standard'
      };

      // Encrypt file if required
      let fileBuffer = file.buffer;
      let encryptionKey = null;

      if (fileMetadata.privacyLevel !== 'public') {
        const encryptionResult = await this.encryptionService.encrypt(fileBuffer);
        fileBuffer = encryptionResult.encrypted;
        encryptionKey = encryptionResult.keyId;
      }

      // Upload to S3
      const s3Key = await this.s3Service.upload({
        buffer: fileBuffer,
        contentType: file.mimetype,
        metadata: fileMetadata
      });

      // Save file record
      const fileRecord = await this.fileService.createFileRecord({
        ...fileMetadata,
        s3Key,
        encryptionKey,
        isEncrypted: encryptionKey !== null
      });

      res.status(201).json({
        success: true,
        data: {
          id: fileRecord.id,
          originalName: fileRecord.originalName,
          size: fileRecord.size,
          uploadedAt: fileRecord.uploadedAt,
          downloadUrl: await this.generateDownloadUrl(fileRecord.id)
        }
      });
    } catch (error) {
      this.handleError(error, res);
    }
  }

  async downloadFile(req: Request, res: Response): Promise<void> {
    try {
      const { fileId } = req.params;
      const userId = req.user?.id;

      if (!userId) {
        throw new AppError('User not authenticated', 401);
      }

      // Get file record
      const fileRecord = await this.fileService.getFileById(fileId);
      if (!fileRecord) {
        throw new AppError('File not found', 404);
      }

      // Check access permissions
      const hasAccess = await this.fileService.checkFileAccess(userId, fileRecord);
      if (!hasAccess) {
        throw new AppError('Access denied', 403);
      }

      // Download from S3
      const fileBuffer = await this.s3Service.download(fileRecord.s3Key);

      // Decrypt if necessary
      let decryptedBuffer = fileBuffer;
      if (fileRecord.isEncrypted && fileRecord.encryptionKey) {
        decryptedBuffer = await this.encryptionService.decrypt(
          fileBuffer,
          fileRecord.encryptionKey
        );
      }

      // Log download
      await this.fileService.logFileAccess({
        fileId: fileRecord.id,
        userId,
        action: 'download',
        timestamp: new Date()
      });

      // Set response headers
      res.setHeader('Content-Type', fileRecord.mimeType);
      res.setHeader('Content-Disposition', `attachment; filename="${fileRecord.originalName}"`);
      res.setHeader('Content-Length', decryptedBuffer.length);

      res.send(decryptedBuffer);
    } catch (error) {
      this.handleError(error, res);
    }
  }

  async getFileMetadata(req: Request, res: Response): Promise<void> {
    try {
      const { fileId } = req.params;
      const userId = req.user?.id;

      if (!userId) {
        throw new AppError('User not authenticated', 401);
      }

      const fileRecord = await this.fileService.getFileById(fileId);
      if (!fileRecord) {
        throw new AppError('File not found', 404);
      }

      const hasAccess = await this.fileService.checkFileAccess(userId, fileRecord);
      if (!hasAccess) {
        throw new AppError('Access denied', 403);
      }

      res.json({
        success: true,
        data: {
          id: fileRecord.id,
          originalName: fileRecord.originalName,
          mimeType: fileRecord.mimeType,
          size: fileRecord.size,
          uploadedAt: fileRecord.uploadedAt,
          category: fileRecord.category,
          tags: fileRecord.tags,
          privacyLevel: fileRecord.privacyLevel,
          downloadUrl: await this.generateDownloadUrl(fileRecord.id)
        }
      });
    } catch (error) {
      this.handleError(error, res);
    }
  }

  async deleteFile(req: Request, res: Response): Promise<void> {
    try {
      const { fileId } = req.params;
      const userId = req.user?.id;

      if (!userId) {
        throw new AppError('User not authenticated', 401);
      }

      const fileRecord = await this.fileService.getFileById(fileId);
      if (!fileRecord) {
        throw new AppError('File not found', 404);
      }

      // Check delete permissions
      const canDelete = await this.fileService.checkDeletePermission(userId, fileRecord);
      if (!canDelete) {
        throw new AppError('Delete permission denied', 403);
      }

      // Delete from S3
      await this.s3Service.delete(fileRecord.s3Key);

      // Delete encryption key if exists
      if (fileRecord.encryptionKey) {
        await this.encryptionService.deleteKey(fileRecord.encryptionKey);
      }

      // Soft delete file record
      await this.fileService.deleteFile(fileId, userId);

      // Log deletion
      await this.fileService.logFileAccess({
        fileId: fileRecord.id,
        userId,
        action: 'delete',
        timestamp: new Date()
      });

      res.json({
        success: true,
        message: 'File deleted successfully'
      });
    } catch (error) {
      this.handleError(error, res);
    }
  }

  async listFiles(req: Request, res: Response): Promise<void> {
    try {
      const userId = req.user?.id;
      const userRole = req.user?.role;

      if (!userId) {
        throw new AppError('User not authenticated', 401);
      }

      const {
        category,
        tags,
        startDate,
        endDate,
        page = 1,
        limit = 20,
        sortBy = 'uploadedAt',
        sortOrder = 'desc'
      } = req.query;

      const filters = {
        category: category as string,
        tags: tags ? (tags as string).split(',') : undefined,
        startDate: startDate ? new Date(startDate as string) : undefined,
        endDate: endDate ? new Date(endDate as string) : undefined,
        userId: userRole === 'employee' ? userId : undefined // Employees see only their files
      };

      const result = await this.fileService.listFiles({
        filters,
        pagination: {
          page: parseInt(page as string),
          limit: Math.min(parseInt(limit as string), 100)
        },
        sort: {
          field: sortBy as string,
          order: sortOrder as 'asc' | 'desc'
        },
        requesterId: userId,
        requesterRole: userRole
      });

      res.json({
        success: true,
        data: {
          files: result.files.map(file => ({
            id: file.id,
            originalName: file.originalName,
            mimeType: file.mimeType,
            size: file.size,
            uploadedAt: file.uploadedAt,
            category: file.category,
            tags: file.tags,
            privacyLevel: file.privacyLevel
          })),
          pagination: result.pagination
        }
      });
    } catch (error) {
      this.handleError(error, res);
    }
  }

  private async generateDownloadUrl(fileId: string): Promise<string> {
    // Generate signed URL for secure download
    return `${process.env.BASE_URL}/api/files/${fileId}/download`;
  }

  private handleError(error: any, res: Response): void {
    if (error instanceof AppError) {
      res.status(error.statusCode).json({
        success: false,
        error: error.message
      });
    } else {
      console.error('File controller error:', error);
      res.status(500).json({
        success: false,
        error: 'Internal server error'
      });
    }
  }
}