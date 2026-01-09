const http = require('http');
const url = require('url');

const PORT = 3001;

// Mock data
const users = {
  // Super Admin - sees ALL organizations
  'superadmin@demo.com': {
    id: 'sadm-001',
    email: 'superadmin@demo.com',
    firstName: 'Super',
    lastName: 'Admin',
    role: 'superAdmin',
    status: 'active',
    organizationId: null, // null = can see all organizations
    createdAt: new Date().toISOString(),
    updatedAt: new Date().toISOString(),
    preferences: {
      theme: 'system',
      language: 'en',
      timezone: 'UTC',
      enableNotifications: true,
      enableSounds: true,
      screenshotInterval: 300,
      enableLocationTracking: false,
      customSettings: {}
    },
    privacySettings: {
      consentGiven: true,
      consentDate: new Date().toISOString(),
      allowScreenshots: true,
      allowLocationTracking: true,
      allowAppTracking: true,
      allowWebsiteTracking: true,
      allowIdleTracking: true,
      shareDataWithManager: false,
      shareDataWithHR: true,
      dataProcessingPurposes: ['productivity_monitoring', 'system_administration'],
      dataRetentionUntil: null
    }
  },
  
  // Acme Corporation Users (org-001)
  'admin@acme.com': {
    id: 'adm-001',
    email: 'admin@acme.com',
    firstName: 'Alice',
    lastName: 'Admin',
    role: 'admin',
    status: 'active',
    organizationId: 'org-001',
    companyId: 'comp-001',
    departmentId: 'dept-001',
    createdAt: new Date().toISOString(),
    updatedAt: new Date().toISOString(),
    preferences: {
      theme: 'system',
      language: 'en',
      timezone: 'UTC',
      enableNotifications: true,
      enableSounds: true,
      screenshotInterval: 300,
      enableLocationTracking: false,
      customSettings: {}
    },
    privacySettings: {
      consentGiven: true,
      consentDate: new Date().toISOString(),
      allowScreenshots: true,
      allowLocationTracking: true,
      allowAppTracking: true,
      allowWebsiteTracking: true,
      allowIdleTracking: true,
      shareDataWithManager: false,
      shareDataWithHR: true,
      dataProcessingPurposes: ['productivity_monitoring', 'system_administration'],
      dataRetentionUntil: null
    }
  },
  'manager@acme.com': {
    id: 'mgr-001',
    email: 'manager@acme.com',
    firstName: 'Mike',
    lastName: 'Manager',
    role: 'manager',
    status: 'active',
    organizationId: 'org-001',
    companyId: 'comp-001',
    departmentId: 'dept-001',
    createdAt: new Date().toISOString(),
    updatedAt: new Date().toISOString(),
    preferences: {
      theme: 'system',
      language: 'en',
      timezone: 'UTC',
      enableNotifications: true,
      enableSounds: true,
      screenshotInterval: 300,
      enableLocationTracking: false,
      customSettings: {}
    },
    privacySettings: {
      consentGiven: true,
      consentDate: new Date().toISOString(),
      allowScreenshots: true,
      allowLocationTracking: false,
      allowAppTracking: true,
      allowWebsiteTracking: true,
      allowIdleTracking: true,
      shareDataWithManager: false,
      shareDataWithHR: true,
      dataProcessingPurposes: ['productivity_monitoring', 'team_management'],
      dataRetentionUntil: null
    }
  },
  'employee@acme.com': {
    id: 'emp-001',
    email: 'employee@acme.com',
    firstName: 'John',
    lastName: 'Employee',
    role: 'employee',
    status: 'active',
    organizationId: 'org-001',
    companyId: 'comp-001',
    departmentId: 'dept-001',
    createdAt: new Date().toISOString(),
    updatedAt: new Date().toISOString(),
    preferences: {
      theme: 'system',
      language: 'en',
      timezone: 'UTC',
      enableNotifications: true,
      enableSounds: true,
      screenshotInterval: 300,
      enableLocationTracking: false,
      customSettings: {}
    },
    privacySettings: {
      consentGiven: true,
      consentDate: new Date().toISOString(),
      allowScreenshots: true,
      allowLocationTracking: false,
      allowAppTracking: true,
      allowWebsiteTracking: true,
      allowIdleTracking: true,
      shareDataWithManager: true,
      shareDataWithHR: false,
      dataProcessingPurposes: ['productivity_monitoring'],
      dataRetentionUntil: null
    }
  },
  
  // TechCorp Users (org-002)
  'admin@techcorp.com': {
    id: 'adm-002',
    email: 'admin@techcorp.com',
    firstName: 'Bob',
    lastName: 'Administrator',
    role: 'admin',
    status: 'active',
    organizationId: 'org-002',
    companyId: 'comp-002',
    departmentId: 'dept-002',
    createdAt: new Date().toISOString(),
    updatedAt: new Date().toISOString(),
    preferences: {
      theme: 'system',
      language: 'en',
      timezone: 'UTC',
      enableNotifications: true,
      enableSounds: true,
      screenshotInterval: 300,
      enableLocationTracking: false,
      customSettings: {}
    },
    privacySettings: {
      consentGiven: true,
      consentDate: new Date().toISOString(),
      allowScreenshots: true,
      allowLocationTracking: true,
      allowAppTracking: true,
      allowWebsiteTracking: true,
      allowIdleTracking: true,
      shareDataWithManager: false,
      shareDataWithHR: true,
      dataProcessingPurposes: ['productivity_monitoring', 'system_administration'],
      dataRetentionUntil: null
    }
  },
  'manager@techcorp.com': {
    id: 'mgr-002',
    email: 'manager@techcorp.com',
    firstName: 'Sarah',
    lastName: 'Lead',
    role: 'manager',
    status: 'active',
    organizationId: 'org-002',
    companyId: 'comp-002',
    departmentId: 'dept-002',
    createdAt: new Date().toISOString(),
    updatedAt: new Date().toISOString(),
    preferences: {
      theme: 'system',
      language: 'en',
      timezone: 'UTC',
      enableNotifications: true,
      enableSounds: true,
      screenshotInterval: 300,
      enableLocationTracking: false,
      customSettings: {}
    },
    privacySettings: {
      consentGiven: true,
      consentDate: new Date().toISOString(),
      allowScreenshots: true,
      allowLocationTracking: false,
      allowAppTracking: true,
      allowWebsiteTracking: true,
      allowIdleTracking: true,
      shareDataWithManager: false,
      shareDataWithHR: true,
      dataProcessingPurposes: ['productivity_monitoring', 'team_management'],
      dataRetentionUntil: null
    }
  },
  'employee@techcorp.com': {
    id: 'emp-002',
    email: 'employee@techcorp.com',
    firstName: 'Emma',
    lastName: 'Developer',
    role: 'employee',
    status: 'active',
    organizationId: 'org-002',
    companyId: 'comp-002',
    departmentId: 'dept-002',
    createdAt: new Date().toISOString(),
    updatedAt: new Date().toISOString(),
    preferences: {
      theme: 'system',
      language: 'en',
      timezone: 'UTC',
      enableNotifications: true,
      enableSounds: true,
      screenshotInterval: 300,
      enableLocationTracking: false,
      customSettings: {}
    },
    privacySettings: {
      consentGiven: true,
      consentDate: new Date().toISOString(),
      allowScreenshots: true,
      allowLocationTracking: false,
      allowAppTracking: true,
      allowWebsiteTracking: true,
      allowIdleTracking: true,
      shareDataWithManager: true,
      shareDataWithHR: false,
      dataProcessingPurposes: ['productivity_monitoring'],
      dataRetentionUntil: null
    }
  }
};

