# Commands Cheatsheet - Quick Reference

---

## 🚀 PROJECT SETUP

### Create New Flutter Project
```bash
flutter create teamsync_pro \
  --platforms=macos,windows,linux \
  --org=com.teamsync

cd teamsync_pro
```

### Setup Backend
```bash
mkdir backend && cd backend
npm init -y
npm install express socket.io cors helmet compression
npm install jsonwebtoken bcryptjs @prisma/client multer nodemailer
npm install -D typescript ts-node-dev @types/node @types/express prisma
npx tsc --init
npx prisma init
```

---

## 📦 FLUTTER COMMANDS

### Install Dependencies
```bash
flutter pub get
```

### Run App
```bash
# macOS
flutter run -d macos

# Windows
flutter run -d windows

# Linux
flutter run -d linux
```

### Build App
```bash
# macOS
flutter build macos --release

# Windows
flutter build windows --release

# Linux
flutter build linux --release
```

### Clean Build
```bash
flutter clean
flutter pub get
flutter run
```

### Generate Code (Riverpod)
```bash
dart run build_runner build --delete-conflicting-outputs
```

### Watch Mode (Auto-generate)
```bash
dart run build_runner watch --delete-conflicting-outputs
```

---

## 🔧 BACKEND COMMANDS

### Install Dependencies
```bash
npm install
```

### Run Development Server
```bash
npm run dev
```

### Build for Production
```bash
npm run build
```

### Start Production Server
```bash
npm start
```

### Run Tests
```bash
npm test
```

### Lint Code
```bash
npm run lint
```

---

## 🗄️ DATABASE COMMANDS (Prisma)

### Initialize Prisma
```bash
npx prisma init
```

### Generate Prisma Client
```bash
npx prisma generate
```

### Create Migration
```bash
npx prisma migrate dev --name init
```

### Apply Migrations
```bash
npx prisma migrate deploy
```

### Reset Database
```bash
npx prisma migrate reset
```

### Open Prisma Studio
```bash
npx prisma studio
```

### Format Schema
```bash
npx prisma format
```

---

## 🐛 DEBUGGING

### Flutter Logs
```bash
flutter logs
```

### Backend Logs
```bash
# Development (auto-restart)
npm run dev

# Production
npm start | tee logs/app.log
```

### Check Flutter Doctor
```bash
flutter doctor -v
```

### Check Node Version
```bash
node --version
npm --version
```

---

## 🧪 TESTING

### Flutter Tests
```bash
# Run all tests
flutter test

# Run specific test
flutter test test/unit/auth_test.dart

# Run with coverage
flutter test --coverage
```

### Backend Tests
```bash
# Run all tests
npm test

# Run specific test
npm test -- auth.test.ts

# Run with coverage
npm test -- --coverage
```

---

## 📱 PLATFORM-SPECIFIC

### macOS
```bash
# Enable macOS desktop
flutter config --enable-macos-desktop

# Build
flutter build macos

# Run
open build/macos/Build/Products/Release/teamsync_pro.app
```

### Windows
```bash
# Enable Windows desktop
flutter config --enable-windows-desktop

# Build
flutter build windows

# Run
start build\windows\runner\Release\teamsync_pro.exe
```

### Linux
```bash
# Enable Linux desktop
flutter config --enable-linux-desktop

# Build
flutter build linux

# Run
./build/linux/x64/release/bundle/teamsync_pro
```

---

## 🔄 GIT COMMANDS

### Initialize Repository
```bash
git init
git add .
git commit -m "Initial commit"
```

### Create Branch
```bash
git checkout -b feature/chat-system
```

### Commit Changes
```bash
git add .
git commit -m "Add chat feature"
```

### Push to Remote
```bash
git push origin main
```

---

## 🐳 DOCKER (Optional)

### Build Backend Image
```bash
cd backend
docker build -t teamsync-backend .
```

### Run Backend Container
```bash
docker run -p 3000:3000 teamsync-backend
```

### Docker Compose
```bash
docker-compose up -d
```

---

## 📊 MONITORING

### Check Running Processes
```bash
# Backend
lsof -i :3000

# Kill process
kill -9 <PID>
```

### Check Disk Space
```bash
df -h
```

### Check Memory Usage
```bash
free -h  # Linux
vm_stat  # macOS
```

---

## 🔧 TROUBLESHOOTING

### Flutter Issues
```bash
# Clean everything
flutter clean
rm -rf pubspec.lock
rm -rf .dart_tool
flutter pub get

# Upgrade Flutter
flutter upgrade

# Repair cache
flutter pub cache repair
```

### Backend Issues
```bash
# Clean node_modules
rm -rf node_modules
rm package-lock.json
npm install

# Clear npm cache
npm cache clean --force
```

### Database Issues
```bash
# Reset database
npx prisma migrate reset

# Regenerate client
npx prisma generate

# Check connection
npx prisma db pull
```

---

## 📝 USEFUL ALIASES (Add to .bashrc or .zshrc)

```bash
# Flutter
alias fr='flutter run'
alias fb='flutter build'
alias fc='flutter clean'
alias fp='flutter pub get'

# Backend
alias nd='npm run dev'
alias nb='npm run build'
alias ns='npm start'
alias nt='npm test'

# Prisma
alias pg='npx prisma generate'
alias pm='npx prisma migrate dev'
alias ps='npx prisma studio'

# Git
alias gs='git status'
alias ga='git add .'
alias gc='git commit -m'
alias gp='git push'
```

---

## 🚀 QUICK START SEQUENCE

```bash
# 1. Create project
flutter create teamsync_pro --platforms=macos,windows,linux

# 2. Setup backend
cd teamsync_pro && mkdir backend && cd backend
npm init -y && npm install express socket.io @prisma/client

# 3. Install frontend deps
cd .. && flutter pub get

# 4. Run backend
cd backend && npm run dev

# 5. Run frontend (new terminal)
cd teamsync_pro && flutter run -d macos
```

---

**Save this file for quick reference during development!**
