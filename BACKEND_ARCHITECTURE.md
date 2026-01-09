# Backend Architecture - Node.js Application

**Framework:** Express.js + TypeScript  
**Real-time:** Socket.io  
**Database:** PostgreSQL  
**Architecture:** Clean Architecture + Domain-Driven Design

---

## 📁 COMPLETE FOLDER STRUCTURE

```
backend/
├── src/
│   ├── index.ts                        # App entry point
│   │
│   ├── config/                         # Configuration
│   │   ├── database.ts                 # DB config
│   │   ├── socket.ts                   # Socket.io config
│   │   ├── email.ts                    # Email config
│   │   └── env.ts                      # Environment variables
│   │
│   ├── core/                           # Core functionality
│   │   ├── middleware/
│   │   │   ├── auth.middleware.ts      # JWT authentication
│   │   │   ├── error.middleware.ts     # Error handling
│   │   │   ├── validation.middleware.ts # Request validation
│   │   │   └── rate-limit.middleware.ts # Rate limiting
│   │   │
│   │   ├── utils/
│   │   │   ├── logger.ts               # Winston logger
│   │   │   ├── jwt.ts                  # JWT utilities
│   │   │   ├── encryption.ts           # Bcrypt utilities
│   │   │   └── validators.ts           # Input validators
│   │   │
│   │   └── errors/
│   │       ├── app-error.ts            # Base error class
│   │       ├── not-found.error.ts      # 404 errors
│   │       └── validation.error.ts     # Validation errors
│   │
│   ├── modules/                        # Feature modules
│   │   │
│   │   ├── auth/                       # Authentication
│   │   │   ├── domain/
│   │   │   │   ├── entities/
│   │   │   │   │   └── user.entity.ts
│   │   │   │   ├── repositories/
│   │   │   │   │   └── user.repository.ts
│   │   │   │   └── services/
│   │   │   │       └── auth.service.ts
│   │   │   │
│   │   │   ├── infrastructure/
│   │   │   │   ├── models/
│   │   │   │   │   └── user.model.ts
│   │   │   │   └── repositories/
│   │   │   │       └── user.repository.impl.ts
│   │   │   │
│   │   │   └── presentation/
│   │   │       ├── controllers/
│   │   │       │   └── auth.controller.ts
│   │   │       ├── routes/
│   │   │       │   └── auth.routes.ts
│   │   │       └── validators/
│   │   │           └── auth.validator.ts
│   │   │
│   │   ├── workspace/                  # Workspaces
│   │   │   ├── domain/
│   │   │   ├── infrastructure/
│   │   │   └── presentation/
│   │   │
│   │   ├── channel/                    # Channels
│   │   │   ├── domain/
│   │   │   ├── infrastructure/
│   │   │   └── presentation/
│   │   │
│   │   ├── message/                    # Messages
│   │   │   ├── domain/
│   │   │   ├── infrastructure/
│   │   │   └── presentation/
│   │   │
│   │   ├── call/                       # Calls
│   │   │   ├── domain/
│   │   │   ├── infrastructure/
│   │   │   └── presentation/
│   │   │
│   │   ├── task/                       # Tasks
│   │   │   ├── domain/
│   │   │   ├── infrastructure/
│   │   │   └── presentation/
│   │   │
│   │   └── monitoring/                 # Monitoring
│   │       ├── domain/
│   │       ├── infrastructure/
│   │       └── presentation/
│   │
│   ├── shared/                         # Shared code
│   │   ├── interfaces/
│   │   ├── types/
│   │   └── constants/
│   │
│   └── socket/                         # Socket.io handlers
│       ├── handlers/
│       │   ├── message.handler.ts
│       │   ├── call.handler.ts
│       │   └── presence.handler.ts
│       └── middleware/
│           └── socket-auth.middleware.ts
│
├── tests/
│   ├── unit/
│   ├── integration/
│   └── e2e/
│
├── prisma/                             # Prisma ORM
│   ├── schema.prisma
│   └── migrations/
│
├── package.json
├── tsconfig.json
└── .env.example
```

---

## 📦 DEPENDENCIES (package.json)

```json
{
  "name": "teamsync-backend",
  "version": "1.0.0",
  "description": "TeamSync Pro Backend",
  "main": "dist/index.js",
  "scripts": {
    "dev": "ts-node-dev --respawn --transpile-only src/index.ts",
    "build": "tsc",
    "start": "node dist/index.js",
    "test": "jest",
    "lint": "eslint src/**/*.ts",
    "prisma:generate": "prisma generate",
    "prisma:migrate": "prisma migrate dev"
  },
  "dependencies": {
    "express": "^4.18.2",
    "socket.io": "^4.6.1",
    "cors": "^2.8.5",
    "helmet": "^7.1.0",
    "compression": "^1.7.4",
    
    "jsonwebtoken": "^9.0.2",
    "bcryptjs": "^2.4.3",
    
    "@prisma/client": "^5.8.0",
    "redis": "^4.6.12",
    
    "multer": "^1.4.5-lts.1",
    "sharp": "^0.33.1",
    
    "nodemailer": "^6.9.8",
    
    "winston": "^3.11.0",
    "morgan": "^1.10.0",
    
    "express-rate-limit": "^7.1.5",
    "express-validator": "^7.0.1",
    
    "dotenv": "^16.3.1",
    "uuid": "^9.0.1"
  },
  "devDependencies": {
    "@types/express": "^4.17.21",
    "@types/node": "^20.10.6",
    "@types/bcryptjs": "^2.4.6",
    "@types/jsonwebtoken": "^9.0.5",
    "@types/multer": "^1.4.11",
    "@types/nodemailer": "^6.4.14",
    
    "typescript": "^5.3.3",
    "ts-node-dev": "^2.0.0",
    
    "prisma": "^5.8.0",
    
    "jest": "^29.7.0",
    "@types/jest": "^29.5.11",
    "ts-jest": "^29.1.1",
    
    "eslint": "^8.56.0",
    "@typescript-eslint/eslint-plugin": "^6.17.0",
    "@typescript-eslint/parser": "^6.17.0"
  }
}
```