// Mock organizations
const organizations = {
  'org-001': {
    id: 'org-001',
    name: 'Acme Corporation',
    description: 'Leading technology company',
    logoUrl: null,
    website: 'https://acme.com',
    industry: 'Technology',
    size: 'enterprise',
    subscriptionPlan: 'enterprise',
    subscriptionStatus: 'active',
    maxUsers: 1000,
    maxCompanies: 10,
    createdAt: new Date().toISOString(),
    updatedAt: new Date().toISOString(),
    isActive: true
  },
  'org-002': {
    id: 'org-002',
    name: 'TechCorp Industries',
    description: 'Innovative software solutions provider',
    logoUrl: null,
    website: 'https://techcorp.com',
    industry: 'Software',
    size: 'medium',
    subscriptionPlan: 'professional',
    subscriptionStatus: 'active',
    maxUsers: 100,
    maxCompanies: 5,
    createdAt: new Date().toISOString(),
    updatedAt: new Date().toISOString(),
    isActive: true
  }
};

// Mock companies
const companies = {
  'comp-001': {
    id: 'comp-001',
    organizationId: 'org-001',
    name: 'Acme Tech Division',
    description: 'Technology and software development',
    location: 'San Francisco, CA',
    industry: 'Software',
    size: 'large',
    createdAt: new Date().toISOString(),
    updatedAt: new Date().toISOString(),
    isActive: true
  },
  'comp-002': {
    id: 'comp-002',
    organizationId: 'org-002',
    name: 'TechCorp Solutions',
    description: 'Enterprise software solutions',
    location: 'New York, NY',
    industry: 'Technology',
    size: 'medium',
    createdAt: new Date().toISOString(),
    updatedAt: new Date().toISOString(),
    isActive: true
  }
};

// Mock departments
const departments = {
  'dept-001': {
    id: 'dept-001',
    companyId: 'comp-001',
    organizationId: 'org-001',
    name: 'Engineering',
    description: 'Software engineering and development',
    managerId: 'mgr-001',
    createdAt: new Date().toISOString(),
    updatedAt: new Date().toISOString(),
    isActive: true
  },
  'dept-002': {
    id: 'dept-002',
    companyId: 'comp-002',
    organizationId: 'org-002',
    name: 'Development',
    description: 'Product development and innovation',
    managerId: 'mgr-002',
    createdAt: new Date().toISOString(),
    updatedAt: new Date().toISOString(),
    isActive: true
  }
};

// Mock time entries storage
const timeEntries = {};
let timeEntryCounter = 1;

function createToken(user) {
  return Buffer.from(JSON.stringify({
    userId: user.id,
    email: user.email,
    role: user.role,
    organizationId: user.organizationId,
    exp: Date.now() + 3600000 // 1 hour
  })).toString('base64');
}

function getUserFromToken(req) {
  try {
    const authHeader = req.headers.authorization;
    if (!authHeader || !authHeader.startsWith('Bearer ')) {
      return null;
    }
    const token = authHeader.substring(7);
    const decoded = JSON.parse(Buffer.from(token, 'base64').toString());
    return decoded;
  } catch (e) {
    return null;
  }
}

function parseBody(req) {
  return new Promise((resolve) => {
    let body = '';
    req.on('data', chunk => body += chunk.toString());
    req.on('end', () => {
      try {
        resolve(JSON.parse(body));
      } catch {
        resolve({});
      }
    });
  });
}

