import express from 'express';
import cors from 'cors';
import helmet from 'helmet';
import { notificationRoutes } from './routes/notification.routes';
import { webhookRoutes } from './routes/webhook.routes';
import { errorHandler } from './middleware/error.middleware';
import { requestLogger } from './middleware/logging.middleware';
import { validateApiKey } from './middleware/auth.middleware';
import { NotificationProcessor } from './services/notification.processor';
import { EmailService } from './services/email.service';
import { PushService } from './services/push.service';
import { SMSService } from './services/sms.service';

const app = express();

// Security middleware
app.use(helmet());
app.use(cors({
  origin: process.env.ALLOWED_ORIGINS?.split(',') || ['http://localhost:3000'],
  credentials: true,
}));

// Body parsing
app.use(express.json({ limit: '1mb' }));
app.use(express.urlencoded({ extended: true }));

// Logging
app.use(requestLogger);

// Health check
app.get('/health', (req, res) => {
  res.json({ 
    status: 'healthy', 
    timestamp: new Date().toISOString(),
    service: 'notification-service'
  });
});

// API routes
app.use('/api/notifications', validateApiKey, notificationRoutes);
app.use('/api/webhooks', webhookRoutes);

// Error handling
app.use(errorHandler);

// Initialize services
const emailService = new EmailService();
const pushService = new PushService();
const smsService = new SMSService();
const notificationProcessor = new NotificationProcessor({
  emailService,
  pushService,
  smsService
});

// Start notification processor
notificationProcessor.start();

const PORT = process.env.PORT || 3004;

app.listen(PORT, () => {
  console.log(`🚀 Notification service running on port ${PORT}`);
});

export default app;