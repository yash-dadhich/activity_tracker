import { Request, Response } from 'express';
import { ActivityService } from '../services/activity.service';
import { ScreenshotService } from '../services/screenshot.service';
import { ProductivityService } from '../services/productivity.service';
import { EncryptionService } from '../services/encryption.service';
import { AppError } from '../utils/errors';
import { validateActivityData } from '../utils/validation';

export class ActivityController {
  private activityService: ActivityService;
  private screenshotService: ScreenshotService;
  private productivityService: ProductivityService;
  private encryptionService: EncryptionService;

  constructor() {
    this.activityService = new ActivityService();
    this.screenshotService = new ScreenshotService();
    this.productivityService = new ProductivityService();
    this.encryptionService = new EncryptionService();
  }

  async submitActivity(req: Request, res: Response): Promise<void> {
    try {
      const userId = req.user?.id;
      const departmentId = req.user?.departmentId;

      if (!userId) {
        throw new AppError('User not authenticated', 401);
      }

      const activityData = req.body;

      // Validate activity data
      const validationResult = validateActivityData(activityData);
      if (!validationResult.isValid) {
        throw new AppError(`Invalid activity data: ${validationResult.errors.join(', ')}`, 400);
      }

      // Check user permissions
      const userPermissions = await this.activityService.getUserPermissions(userId);
      if (!this.hasRequiredPermissions(activityData, userPermissions)) {
        throw new AppError('Insufficient permissions for this activity type', 403);
      }

      // Process activity data
      const processedActivity = await this.processActivityData({
        ...activityData,
        userId,
        departmentId,
        timestamp: new Date(),
      });

      // Store activity
      const activity = await this.activityService.createActivity(processedActivity);

      // Trigger real-time processing
      await this.activityService.triggerRealTimeProcessing(activity);

      res.status(201).json({
        success: true,
        data: {
          id: activity.id,
          timestamp: activity.timestamp,
          processed: true,
        },
      });
    } catch (error) {
      this.handleError(error, res);
    }
  }

  async uploadScreenshot(req: Request, res: Response): Promise<void> {
    try {
      const userId = req.user?.id;
      const departmentId = req.user?.departmentId;

      if (!userId) {
        throw new AppError('User not authenticated', 401);
      }

      // Check screenshot permissions
      const userPermissions = await this.activityService.getUserPermissions(userId);
      if (!userPermissions.allowScreenshots) {
        throw new AppError('Screenshot capture not permitted for this user', 403);
      }

      const file = req.file;
      if (!file) {
        throw new AppError('No screenshot file provided', 400);
      }

      // Validate file type and size
      if (!file.mimetype.startsWith('image/')) {
        throw new AppError('Invalid file type. Only images are allowed', 400);
      }

      if (file.size > 10 * 1024 * 1024) { // 10MB limit
        throw new AppError('File size too large. Maximum 10MB allowed', 400);
      }

      // Process screenshot
      const screenshotData = {
        userId,
        departmentId,
        originalName: file.originalname,
        mimeType: file.mimetype,
        size: file.size,
        buffer: file.buffer,
        metadata: {
          timestamp: new Date(),
          deviceInfo: req.body.deviceInfo,
          sessionId: req.body.sessionId,
          privacyLevel: req.body.privacyLevel || 'standard',
        },
      };

      // Encrypt and store screenshot
      const screenshot = await this.screenshotService.processAndStore(screenshotData);

      res.status(201).json({
        success: true,
        data: {
          id: screenshot.id,
          timestamp: screenshot.timestamp,
          encrypted: screenshot.isEncrypted,
          thumbnailUrl: screenshot.thumbnailUrl,
        },
      });
    } catch (error) {
      this.handleError(error, res);
    }
  }