---

## 🗄️ DATABASE (Prisma Schema)

```prisma
// prisma/schema.prisma

generator client {
  provider = "prisma-client-js"
}

datasource db {
  provider = "postgresql"
  url      = env("DATABASE_URL")
}

model User {
  id            String    @id @default(uuid())
  email         String    @unique
  password      String
  firstName     String
  lastName      String
  displayName   String?
  avatar        String?
  status        UserStatus @default(OFFLINE)
  statusMessage String?
  role          UserRole   @default(MEMBER)
  
  workspaces    WorkspaceMember[]
  messages      Message[]
  calls         CallParticipant[]
  
  createdAt     DateTime  @default(now())
  updatedAt     DateTime  @updatedAt
  
  @@map("users")
}

model Workspace {
  id          String    @id @default(uuid())
  name        String
  slug        String    @unique
  ownerId     String
  
  members     WorkspaceMember[]
  channels    Channel[]
  
  createdAt   DateTime  @default(now())
  updatedAt   DateTime  @updatedAt
  
  @@map("workspaces")
}

model Channel {
  id            String    @id @default(uuid())
  workspaceId   String
  name          String
  description   String?
  type          ChannelType @default(PUBLIC)
  
  workspace     Workspace @relation(fields: [workspaceId], references: [id])
  members       ChannelMember[]
  messages      Message[]
  
  createdAt     DateTime  @default(now())
  updatedAt     DateTime  @updatedAt
  
  @@map("channels")
}

model Message {
  id          String    @id @default(uuid())
  channelId   String
  senderId    String
  content     String
  type        MessageType @default(TEXT)
  
  channel     Channel   @relation(fields: [channelId], references: [id])
  sender      User      @relation(fields: [senderId], references: [id])
  
  createdAt   DateTime  @default(now())
  updatedAt   DateTime  @updatedAt
  
  @@map("messages")
}

enum UserStatus {
  ONLINE
  AWAY
  BUSY
  OFFLINE
}

enum UserRole {
  OWNER
  ADMIN
  MEMBER
  GUEST
}

enum ChannelType {
  PUBLIC
  PRIVATE
}

enum MessageType {
  TEXT
  FILE
  IMAGE
  SYSTEM
}
```

---

## 🔌 API ENDPOINTS

### Authentication
```
POST   /api/v1/auth/register
POST   /api/v1/auth/login
POST   /api/v1/auth/logout
GET    /api/v1/auth/me
POST   /api/v1/auth/refresh
```

### Workspaces
```
GET    /api/v1/workspaces
POST   /api/v1/workspaces
GET    /api/v1/workspaces/:id
PUT    /api/v1/workspaces/:id
DELETE /api/v1/workspaces/:id
```

### Channels
```
GET    /api/v1/workspaces/:wsId/channels
POST   /api/v1/workspaces/:wsId/channels
GET    /api/v1/channels/:id
PUT    /api/v1/channels/:id
DELETE /api/v1/channels/:id
```

### Messages
```
GET    /api/v1/channels/:id/messages
POST   /api/v1/channels/:id/messages
PUT    /api/v1/messages/:id
DELETE /api/v1/messages/:id
```

---

## 🔌 SOCKET.IO EVENTS

### Connection
```typescript
socket.on('connection', (socket) => {
  socket.on('user:online', handleUserOnline);
  socket.on('disconnect', handleDisconnect);
});
```

### Messaging
```typescript
socket.on('message:send', handleMessageSend);
socket.on('typing:start', handleTypingStart);
socket.on('typing:stop', handleTypingStop);
```

### Calls
```typescript
socket.on('call:initiate', handleCallInitiate);
socket.on('webrtc:offer', handleWebRTCOffer);
socket.on('webrtc:answer', handleWebRTCAnswer);
socket.on('webrtc:ice-candidate', handleICECandidate);
```

---

## 🔒 SECURITY

1. **JWT Authentication** - Secure token-based auth
2. **Password Hashing** - Bcrypt with salt
3. **Rate Limiting** - Prevent abuse
4. **CORS** - Controlled cross-origin
5. **Helmet** - Security headers
6. **Input Validation** - Sanitize all inputs

---

**Next:** Read `DATABASE_SCHEMA.md` for complete data model!