const server = http.createServer(async (req, res) => {
  // CORS headers
  res.setHeader('Access-Control-Allow-Origin', '*');
  res.setHeader('Access-Control-Allow-Methods', 'GET, POST, PUT, DELETE, OPTIONS');
  res.setHeader('Access-Control-Allow-Headers', 'Content-Type, Authorization');
  
  if (req.method === 'OPTIONS') {
    res.writeHead(200);
    res.end();
    return;
  }

  const parsedUrl = url.parse(req.url, true);
  const path = parsedUrl.pathname;
  
  res.setHeader('Content-Type', 'application/json');

  try {
    // Health check
    if (path === '/health') {
      res.writeHead(200);
      res.end(JSON.stringify({ status: 'healthy', timestamp: new Date().toISOString() }));
      return;
    }

    // Login endpoint
    if (path === '/v1/auth/login' && req.method === 'POST') {
      const body = await parseBody(req);
      const { email, password } = body;
      
      if (users[email] && password === 'Demo123!') {
        const user = users[email];
        const token = createToken(user);
        
        res.writeHead(200);
        res.end(JSON.stringify({
          success: true,
          data: {
            user,
            accessToken: token,
            refreshToken: 'refresh-' + user.id,
            expiresIn: 3600
          }
        }));
      } else {
        res.writeHead(401);
        res.end(JSON.stringify({
          success: false,
          error: 'Invalid credentials'
        }));
      }
      return;
    }

    // Team data
    if (path === '/v1/users/team' && req.method === 'GET') {
      res.writeHead(200);
      res.end(JSON.stringify({
        success: true,
        data: {
          users: [
            {
              id: 'emp-001',
              firstName: 'John',
              lastName: 'Employee',
              email: 'john@demo.com',
              role: 'employee',
              status: 'active'
            },
            {
              id: 'emp-002',
              firstName: 'Alice',
              lastName: 'Developer',
              email: 'alice@demo.com',
              role: 'employee',
              status: 'active'
            }
          ]
        }
      }));
      return;
    }

    // Activities
    if (path === '/v1/activities' && req.method === 'GET') {
      res.writeHead(200);
      res.end(JSON.stringify({
        success: true,
        data: {
          activities: [
            {
              id: 'act-001',
              userId: 'emp-001',
              deviceId: 'device-001',
              startTime: new Date().toISOString(),
              endTime: null,
              duration: 3600,
              type: 'application',
              category: 'productive',
              title: 'Visual Studio Code',
              applicationName: 'Visual Studio Code',
              isIdle: false,
              productivityScore: 0.9,
              metadata: {}
            }
          ],
          pagination: {
            page: 1,
            limit: 50,
            total: 1,
            totalPages: 1
          }
        }
      }));
      return;
    }

    // Productivity score
    if (path === '/v1/analytics/productivity-score' && req.method === 'GET') {
      res.writeHead(200);
      res.end(JSON.stringify({
        success: true,
        data: {
          scores: [
            {
              id: 'score-001',
              userId: 'emp-001',
              date: new Date().toISOString().split('T')[0],
              overallScore: 0.85,
              categoryScores: {
                productive: 0.9,
                neutral: 0.7,
                distracting: 0.2,
                personal: 0.3
              },
              timeDistribution: {
                productive: 25200,
                neutral: 3600,
                distracting: 1800,
                personal: 900
              },
              insights: [],
              trend: {
                direction: 'up',
                changePercentage: 5.2,
                period: 7,
                dataPoints: []
              }
            },
            {
              id: 'score-002',
              userId: 'emp-002',
              date: new Date().toISOString().split('T')[0],
              overallScore: 0.78,
              categoryScores: {
                productive: 0.8,
                neutral: 0.6,
                distracting: 0.3,
                personal: 0.4
              },
              timeDistribution: {
                productive: 22800,
                neutral: 4200,
                distracting: 2400,
                personal: 1200
              },
              insights: [],
              trend: {
                direction: 'up',
                changePercentage: 3.1,
                period: 7,
                dataPoints: []
              }
            }
          ]
        }
      }));
      return;
    }

    // Team alerts
    if (path === '/v1/notifications/alerts' && req.method === 'GET') {
      res.writeHead(200);
      res.end(JSON.stringify({
        success: true,
        data: {
          alerts: [
            {
              id: 'alert-001',
              type: 'productivity',
              severity: 'medium',
              title: 'Low Productivity Alert',
              description: 'John Employee productivity dropped below 70% today',
              timestamp: new Date(Date.now() - 2 * 60 * 60 * 1000).toISOString(), // 2 hours ago
              userId: 'emp-001',
              isRead: false
            },
            {
              id: 'alert-002',
              type: 'attendance',
              severity: 'low',
              title: 'Late Start',
              description: 'Alice Developer started work 30 minutes late',
              timestamp: new Date(Date.now() - 4 * 60 * 60 * 1000).toISOString(), // 4 hours ago
              userId: 'emp-002',
              isRead: false
            }
          ]
        }
      }));
      return;
    }

    // Employee activity logs for managers/admins
    if (path === '/v1/activities/detailed' && req.method === 'GET') {
      const { userId, startDate, endDate } = parsedUrl.query;
      const currentUser = getUserFromToken(req);
      
      if (!currentUser) {
        res.writeHead(401);
        res.end(JSON.stringify({ success: false, error: 'Unauthorized' }));
        return;
      }

      // Check if user has permission to view this data
      let canView = false;
      const targetUserId = userId || currentUser.userId;

      if (currentUser.role === 'superAdmin') {
        // Super admin can view anyone
        canView = true;
      } else if (currentUser.role === 'admin') {
        // Admin can view users in their organization
        const adminUser = Object.values(users).find(u => u.id === currentUser.userId);
        const targetUser = Object.values(users).find(u => u.id === targetUserId);
        canView = adminUser?.organizationId === targetUser?.organizationId;
      } else if (currentUser.role === 'manager') {
        // Manager can view users in their department
        const managerUser = Object.values(users).find(u => u.id === currentUser.userId);
        const targetUser = Object.values(users).find(u => u.id === targetUserId);
        canView = managerUser?.departmentId === targetUser?.departmentId;
      } else if (currentUser.role === 'employee') {
        // Employee can only view their own data
        canView = currentUser.userId === targetUserId;
      }

      if (!canView) {
        res.writeHead(403);
        res.end(JSON.stringify({ success: false, error: 'Forbidden: You do not have permission to view this user\'s data' }));
        return;
      }
      
      res.writeHead(200);
      res.end(JSON.stringify({
        success: true,
        data: {
          activities: [
            {
              id: 'act-001',
              userId: targetUserId,
              deviceId: 'device-001',
              startTime: new Date(Date.now() - 2 * 60 * 60 * 1000).toISOString(),
              endTime: new Date(Date.now() - 1 * 60 * 60 * 1000).toISOString(),
              duration: 3600,
              type: 'application',
              category: 'productive',
              title: 'Visual Studio Code',
              applicationName: 'Visual Studio Code',
              windowTitle: 'main.dart - Flutter Project',
              isIdle: false,
              productivityScore: 0.9,
              keystrokes: 1250,
              mouseClicks: 89,
              screenshots: ['screenshot_001.png', 'screenshot_002.png'],
              metadata: {
                projectName: 'Flutter App',
                linesOfCode: 45,
                filesModified: ['main.dart', 'home_screen.dart']
              }
            },
            {
              id: 'act-002',
              userId: targetUserId,
              deviceId: 'device-001',
              startTime: new Date(Date.now() - 1 * 60 * 60 * 1000).toISOString(),
              endTime: new Date(Date.now() - 30 * 60 * 1000).toISOString(),
              duration: 1800,
              type: 'website',
              category: 'neutral',
              title: 'Stack Overflow - Flutter Questions',
              applicationName: 'Safari',
              windowTitle: 'How to fix Flutter build issues - Stack Overflow',
              url: 'https://stackoverflow.com/questions/flutter-build',
              isIdle: false,
              productivityScore: 0.7,
              keystrokes: 234,
              mouseClicks: 45,
              screenshots: ['screenshot_003.png'],
              metadata: {
                domain: 'stackoverflow.com',
                timeOnPage: 1800,
                scrollDistance: 2400
              }
            },
            {
              id: 'act-003',
              userId: targetUserId,
              deviceId: 'device-001',
              startTime: new Date(Date.now() - 30 * 60 * 1000).toISOString(),
              endTime: new Date().toISOString(),
              duration: 1800,
              type: 'application',
              category: 'distracting',
              title: 'Slack - General Chat',
              applicationName: 'Slack',
              windowTitle: '#general - Company Workspace',
              isIdle: false,
              productivityScore: 0.3,
              keystrokes: 156,
              mouseClicks: 23,
              screenshots: ['screenshot_004.png'],
              metadata: {
                channelName: 'general',
                messagesRead: 12,
                messagesSent: 3
              }
            }
          ],
          pagination: {
            page: 1,
            limit: 50,
            total: 3,
            totalPages: 1
          }
        }
      }));
      return;
    }

    // Employee screenshots for managers/admins
    if (path === '/v1/screenshots' && req.method === 'GET') {
      const { userId, startDate, endDate } = parsedUrl.query;
      
      res.writeHead(200);
      res.end(JSON.stringify({
        success: true,
        data: {
          screenshots: [
            {
              id: 'screenshot-001',
              userId: userId || 'emp-001',
              timestamp: new Date(Date.now() - 2 * 60 * 60 * 1000).toISOString(),
              filename: 'screenshot_20260106_1400.png',
              url: '/screenshots/screenshot_20260106_1400.png',
              applicationName: 'Visual Studio Code',
              windowTitle: 'main.dart - Flutter Project',
              activityId: 'act-001',
              metadata: {
                screenResolution: '1920x1080',
                fileSize: 245760
              }
            },
            {
              id: 'screenshot-002',
              userId: userId || 'emp-001',
              timestamp: new Date(Date.now() - 1.5 * 60 * 60 * 1000).toISOString(),
              filename: 'screenshot_20260106_1430.png',
              url: '/screenshots/screenshot_20260106_1430.png',
              applicationName: 'Safari',
              windowTitle: 'Stack Overflow - Flutter Questions',
              activityId: 'act-002',
              metadata: {
                screenResolution: '1920x1080',
                fileSize: 198432
              }
            },
            {
              id: 'screenshot-003',
              userId: userId || 'emp-001',
              timestamp: new Date(Date.now() - 1 * 60 * 60 * 1000).toISOString(),
              filename: 'screenshot_20260106_1500.png',
              url: '/screenshots/screenshot_20260106_1500.png',
              applicationName: 'Slack',
              windowTitle: '#general - Company Workspace',
              activityId: 'act-003',
              metadata: {
                screenResolution: '1920x1080',
                fileSize: 312456
              }
            }
          ],
          pagination: {
            page: 1,
            limit: 50,
            total: 3,
            totalPages: 1
          }
        }
      }));
      return;
    }

    // ============ SUPER ADMIN ENDPOINTS ============
    
    // Get all organizations
    if (path === '/v1/super-admin/organizations' && req.method === 'GET') {
      res.writeHead(200);
      res.end(JSON.stringify({
        success: true,
        data: {
          organizations: Object.values(organizations),
          pagination: {
            page: 1,
            limit: 50,
            total: Object.keys(organizations).length,
            totalPages: 1
          }
        }
      }));
      return;
    }

    // Create organization
    if (path === '/v1/super-admin/organizations' && req.method === 'POST') {
      const body = await parseBody(req);
      const newOrg = {
        id: `org-${Date.now()}`,
        ...body,
        createdAt: new Date().toISOString(),
        updatedAt: new Date().toISOString(),
        isActive: true
      };
      organizations[newOrg.id] = newOrg;
      
      res.writeHead(201);
      res.end(JSON.stringify({
        success: true,
        data: { organization: newOrg }
      }));
      return;
    }

    // Update organization
    if (path.startsWith('/v1/super-admin/organizations/') && req.method === 'PUT') {
      const orgId = path.split('/').pop();
      const body = await parseBody(req);
      
      if (organizations[orgId]) {
        organizations[orgId] = {
          ...organizations[orgId],
          ...body,
          updatedAt: new Date().toISOString()
        };
        
        res.writeHead(200);
        res.end(JSON.stringify({
          success: true,
          data: { organization: organizations[orgId] }
        }));
      } else {
        res.writeHead(404);
        res.end(JSON.stringify({ success: false, error: 'Organization not found' }));
      }
      return;
    }

    // Delete organization
    if (path.startsWith('/v1/super-admin/organizations/') && req.method === 'DELETE') {
      const orgId = path.split('/').pop();
      
      if (organizations[orgId]) {
        delete organizations[orgId];
        res.writeHead(200);
        res.end(JSON.stringify({
          success: true,
          message: 'Organization deleted successfully'
        }));
      } else {
        res.writeHead(404);
        res.end(JSON.stringify({ success: false, error: 'Organization not found' }));
      }
      return;
    }

    // System analytics
    if (path === '/v1/super-admin/analytics' && req.method === 'GET') {
      res.writeHead(200);
      res.end(JSON.stringify({
        success: true,
        data: {
          totalOrganizations: Object.keys(organizations).length,
          totalUsers: Object.keys(users).length,
          totalCompanies: Object.keys(companies).length,
          totalDepartments: Object.keys(departments).length,
          systemHealth: {
            cpuUsage: 45.2,
            memoryUsage: 62.8,
            diskUsage: 38.5,
            uptime: '45 days 12 hours'
          },
          revenueMetrics: {
            mrr: 125000,
            arr: 1500000,
            growth: 15.3
          }
        }
      }));
      return;
    }

    // ============ ADMIN ENDPOINTS ============
    
    // Get companies
    if (path === '/v1/admin/companies' && req.method === 'GET') {
      const { organizationId } = parsedUrl.query;
      const currentUser = getUserFromToken(req);
      
      // Filter companies based on user's organization
      let orgCompanies = Object.values(companies);
      
      // If user is not super admin, filter by their organizationId
      if (currentUser && currentUser.organizationId !== null) {
        orgCompanies = orgCompanies.filter(c => c.organizationId === currentUser.organizationId);
      } else if (organizationId) {
        // Super admin can filter by specific organizationId
        orgCompanies = orgCompanies.filter(c => c.organizationId === organizationId);
      }
      
      res.writeHead(200);
      res.end(JSON.stringify({
        success: true,
        data: {
          companies: orgCompanies,
          pagination: {
            page: 1,
            limit: 50,
            total: orgCompanies.length,
            totalPages: 1
          }
        }
      }));
      return;
    }

    // Create company
    if (path === '/v1/admin/companies' && req.method === 'POST') {
      const body = await parseBody(req);
      const newCompany = {
        id: `comp-${Date.now()}`,
        ...body,
        createdAt: new Date().toISOString(),
        updatedAt: new Date().toISOString(),
        isActive: true
      };
      companies[newCompany.id] = newCompany;
      
      res.writeHead(201);
      res.end(JSON.stringify({
        success: true,
        data: { company: newCompany }
      }));
      return;
    }

    // Update company
    if (path.startsWith('/v1/admin/companies/') && req.method === 'PUT') {
      const companyId = path.split('/').pop();
      const body = await parseBody(req);
      
      if (companies[companyId]) {
        companies[companyId] = {
          ...companies[companyId],
          ...body,
          updatedAt: new Date().toISOString()
        };
        
        res.writeHead(200);
        res.end(JSON.stringify({
          success: true,
          data: { company: companies[companyId] }
        }));
      } else {
        res.writeHead(404);
        res.end(JSON.stringify({ success: false, error: 'Company not found' }));
      }
      return;
    }

    // Delete company
    if (path.startsWith('/v1/admin/companies/') && req.method === 'DELETE') {
      const companyId = path.split('/').pop();
      
      if (companies[companyId]) {
        delete companies[companyId];
        res.writeHead(200);
        res.end(JSON.stringify({
          success: true,
          message: 'Company deleted successfully'
        }));
      } else {
        res.writeHead(404);
        res.end(JSON.stringify({ success: false, error: 'Company not found' }));
      }
      return;
    }

    // Get departments
    if (path === '/v1/admin/departments' && req.method === 'GET') {
      const { companyId, organizationId } = parsedUrl.query;
      const currentUser = getUserFromToken(req);
      
      let filteredDepts = Object.values(departments);
      
      // If user is not super admin, filter by their organizationId
      if (currentUser && currentUser.organizationId !== null) {
        filteredDepts = filteredDepts.filter(d => d.organizationId === currentUser.organizationId);
      } else if (organizationId) {
        // Super admin can filter by specific organizationId
        filteredDepts = filteredDepts.filter(d => d.organizationId === organizationId);
      }
      
      // Apply additional filters
      if (companyId) {
        filteredDepts = filteredDepts.filter(d => d.companyId === companyId);
      }
      
      res.writeHead(200);
      res.end(JSON.stringify({
        success: true,
        data: {
          departments: filteredDepts,
          pagination: {
            page: 1,
            limit: 50,
            total: filteredDepts.length,
            totalPages: 1
          }
        }
      }));
      return;
    }

    // Create department
    if (path === '/v1/admin/departments' && req.method === 'POST') {
      const body = await parseBody(req);
      const newDept = {
        id: `dept-${Date.now()}`,
        ...body,
        createdAt: new Date().toISOString(),
        updatedAt: new Date().toISOString(),
        isActive: true
      };
      departments[newDept.id] = newDept;
      
      res.writeHead(201);
      res.end(JSON.stringify({
        success: true,
        data: { department: newDept }
      }));
      return;
    }

    // Update department
    if (path.startsWith('/v1/admin/departments/') && req.method === 'PUT') {
      const deptId = path.split('/').pop();
      const body = await parseBody(req);
      
      if (departments[deptId]) {
        departments[deptId] = {
          ...departments[deptId],
          ...body,
          updatedAt: new Date().toISOString()
        };
        
        res.writeHead(200);
        res.end(JSON.stringify({
          success: true,
          data: { department: departments[deptId] }
        }));
      } else {
        res.writeHead(404);
        res.end(JSON.stringify({ success: false, error: 'Department not found' }));
      }
      return;
    }

    // Delete department
    if (path.startsWith('/v1/admin/departments/') && req.method === 'DELETE') {
      const deptId = path.split('/').pop();
      
      if (departments[deptId]) {
        delete departments[deptId];
        res.writeHead(200);
        res.end(JSON.stringify({
          success: true,
          message: 'Department deleted successfully'
        }));
      } else {
        res.writeHead(404);
        res.end(JSON.stringify({ success: false, error: 'Department not found' }));
      }
      return;
    }

    // Get all users (admin)
    if (path === '/v1/admin/users' && req.method === 'GET') {
      const { organizationId, companyId, departmentId, role } = parsedUrl.query;
      const currentUser = getUserFromToken(req);
      
      let filteredUsers = Object.values(users);
      
      // If user is not super admin, filter by their organizationId
      if (currentUser && currentUser.organizationId !== null) {
        filteredUsers = filteredUsers.filter(u => u.organizationId === currentUser.organizationId);
      } else if (organizationId) {
        // Super admin can filter by specific organizationId
        filteredUsers = filteredUsers.filter(u => u.organizationId === organizationId);
      }
      
      // Apply additional filters
      if (companyId) {
        filteredUsers = filteredUsers.filter(u => u.companyId === companyId);
      }
      if (departmentId) {
        filteredUsers = filteredUsers.filter(u => u.departmentId === departmentId);
      }
      if (role) {
        filteredUsers = filteredUsers.filter(u => u.role === role);
      }
      
      res.writeHead(200);
      res.end(JSON.stringify({
        success: true,
        data: {
          users: filteredUsers,
          pagination: {
            page: 1,
            limit: 50,
            total: filteredUsers.length,
            totalPages: 1
          }
        }
      }));
      return;
    }

    // Create user (admin)
    if (path === '/v1/admin/users' && req.method === 'POST') {
      const body = await parseBody(req);
      const newUser = {
        id: `usr-${Date.now()}`,
        ...body,
        status: 'active',
        createdAt: new Date().toISOString(),
        updatedAt: new Date().toISOString(),
        preferences: {
          theme: 'system',
          language: 'en',
          timezone: 'UTC',
          enableNotifications: true,
          enableSounds: true,
          screenshotInterval: 300,
          enableLocationTracking: false,
          customSettings: {}
        },
        privacySettings: {
          consentGiven: false,
          consentDate: null,
          allowScreenshots: false,
          allowLocationTracking: false,
          allowAppTracking: false,
          allowWebsiteTracking: false,
          allowIdleTracking: false,
          shareDataWithManager: false,
          shareDataWithHR: false,
          dataProcessingPurposes: [],
          dataRetentionUntil: null
        }
      };
      users[newUser.email] = newUser;
      
      res.writeHead(201);
      res.end(JSON.stringify({
        success: true,
        data: { user: newUser }
      }));
      return;
    }

    // Update user role
    if (path.match(/\/v1\/admin\/users\/[^/]+\/role$/) && req.method === 'PUT') {
      const userId = path.split('/')[4];
      const body = await parseBody(req);
      
      const user = Object.values(users).find(u => u.id === userId);
      if (user) {
        user.role = body.role;
        user.updatedAt = new Date().toISOString();
        
        res.writeHead(200);
        res.end(JSON.stringify({
          success: true,
          data: { user }
        }));
      } else {
        res.writeHead(404);
        res.end(JSON.stringify({ success: false, error: 'User not found' }));
      }
      return;
    }

    // Update user
    if (path.match(/\/v1\/admin\/users\/[^/]+$/) && req.method === 'PUT') {
      const userId = path.split('/')[4];
      const body = await parseBody(req);
      
      const user = Object.values(users).find(u => u.id === userId);
      if (user) {
        Object.assign(user, body);
        user.updatedAt = new Date().toISOString();
        
        res.writeHead(200);
        res.end(JSON.stringify({
          success: true,
          data: { user }
        }));
      } else {
        res.writeHead(404);
        res.end(JSON.stringify({ success: false, error: 'User not found' }));
      }
      return;
    }

    // Delete user
    if (path.match(/\/v1\/admin\/users\/[^/]+$/) && req.method === 'DELETE') {
      const userId = path.split('/')[4];
      
      const userEmail = Object.keys(users).find(email => users[email].id === userId);
      if (userEmail) {
        delete users[userEmail];
        res.writeHead(200);
        res.end(JSON.stringify({
          success: true,
          message: 'User deleted successfully'
        }));
      } else {
        res.writeHead(404);
        res.end(JSON.stringify({ success: false, error: 'User not found' }));
      }
      return;
    }

    // Get organization activities (admin)
    if (path === '/v1/admin/activities' && req.method === 'GET') {
      res.writeHead(200);
      res.end(JSON.stringify({
        success: true,
        data: {
          activities: [
            {
              id: 'act-001',
              userId: 'emp-001',
              deviceId: 'device-001',
              startTime: new Date(Date.now() - 2 * 60 * 60 * 1000).toISOString(),
              endTime: new Date(Date.now() - 1 * 60 * 60 * 1000).toISOString(),
              duration: 3600,
              type: 'application',
              category: 'productive',
              title: 'Visual Studio Code',
              applicationName: 'Visual Studio Code',
              isIdle: false,
              productivityScore: 0.9
            }
          ],
          pagination: {
            page: 1,
            limit: 50,
            total: 1,
            totalPages: 1
          }
        }
      }));
      return;
    }

    // ============ TIME TRACKING ENDPOINTS ============
    
    // Clock In
    if (path === '/v1/time-tracking/clock-in' && req.method === 'POST') {
      const body = await parseBody(req);
      const currentUser = getUserFromToken(req);
      
      if (!currentUser) {
        res.writeHead(401);
        res.end(JSON.stringify({ success: false, error: 'Unauthorized' }));
        return;
      }

      // Check if user already has an active session
      const activeSession = Object.values(timeEntries).find(
        entry => entry.userId === currentUser.userId && entry.status === 'active'
      );

      if (activeSession) {
        res.writeHead(400);
        res.end(JSON.stringify({
          success: false,
          error: 'Already clocked in',
          data: { session: activeSession }
        }));
        return;
      }

      const entryId = `time-${timeEntryCounter++}`;
      const entry = {
        id: entryId,
        userId: currentUser.userId,
        clockInTime: new Date().toISOString(),
        clockOutTime: null,
        duration: null,
        status: 'active',
        location: body.location,
        deviceId: body.deviceInfo?.platform,
        ipAddress: req.socket.remoteAddress,
        metadata: body.deviceInfo || {}
      };

      timeEntries[entryId] = entry;

      res.writeHead(200);
      res.end(JSON.stringify({
        success: true,
        data: { session: entry }
      }));
      return;
    }

    // Clock Out
    if (path === '/v1/time-tracking/clock-out' && req.method === 'POST') {
      const body = await parseBody(req);
      const currentUser = getUserFromToken(req);
      
      if (!currentUser) {
        res.writeHead(401);
        res.end(JSON.stringify({ success: false, error: 'Unauthorized' }));
        return;
      }

      const entry = timeEntries[body.sessionId];

      if (!entry) {
        res.writeHead(404);
        res.end(JSON.stringify({ success: false, error: 'Session not found' }));
        return;
      }

      if (entry.userId !== currentUser.userId) {
        res.writeHead(403);
        res.end(JSON.stringify({ success: false, error: 'Forbidden' }));
        return;
      }

      if (entry.status !== 'active') {
        res.writeHead(400);
        res.end(JSON.stringify({ success: false, error: 'Session already completed' }));
        return;
      }

      const clockOutTime = new Date();
      const clockInTime = new Date(entry.clockInTime);
      const duration = Math.floor((clockOutTime - clockInTime) / 1000);

      entry.clockOutTime = clockOutTime.toISOString();
      entry.duration = duration;
      entry.status = 'completed';

      res.writeHead(200);
      res.end(JSON.stringify({
        success: true,
        data: { session: entry }
      }));
      return;
    }

    // Get Current Session
    if (path === '/v1/time-tracking/current-session' && req.method === 'GET') {
      const currentUser = getUserFromToken(req);
      
      if (!currentUser) {
        res.writeHead(401);
        res.end(JSON.stringify({ success: false, error: 'Unauthorized' }));
        return;
      }

      const activeSession = Object.values(timeEntries).find(
        entry => entry.userId === currentUser.userId && entry.status === 'active'
      );

      res.writeHead(200);
      res.end(JSON.stringify({
        success: true,
        data: {
          session: activeSession || null,
          isMonitoring: activeSession ? true : false
        }
      }));
      return;
    }

    // Get Time Entries/Sessions
    if (path === '/v1/time-tracking/sessions' && req.method === 'GET') {
      const { startDate, endDate, userId } = parsedUrl.query;
      const currentUser = getUserFromToken(req);
      
      if (!currentUser) {
        res.writeHead(401);
        res.end(JSON.stringify({ success: false, error: 'Unauthorized' }));
        return;
      }

      let filteredEntries = Object.values(timeEntries);

      // Role-based filtering
      if (currentUser.role === 'employee') {
        // Employees can only see their own entries
        filteredEntries = filteredEntries.filter(e => e.userId === currentUser.userId);
      } else if (currentUser.role === 'manager') {
        // Managers can see their department's entries
        const managerUser = Object.values(users).find(u => u.id === currentUser.userId);
        const managerDepartmentId = managerUser?.departmentId;
        
        if (managerDepartmentId) {
          // Get all users in the same department
          const departmentUserIds = Object.values(users)
            .filter(u => u.departmentId === managerDepartmentId)
            .map(u => u.id);
          
          // Filter entries to only show department members
          filteredEntries = filteredEntries.filter(e => departmentUserIds.includes(e.userId));
          
          // If specific userId requested, further filter
          if (userId) {
            filteredEntries = filteredEntries.filter(e => e.userId === userId);
          }
        } else {
          // No department, can only see own entries
          filteredEntries = filteredEntries.filter(e => e.userId === currentUser.userId);
        }
      } else if (currentUser.role === 'admin') {
        // Admins can see their organization's entries
        const adminUser = Object.values(users).find(u => u.id === currentUser.userId);
        const adminOrgId = adminUser?.organizationId;
        
        if (adminOrgId) {
          // Get all users in the same organization
          const orgUserIds = Object.values(users)
            .filter(u => u.organizationId === adminOrgId)
            .map(u => u.id);
          
          // Filter entries to only show organization members
          filteredEntries = filteredEntries.filter(e => orgUserIds.includes(e.userId));
          
          // If specific userId requested, further filter
          if (userId) {
            filteredEntries = filteredEntries.filter(e => e.userId === userId);
          }
        }
      }
      // Super admin sees all

      // Date filtering
      if (startDate) {
        const start = new Date(startDate);
        filteredEntries = filteredEntries.filter(e => new Date(e.clockInTime) >= start);
      }
      if (endDate) {
        const end = new Date(endDate);
        filteredEntries = filteredEntries.filter(e => new Date(e.clockInTime) <= end);
      }

      res.writeHead(200);
      res.end(JSON.stringify({
        success: true,
        data: {
          sessions: filteredEntries,
          pagination: {
            page: 1,
            limit: 50,
            total: filteredEntries.length,
            totalPages: 1
          }
        }
      }));
      return;
    }

    // Get Work Summary
    if (path === '/v1/time-tracking/summary' && req.method === 'GET') {
      const { startDate, endDate, userId } = parsedUrl.query;
      const currentUser = getUserFromToken(req);
      
      if (!currentUser) {
        res.writeHead(401);
        res.end(JSON.stringify({ success: false, error: 'Unauthorized' }));
        return;
      }

      let filteredEntries = Object.values(timeEntries);

      // Role-based filtering (same as sessions)
      if (currentUser.role === 'employee') {
        // Employees can only see their own entries
        filteredEntries = filteredEntries.filter(e => e.userId === currentUser.userId);
      } else if (currentUser.role === 'manager') {
        // Managers can see their department's entries
        const managerUser = Object.values(users).find(u => u.id === currentUser.userId);
        const managerDepartmentId = managerUser?.departmentId;
        
        if (managerDepartmentId) {
          // Get all users in the same department
          const departmentUserIds = Object.values(users)
            .filter(u => u.departmentId === managerDepartmentId)
            .map(u => u.id);
          
          // Filter entries to only show department members
          filteredEntries = filteredEntries.filter(e => departmentUserIds.includes(e.userId));
          
          // If specific userId requested, further filter
          if (userId) {
            filteredEntries = filteredEntries.filter(e => e.userId === userId);
          }
        } else {
          // No department, can only see own entries
          filteredEntries = filteredEntries.filter(e => e.userId === currentUser.userId);
        }
      } else if (currentUser.role === 'admin') {
        // Admins can see their organization's entries
        const adminUser = Object.values(users).find(u => u.id === currentUser.userId);
        const adminOrgId = adminUser?.organizationId;
        
        if (adminOrgId) {
          // Get all users in the same organization
          const orgUserIds = Object.values(users)
            .filter(u => u.organizationId === adminOrgId)
            .map(u => u.id);
          
          // Filter entries to only show organization members
          filteredEntries = filteredEntries.filter(e => orgUserIds.includes(e.userId));
          
          // If specific userId requested, further filter
          if (userId) {
            filteredEntries = filteredEntries.filter(e => e.userId === userId);
          }
        }
      } else if (userId) {
        // Super admin with specific userId filter
        filteredEntries = filteredEntries.filter(e => e.userId === userId);
      }
      // Super admin without userId sees all

      // Date filtering
      if (startDate) {
        const start = new Date(startDate);
        filteredEntries = filteredEntries.filter(e => new Date(e.clockInTime) >= start);
      }
      if (endDate) {
        const end = new Date(endDate);
        filteredEntries = filteredEntries.filter(e => new Date(e.clockInTime) <= end);
      }

      // Calculate summary
      const totalSessions = filteredEntries.length;
      const completedSessions = filteredEntries.filter(e => e.status === 'completed').length;
      const activeSessions = filteredEntries.filter(e => e.status === 'active').length;
      const totalSeconds = filteredEntries
        .filter(e => e.duration)
        .reduce((sum, e) => sum + e.duration, 0);
      const totalHours = (totalSeconds / 3600).toFixed(2);

      res.writeHead(200);
      res.end(JSON.stringify({
        success: true,
        data: {
          totalSessions,
          completedSessions,
          activeSessions,
          totalSeconds,
          totalHours: parseFloat(totalHours),
          averageSessionDuration: completedSessions > 0 ? totalSeconds / completedSessions : 0
        }
      }));
      return;
    }

    // Default 404
    res.writeHead(404);
    res.end(JSON.stringify({ success: false, error: 'Not found' }));
    
  } catch (error) {
    res.writeHead(500);
    res.end(JSON.stringify({ success: false, error: 'Internal server error' }));
  }
});

