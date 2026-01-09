# Implementation Guide - Step by Step

**Timeline:** 3 Days MVP  
**Start Date:** January 8, 2026

---

## 🚀 SETUP INSTRUCTIONS

### Prerequisites
```bash
# Required
- Flutter SDK 3.x
- Node.js 18+
- PostgreSQL 15+
- Git

# Optional
- Docker
- Redis
```

### Step 1: Create New Flutter Project
```bash
# Create project with all platforms
flutter create teamsync_pro \
  --platforms=macos,windows,linux \
  --org=com.teamsync

cd teamsync_pro

# Enable desktop platforms
flutter config --enable-macos-desktop
flutter config --enable-windows-desktop
flutter config --enable-linux-desktop
```

### Step 2: Setup Backend
```bash
# Create backend folder
mkdir backend
cd backend

# Initialize Node.js project
npm init -y

# Install dependencies
npm install express socket.io cors helmet compression
npm install jsonwebtoken bcryptjs @prisma/client
npm install multer nodemailer winston dotenv uuid

# Install dev dependencies
npm install -D typescript ts-node-dev @types/node @types/express
npm install -D prisma @types/bcryptjs @types/jsonwebtoken

# Initialize TypeScript
npx tsc --init

# Initialize Prisma
npx prisma init
```

### Step 3: Project Structure
```bash
# Frontend structure
cd ../
mkdir -p lib/{core,features,shared}
mkdir -p lib/core/{constants,theme,network,storage,error,utils,router}
mkdir -p lib/features/{auth,workspace,chat,calls,tasks,monitoring}
mkdir -p assets/{images,icons,fonts,animations}

# Backend structure
cd backend
mkdir -p src/{config,core,modules,shared,socket}
mkdir -p src/core/{middleware,utils,errors}
mkdir -p src/modules/{auth,workspace,channel,message,call,task,monitoring}
```

---

## 📅 DAY 1: CORE COMMUNICATION

### Morning (4 hours) - Backend Foundation

#### 1. Setup Express Server (30 min)
```typescript
// src/index.ts
import express from 'express';
import cors from 'cors';
import helmet from 'helmet';
import { createServer } from 'http';
import { Server } from 'socket.io';

const app = express();
const httpServer = createServer(app);
const io = new Server(httpServer, {
  cors: { origin: '*' }
});

app.use(cors());
app.use(helmet());
app.use(express.json());

// Routes
app.get('/health', (req, res) => {
  res.json({ status: 'ok' });
});

// Socket.io
io.on('connection', (socket) => {
  console.log('Client connected:', socket.id);
  
  socket.on('disconnect', () => {
    console.log('Client disconnected:', socket.id);
  });
});

const PORT = process.env.PORT || 3000;
httpServer.listen(PORT, () => {
  console.log(`Server running on port ${PORT}`);
});
```

#### 2. Setup Prisma & Database (30 min)
```prisma
// prisma/schema.prisma
// Copy from BACKEND_ARCHITECTURE.md
```

```bash
# Run migrations
npx prisma migrate dev --name init
npx prisma generate
```

#### 3. Auth Module (2 hours)
```typescript
// src/modules/auth/presentation/controllers/auth.controller.ts
import { Request, Response } from 'express';
import { AuthService } from '../../domain/services/auth.service';

export class AuthController {
  constructor(private authService: AuthService) {}

  async register(req: Request, res: Response) {
    try {
      const user = await this.authService.register(req.body);
      res.status(201).json({ success: true, data: user });
    } catch (error) {
      res.status(400).json({ success: false, error: error.message });
    }
  }

  async login(req: Request, res: Response) {
    try {
      const result = await this.authService.login(req.body);
      res.json({ success: true, data: result });
    } catch (error) {
      res.status(401).json({ success: false, error: error.message });
    }
  }
}
```

#### 4. Workspace & Channel APIs (1 hour)
```typescript
// src/modules/workspace/presentation/controllers/workspace.controller.ts
export class WorkspaceController {
  async create(req: Request, res: Response) {
    // Create workspace
  }

  async list(req: Request, res: Response) {
    // List user's workspaces
  }
}
```

### Afternoon (4 hours) - Flutter Foundation

#### 1. Setup Riverpod (30 min)
```dart
// lib/main.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

void main() {
  runApp(
    const ProviderScope(
      child: MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'TeamSync Pro',
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF2563EB),
        ),
      ),
      home: const HomeScreen(),
    );
  }
}
```