  async getActivities(req: Request, res: Response): Promise<void> {
    try {
      const userId = req.user?.id;
      const userRole = req.user?.role;
      const departmentId = req.user?.departmentId;

      if (!userId) {
        throw new AppError('User not authenticated', 401);
      }

      const {
        startDate,
        endDate,
        type,
        category,
        page = 1,
        limit = 50,
        targetUserId,
      } = req.query;

      // Determine access scope based on role
      let accessScope: 'self' | 'team' | 'department' | 'all' = 'self';
      let targetUserIds: string[] = [userId];

      if (targetUserId && userRole !== 'employee') {
        // Managers can view their team, admins can view department/all
        const hasAccess = await this.activityService.checkUserAccess(
          userId,
          userRole,
          departmentId,
          targetUserId as string
        );

        if (!hasAccess) {
          throw new AppError('Access denied to requested user data', 403);
        }

        targetUserIds = [targetUserId as string];
      } else if (userRole === 'manager') {
        // Get team members
        targetUserIds = await this.activityService.getTeamMembers(userId);
        accessScope = 'team';
      } else if (userRole === 'admin' || userRole === 'superAdmin') {
        // Get department members or all users
        if (userRole === 'superAdmin') {
          targetUserIds = await this.activityService.getAllUsers();
          accessScope = 'all';
        } else {
          targetUserIds = await this.activityService.getDepartmentMembers(departmentId);
          accessScope = 'department';
        }
      }

      // Build query parameters
      const queryParams = {
        userIds: targetUserIds,
        startDate: startDate ? new Date(startDate as string) : undefined,
        endDate: endDate ? new Date(endDate as string) : undefined,
        type: type as string,
        category: category as string,
        page: parseInt(page as string),
        limit: Math.min(parseInt(limit as string), 100), // Max 100 items per page
      };

      // Get activities
      const result = await this.activityService.getActivities(queryParams);

      // Apply privacy filters based on user permissions
      const filteredActivities = await this.applyPrivacyFilters(
        result.activities,
        userId,
        userRole,
        accessScope
      );

      res.json({
        success: true,
        data: {
          activities: filteredActivities,
          pagination: {
            page: result.page,
            limit: result.limit,
            total: result.total,
            totalPages: result.totalPages,
          },
          scope: accessScope,
        },
      });
    } catch (error) {
      this.handleError(error, res);
    }
  }

  async getProductivityScore(req: Request, res: Response): Promise<void> {
    try {
      const userId = req.user?.id;
      const userRole = req.user?.role;
      const departmentId = req.user?.departmentId;

      if (!userId) {
        throw new AppError('User not authenticated', 401);
      }

      const {
        targetUserId,
        startDate,
        endDate,
        granularity = 'daily',
      } = req.query;

      // Check access permissions
      let targetId = userId;
      if (targetUserId && targetUserId !== userId) {
        const hasAccess = await this.activityService.checkUserAccess(
          userId,
          userRole,
          departmentId,
          targetUserId as string
        );

        if (!hasAccess) {
          throw new AppError('Access denied to requested user data', 403);
        }

        targetId = targetUserId as string;
      }

      // Get productivity score
      const scoreData = await this.productivityService.getProductivityScore({
        userId: targetId,
        startDate: startDate ? new Date(startDate as string) : undefined,
        endDate: endDate ? new Date(endDate as string) : undefined,
        granularity: granularity as 'hourly' | 'daily' | 'weekly' | 'monthly',
      });

      res.json({
        success: true,
        data: scoreData,
      });
    } catch (error) {
      this.handleError(error, res);
    }
  }

  async getInsights(req: Request, res: Response): Promise<void> {
    try {
      const userId = req.user?.id;
      const userRole = req.user?.role;

      if (!userId) {
        throw new AppError('User not authenticated', 401);
      }

      const { targetUserId, period = '7d' } = req.query;

      // Check access permissions
      let targetId = userId;
      if (targetUserId && targetUserId !== userId) {
        const hasAccess = await this.activityService.checkUserAccess(
          userId,
          userRole,
          req.user?.departmentId,
          targetUserId as string
        );

        if (!hasAccess) {
          throw new AppError('Access denied to requested user data', 403);
        }

        targetId = targetUserId as string;
      }

      // Generate insights
      const insights = await this.productivityService.generateInsights({
        userId: targetId,
        period: period as string,
        includeRecommendations: true,
        includeTrends: true,
      });

      res.json({
        success: true,
        data: insights,
      });
    } catch (error) {
      this.handleError(error, res);
    }
  }