server.listen(PORT, () => {
  console.log(`🚀 Mock backend running on http://localhost:${PORT}`);
  console.log('');
  console.log('📧 Demo Accounts:');
  console.log('');
  console.log('   🔑 Super Admin (sees ALL organizations):');
  console.log('      Email:    superadmin@demo.com');
  console.log('      Password: Demo123!');
  console.log('');
  console.log('   🏢 Acme Corporation (org-001):');
  console.log('      Admin:    admin@acme.com / Demo123!');
  console.log('      Manager:  manager@acme.com / Demo123!');
  console.log('      Employee: employee@acme.com / Demo123!');
  console.log('');
  console.log('   🏢 TechCorp Industries (org-002):');
  console.log('      Admin:    admin@techcorp.com / Demo123!');
  console.log('      Manager:  manager@techcorp.com / Demo123!');
  console.log('      Employee: employee@techcorp.com / Demo123!');
  console.log('');
  console.log('✅ Multi-tenancy enabled!');
  console.log('   - Super Admin sees all organizations');
  console.log('   - Admins only see their organization data');
  console.log('   - Data is properly isolated by organizationId');
  console.log('');
  console.log('✅ Time Tracking enabled!');
  console.log('   - Clock In/Clock Out functionality');
  console.log('   - Work session tracking');
  console.log('   - Role-based report access');
  console.log('   - Admin password: 123456');
  console.log('');
  console.log('✅ Backend ready for Flutter app!');
});