import { Request, Response } from 'express';
import bcrypt from 'bcryptjs';
import jwt from 'jsonwebtoken';
import { AuthService } from '../services/auth.service';
import { UserService } from '../services/user.service';
import { AuditService } from '../services/audit.service';
import { validateEmail, validatePassword } from '../utils/validation';
import { AppError } from '../utils/errors';

export class AuthController {
  private authService: AuthService;
  private userService: UserService;
  private auditService: AuditService;

  constructor() {
    this.authService = new AuthService();
    this.userService = new UserService();
    this.auditService = new AuditService();
  }

  async login(req: Request, res: Response): Promise<void> {
    try {
      const { email, password, deviceInfo } = req.body;

      // Validate input
      if (!email || !password) {
        throw new AppError('Email and password are required', 400);
      }

      if (!validateEmail(email)) {
        throw new AppError('Invalid email format', 400);
      }

      // Find user
      const user = await this.userService.findByEmail(email);
      if (!user) {
        await this.auditService.logFailedLogin(email, req.ip, 'User not found');
        throw new AppError('Invalid credentials', 401);
      }

      // Check if user is active
      if (user.status !== 'active') {
        await this.auditService.logFailedLogin(email, req.ip, 'User inactive');
        throw new AppError('Account is not active', 401);
      }

      // Verify password
      const isValidPassword = await bcrypt.compare(password, user.passwordHash);
      if (!isValidPassword) {
        await this.auditService.logFailedLogin(email, req.ip, 'Invalid password');
        throw new AppError('Invalid credentials', 401);
      }

      // Check for account lockout
      const isLocked = await this.authService.isAccountLocked(user.id);
      if (isLocked) {
        throw new AppError('Account is temporarily locked due to multiple failed attempts', 423);
      }

      // Generate tokens
      const accessToken = this.generateAccessToken(user);
      const refreshToken = await this.authService.generateRefreshToken(user.id, deviceInfo);

      // Update last login
      await this.userService.updateLastLogin(user.id);

      // Log successful login
      await this.auditService.logSuccessfulLogin(user.id, req.ip, deviceInfo);

      // Return user data (excluding sensitive information)
      const userData = {
        id: user.id,
        email: user.email,
        firstName: user.firstName,
        lastName: user.lastName,
        role: user.role,
        departmentId: user.departmentId,
        preferences: user.preferences,
        privacySettings: user.privacySettings,
      };

      res.json({
        success: true,
        data: {
          user: userData,
          accessToken,
          refreshToken,
          expiresIn: 3600, // 1 hour
        },
      });
    } catch (error) {
      if (error instanceof AppError) {
        res.status(error.statusCode).json({
          success: false,
          error: error.message,
        });
      } else {
        console.error('Login error:', error);
        res.status(500).json({
          success: false,
          error: 'Internal server error',
        });
      }
    }
  }

  async refreshToken(req: Request, res: Response): Promise<void> {
    try {
      const { refreshToken } = req.body;

      if (!refreshToken) {
        throw new AppError('Refresh token is required', 400);
      }

      // Validate refresh token
      const tokenData = await this.authService.validateRefreshToken(refreshToken);
      if (!tokenData) {
        throw new AppError('Invalid refresh token', 401);
      }

      // Get user
      const user = await this.userService.findById(tokenData.userId);
      if (!user || user.status !== 'active') {
        throw new AppError('User not found or inactive', 401);
      }

      // Generate new access token
      const newAccessToken = this.generateAccessToken(user);

      res.json({
        success: true,
        data: {
          accessToken: newAccessToken,
          expiresIn: 3600,
        },
      });
    } catch (error) {
      if (error instanceof AppError) {
        res.status(error.statusCode).json({
          success: false,
          error: error.message,
        });
      } else {
        console.error('Refresh token error:', error);
        res.status(500).json({
          success: false,
          error: 'Internal server error',
        });
      }
    }
  }

  async logout(req: Request, res: Response): Promise<void> {
    try {
      const { refreshToken } = req.body;
      const userId = req.user?.id;

      if (refreshToken) {
        await this.authService.revokeRefreshToken(refreshToken);
      }

      if (userId) {
        await this.auditService.logLogout(userId, req.ip);
      }

      res.json({
        success: true,
        message: 'Logged out successfully',
      });
    } catch (error) {
      console.error('Logout error:', error);
      res.status(500).json({
        success: false,
        error: 'Internal server error',
      });
    }
  }