  private async processActivityData(activityData: any): Promise<any> {
    // Encrypt sensitive data
    if (activityData.windowTitle) {
      activityData.windowTitle = await this.encryptionService.encrypt(activityData.windowTitle);
    }

    if (activityData.websiteUrl) {
      activityData.websiteUrl = await this.encryptionService.encrypt(activityData.websiteUrl);
    }

    // Add productivity classification
    if (activityData.applicationName || activityData.websiteUrl) {
      const category = await this.productivityService.classifyActivity({
        applicationName: activityData.applicationName,
        windowTitle: activityData.windowTitle,
        websiteUrl: activityData.websiteUrl,
        isIdle: activityData.isIdle,
      });

      activityData.productivityCategory = category;
    }

    // Add location data if permitted and available
    if (activityData.location && activityData.allowLocationTracking) {
      activityData.location = {
        ...activityData.location,
        timestamp: new Date(),
      };
    } else {
      delete activityData.location;
    }

    return activityData;
  }

  private hasRequiredPermissions(activityData: any, permissions: any): boolean {
    if (activityData.type === 'screenshot' && !permissions.allowScreenshots) {
      return false;
    }

    if (activityData.location && !permissions.allowLocationTracking) {
      return false;
    }

    if (activityData.applicationName && !permissions.allowAppTracking) {
      return false;
    }

    if (activityData.websiteUrl && !permissions.allowWebsiteTracking) {
      return false;
    }

    if (activityData.isIdle !== undefined && !permissions.allowIdleTracking) {
      return false;
    }

    return true;
  }

  private async applyPrivacyFilters(
    activities: any[],
    requesterId: string,
    requesterRole: string,
    accessScope: string
  ): Promise<any[]> {
    return activities.map(activity => {
      // Always decrypt for the data owner
      if (activity.userId === requesterId) {
        return activity;
      }

      // Apply role-based filtering
      const filtered = { ...activity };

      // Remove or anonymize sensitive data based on role and permissions
      if (requesterRole === 'employee') {
        // Employees can only see their own data
        return null;
      }

      if (requesterRole === 'manager' && accessScope === 'team') {
        // Managers see aggregated data for team members
        delete filtered.windowTitle;
        delete filtered.websiteUrl;
        filtered.applicationName = this.anonymizeAppName(filtered.applicationName);
      }

      if (requesterRole === 'admin') {
        // Admins see more data but still respect privacy settings
        const userPrivacySettings = activity.user?.privacySettings;
        if (!userPrivacySettings?.shareDataWithManager) {
          delete filtered.windowTitle;
          delete filtered.websiteUrl;
        }
      }

      return filtered;
    }).filter(Boolean);
  }

  private anonymizeAppName(appName: string): string {
    if (!appName) return appName;

    // Keep general categories but remove specific details
    const categories = {
      'browser': ['chrome', 'firefox', 'safari', 'edge'],
      'editor': ['code', 'visual studio', 'sublime', 'atom'],
      'communication': ['slack', 'teams', 'zoom', 'discord'],
      'productivity': ['word', 'excel', 'powerpoint', 'notion'],
    };

    const lowerApp = appName.toLowerCase();
    for (const [category, apps] of Object.entries(categories)) {
      if (apps.some(app => lowerApp.includes(app))) {
        return category;
      }
    }

    return 'application';
  }

  private handleError(error: any, res: Response): void {
    if (error instanceof AppError) {
      res.status(error.statusCode).json({
        success: false,
        error: error.message,
      });
    } else {
      console.error('Activity controller error:', error);
      res.status(500).json({
        success: false,
        error: 'Internal server error',
      });
    }
  }
}