const express = require('express');
const cors = require('cors');

// Simple JWT implementation for demo
const jwt = {
  sign: (payload, secret, options) => {
    return Buffer.from(JSON.stringify({...payload, exp: Date.now() + (options.expiresIn === '1h' ? 3600000 : 86400000)})).toString('base64');
  },
  verify: (token, secret) => {
    try {
      return JSON.parse(Buffer.from(token, 'base64').toString());
    } catch {
      throw new Error('Invalid token');
    }
  }
};

const app = express();
const PORT = 3000;
const JWT_SECRET = 'demo-secret-key';

// Middleware
app.use(cors());
app.use(express.json());

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
    preferences: {
      theme: 'system',
      language: 'en',
      timezone: 'UTC',
      enableNotifications: true,
      enableSounds: true,
      screenshotInterval: 300,
      enableLocationTracking: false,
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
    preferences: {
      theme: 'system',
      language: 'en',
      timezone: 'UTC',
      enableNotifications: true,
      enableSounds: true,
      screenshotInterval: 300,
      enableLocationTracking: false,
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
    preferences: {
      theme: 'system',
      language: 'en',
      timezone: 'UTC',
      enableNotifications: true,
      enableSounds: true,
      screenshotInterval: 300,
      enableLocationTracking: false,
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
    }
  }
};

// Auth endpoints
app.post('/v1/auth/login', (req, res) => {
  const { email, password } = req.body;
  
  // Simple demo authentication
  if (users[email] && password === 'Demo123!') {
    const user = users[email];
    const token = jwt.sign({ userId: user.id, email: user.email, role: user.role }, JWT_SECRET, { expiresIn: '1h' });
    
    res.json({
      success: true,
      data: {
        user,
        accessToken: token,
        refreshToken: 'refresh-' + user.id,
        expiresIn: 3600
      }
    });
  } else {
    res.status(401).json({
      success: false,
      error: 'Invalid credentials'
    });
  }
});

// Health check
app.get('/health', (req, res) => {
  res.json({ status: 'healthy', timestamp: new Date().toISOString() });
});

// Mock team data for manager
app.get('/v1/users/team', (req, res) => {
  res.json({
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
  });
});

// Mock activities
app.get('/v1/activities', (req, res) => {
  res.json({
    success: true,
    data: {
      activities: [
        {
          id: 'act-001',
          userId: 'emp-001',
          startTime: new Date().toISOString(),
          duration: 3600,
          type: 'application',
          category: 'productive',
          title: 'Visual Studio Code',
          applicationName: 'Visual Studio Code'
        }
      ],
      pagination: {
        page: 1,
        limit: 50,
        total: 1,
        totalPages: 1
      }
    }
  });
});

// Mock productivity score
app.get('/v1/analytics/productivity-score', (req, res) => {
  res.json({
    success: true,
    data: {
      id: 'score-001',
      userId: 'emp-001',
      date: new Date().toISOString().split('T')[0],
      overallScore: 0.85,
      categoryScores: {
        productive: 0.9,
        neutral: 0.7,
        distracting: 0.2
      },
      timeDistribution: {
        productive: 25200, // 7 hours in seconds
        neutral: 3600,     // 1 hour
        distracting: 1800  // 30 minutes
      }
    }
  });
});

// Start server
app.listen(PORT, () => {
  console.log(`🚀 Mock backend running on http://localhost:${PORT}`);
  console.log('📧 Demo accounts:');
  console.log('   Employee: employee@demo.com / Demo123!');
  console.log('   Manager:  manager@demo.com / Demo123!');
  console.log('   Admin:    admin@demo.com / Demo123!');