#### 2. Theme Setup (30 min)
```dart
// lib/core/theme/app_theme.dart
import 'package:flutter/material.dart';

class AppTheme {
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: const Color(0xFF2563EB),
        brightness: Brightness.light,
      ),
      fontFamily: 'Inter',
    );
  }

  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: const Color(0xFF2563EB),
        brightness: Brightness.dark,
      ),
      fontFamily: 'Inter',
    );
  }
}
```

#### 3. API Client (1 hour)
```dart
// lib/core/network/api_client.dart
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final apiClientProvider = Provider<ApiClient>((ref) {
  return ApiClient();
});

class ApiClient {
  late final Dio _dio;

  ApiClient() {
    _dio = Dio(
      BaseOptions(
        baseUrl: 'http://localhost:3000/api/v1',
        connectTimeout: const Duration(seconds: 5),
        receiveTimeout: const Duration(seconds: 3),
      ),
    );

    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) {
          // Add auth token
          return handler.next(options);
        },
        onError: (error, handler) {
          // Handle errors
          return handler.next(error);
        },
      ),
    );
  }

  Future<Response> get(String path) => _dio.get(path);
  Future<Response> post(String path, dynamic data) => _dio.post(path, data: data);
  Future<Response> put(String path, dynamic data) => _dio.put(path, data: data);
  Future<Response> delete(String path) => _dio.delete(path);
}
```

#### 4. Auth Feature (2 hours)
```dart
// lib/features/auth/presentation/providers/auth_provider.dart
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'auth_provider.g.dart';

@riverpod
class Auth extends _$Auth {
  @override
  FutureOr<User?> build() async {
    // Check if user is logged in
    return null;
  }

  Future<void> login(String email, String password) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final response = await ref.read(apiClientProvider).post(
        '/auth/login',
        {'email': email, 'password': password},
      );
      return User.fromJson(response.data['data']);
    });
  }
}
```

### Evening (2 hours) - Real-time Messaging

#### 1. Socket.io Client (1 hour)
```dart
// lib/core/network/socket_client.dart
import 'package:socket_io_client/socket_io_client.dart' as IO;

class SocketClient {
  late IO.Socket socket;

  void connect() {
    socket = IO.io('http://localhost:3000', <String, dynamic>{
      'transports': ['websocket'],
      'autoConnect': false,
    });

    socket.connect();

    socket.on('connect', (_) {
      print('Connected to server');
    });

    socket.on('message:receive', (data) {
      // Handle incoming message
    });
  }

  void sendMessage(String channelId, String content) {
    socket.emit('message:send', {
      'channelId': channelId,
      'content': content,
    });
  }
}
```

#### 2. Message UI (1 hour)
```dart
// lib/features/chat/presentation/screens/chat_screen.dart
class ChatScreen extends ConsumerWidget {
  const ChatScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(title: const Text('# general')),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: 10,
              itemBuilder: (context, index) {
                return MessageTile();
              },
            ),
          ),
          MessageInput(),
        ],
      ),
    );
  }
}
```

---

## 📅 DAY 2: CALLS & COLLABORATION

### Morning (4 hours) - Audio Calls
- WebRTC setup
- Call UI
- Audio controls

### Afternoon (4 hours) - Screen Sharing
- Screen capture
- Screen share UI
- Controls

### Evening (2 hours) - Email Invitations
- Nodemailer setup
- Invitation flow
- Accept invitation

---

## 📅 DAY 3: POLISH & EXTENSIONS

### Morning (4 hours) - Polish
- Typing indicators
- Online status
- Reactions
- Search

### Afternoon (3 hours) - Monitoring
- Screenshot capture
- Activity tracking
- Reports

### Evening (3 hours) - Tasks
- Task board
- Create/assign tasks
- Task comments

---

## ✅ TESTING CHECKLIST

### Day 1
- [ ] User can register
- [ ] User can login
- [ ] User can create workspace
- [ ] User can create channel
- [ ] User can send message
- [ ] Messages appear in real-time

### Day 2
- [ ] User can initiate call
- [ ] User can join call
- [ ] User can share screen
- [ ] User can invite via email
- [ ] Invited user can join

### Day 3
- [ ] Typing indicators work
- [ ] Online status updates
- [ ] Screenshots captured
- [ ] Tasks can be created
- [ ] Reports generated

---

## 🚀 DEPLOYMENT

### Build Flutter App
```bash
# macOS
flutter build macos --release

# Windows
flutter build windows --release

# Linux
flutter build linux --release
```

### Deploy Backend
```bash
# Build
npm run build

# Start
npm start
```

---

**Next Steps:**
1. Follow Day 1 implementation
2. Test each feature
3. Move to Day 2
4. Complete MVP in 3 days!