  async register(req: Request, res: Response): Promise<void> {
    try {
      const {
        email,
        password,
        firstName,
        lastName,
        departmentId,
        role = 'employee',
      } = req.body;

      // Validate input
      if (!email || !password || !firstName || !lastName) {
        throw new AppError('All required fields must be provided', 400);
      }

      if (!validateEmail(email)) {
        throw new AppError('Invalid email format', 400);
      }

      if (!validatePassword(password)) {
        throw new AppError(
          'Password must be at least 8 characters long and contain uppercase, lowercase, number, and special character',
          400
        );
      }

      // Check if user already exists
      const existingUser = await this.userService.findByEmail(email);
      if (existingUser) {
        throw new AppError('User with this email already exists', 409);
      }

      // Hash password
      const passwordHash = await bcrypt.hash(password, 12);

      // Create user
      const userData = {
        email,
        passwordHash,
        firstName,
        lastName,
        role,
        departmentId,
        status: 'pending',
        preferences: {
          theme: 'system',
          language: 'en',
          timezone: 'UTC',
          enableNotifications: true,
          enableSounds: true,
          screenshotInterval: 300, // 5 minutes
          enableLocationTracking: false,
        },
        privacySettings: {
          consentGiven: false,
          allowScreenshots: false,
          allowLocationTracking: false,
          allowAppTracking: false,
          allowWebsiteTracking: false,
          allowIdleTracking: false,
          shareDataWithManager: false,
          shareDataWithHR: false,
          dataProcessingPurposes: [],
        },
      };

      const user = await this.userService.create(userData);

      // Log registration
      await this.auditService.logUserRegistration(user.id, req.ip);

      res.status(201).json({
        success: true,
        data: {
          id: user.id,
          email: user.email,
          firstName: user.firstName,
          lastName: user.lastName,
          status: user.status,
        },
        message: 'User registered successfully. Account pending approval.',
      });
    } catch (error) {
      if (error instanceof AppError) {
        res.status(error.statusCode).json({
          success: false,
          error: error.message,
        });
      } else {
        console.error('Registration error:', error);
        res.status(500).json({
          success: false,
          error: 'Internal server error',
        });
      }
    }
  }

  async changePassword(req: Request, res: Response): Promise<void> {
    try {
      const { currentPassword, newPassword } = req.body;
      const userId = req.user?.id;

      if (!userId) {
        throw new AppError('User not authenticated', 401);
      }

      if (!currentPassword || !newPassword) {
        throw new AppError('Current password and new password are required', 400);
      }

      if (!validatePassword(newPassword)) {
        throw new AppError(
          'New password must be at least 8 characters long and contain uppercase, lowercase, number, and special character',
          400
        );
      }

      // Get user
      const user = await this.userService.findById(userId);
      if (!user) {
        throw new AppError('User not found', 404);
      }

      // Verify current password
      const isValidPassword = await bcrypt.compare(currentPassword, user.passwordHash);
      if (!isValidPassword) {
        throw new AppError('Current password is incorrect', 400);
      }

      // Hash new password
      const newPasswordHash = await bcrypt.hash(newPassword, 12);

      // Update password
      await this.userService.updatePassword(userId, newPasswordHash);

      // Revoke all refresh tokens to force re-login
      await this.authService.revokeAllRefreshTokens(userId);

      // Log password change
      await this.auditService.logPasswordChange(userId, req.ip);

      res.json({
        success: true,
        message: 'Password changed successfully',
      });
    } catch (error) {
      if (error instanceof AppError) {
        res.status(error.statusCode).json({
          success: false,
          error: error.message,
        });
      } else {
        console.error('Change password error:', error);
        res.status(500).json({
          success: false,
          error: 'Internal server error',
        });
      }
    }
  }

  private generateAccessToken(user: any): string {
    const payload = {
      id: user.id,
      email: user.email,
      role: user.role,
      departmentId: user.departmentId,
    };

    return jwt.sign(payload, process.env.JWT_SECRET!, {
      expiresIn: '1h',
      issuer: 'enterprise-productivity-monitor',
      audience: 'client-app',
    });
  }
}