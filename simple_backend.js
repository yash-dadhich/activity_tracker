const http = require('http');
const url = require('url');

const PORT = 3001;

// Mock data
const users = {
  'employee@demo.com': {
    id: 'emp-001',
    email: 'employee@demo.com',
    firstName: 'John',
    lastName: 'Employee',
    role: 'employee',
    status: 'active',
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
  'manager@demo.com': {
    id: 'mgr-001',
    email: 'manager@demo.com',
    firstName: 'Jane',
    lastName: 'Manager',
    role: 'manager',
    status: 'active',
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
  'admin@demo.com': {
    id: 'adm-001',
    email: 'admin@demo.com',
    firstName: 'Admin',
    lastName: 'User',
    role: 'admin',
    status: 'active',
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
  }
};

function createToken(user) {
  return Buffer.from(JSON.stringify({
    userId: user.id,
    email: user.email,
    role: user.role,
    exp: Date.now() + 3600000 // 1 hour
  })).toString('base64');
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
  console.log('📧 Demo accounts:');
  console.log('   Employee: employee@demo.com / Demo123!');
  console.log('   Manager:  manager@demo.com / Demo123!');
  console.log('   Admin:    admin@demo.com / Demo123!');
  console.log('');
  console.log('✅ Backend ready for Flutter app!');
});