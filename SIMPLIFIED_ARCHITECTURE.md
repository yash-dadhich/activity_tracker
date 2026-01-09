# Simplified System Architecture

## 🎯 What You're Building

A **complete employee monitoring and collaboration platform** with 4 main modules:

1. **Chat** - Team communication
2. **Activity Monitoring** - Track employee work
3. **Task Management** - Organize projects and tasks
4. **Audio/Video Calls** - Team collaboration

---

## 🏗️ System Architecture (Simple View)

```
┌─────────────────────────────────────────────────────────┐
│                    FLUTTER APP                           │
│                                                          │
│  ┌──────────────────────────────────────────────────┐  │
│  │           ROLE-BASED DASHBOARD                    │  │
│  │  • Super Admin: See everything                    │  │
│  │  • Admin: See organization                        │  │
│  │  • Manager: See department                        │  │
│  │  │  Employee: See own data                        │  │
│  └──────────────────────────────────────────────────┘  │
│                                                          │
│  ┌─────────┬─────────┬─────────┬─────────┐            │
│  │  Chat   │Activity │  Tasks  │  Calls  │            │
│  │  Screen │ Screen  │ Screen  │ Screen  │            │
│  └─────────┴─────────┴─────────┴─────────┘            │
│                                                          │
│  ┌──────────────────────────────────────────────────┐  │
│  │           NATIVE MONITORING SERVICES              │  │
│  │  • Screenshot every 30s                           │  │
│  │  • Browser history tracking                       │  │
│  │  • File access tracking                           │  │
│  │  • App usage tracking                             │  │
│  │  • Meeting detection (Zoom, Teams, etc)           │  │
│  └──────────────────────────────────────────────────┘  │
└─────────────────────────────────────────────────────────┘
                    ↕                    ↕
              HTTP/REST            WebSocket
                    ↕                    ↕
┌─────────────────────────────────────────────────────────┐
│              NODE.JS BACKEND (simple_backend.js)         │
│                                                          │
│  ┌──────────────────────────────────────────────────┐  │
│  │                  REST APIs                        │  │
│  │  • /auth/login                                    │  │
│  │  • /activities/* (screenshots, websites, files)   │  │
│  │  • /tasks/* (projects, sprints, tasks)            │  │
│  │  • /chat/* (messages, conversations)              │  │
│  │  • /calls/* (initiate, end, history)              │  │
│  └──────────────────────────────────────────────────┘  │
│                                                          │
│  ┌──────────────────────────────────────────────────┐  │
│  │              SOCKET.IO (Real-time)                │  │
│  │  • Chat messages                                  │  │
│  │  • Online status                                  │  │
│  │  • Typing indicators                              │  │
│  │  • Call signaling (WebRTC)                        │  │
│  │  • Activity updates                               │  │
│  └──────────────────────────────────────────────────┘  │
│                                                          │
│  ┌──────────────────────────────────────────────────┐  │
│  │         ROLE-BASED ACCESS CONTROL                 │  │
│  │  • Check user role on every request               │  │
│  │  • Filter data by organizationId/departmentId     │  │
│  └──────────────────────────────────────────────────┘  │
└─────────────────────────────────────────────────────────┘
                            ↕
┌─────────────────────────────────────────────────────────┐
│              IN-MEMORY DATA STORE                        │
│  • users, organizations, companies, departments          │
│  • activities (screenshots, websites, files, apps)       │
│  • projects, sprints, tasks, comments                    │
│  • conversations, messages                               │
│  • calls, call_history                                   │
└─────────────────────────────────────────────────────────┘
```

---

## 📊 Data Flow Examples

### Example 1: Employee Takes Screenshot
```
1. Flutter App (Native Plugin)
   ↓ Captures screenshot every 30s
   
2. Upload to Backend
   POST /v1/activities/screenshot
   Body: { userId, timestamp, imageBase64 }
   
3. Backend Stores
   screenshots.push({ id, userId, timestamp, data })
   
4. Manager Views Activity
   GET /v1/activities/screenshots?userId=emp-001
   Backend filters by department
   Returns screenshots for that employee
```

### Example 2: Send Chat Message
```
1. Employee types message
   ↓
   
2. Send via WebSocket
   socket.emit('send_message', {
     conversationId, senderId, content
   })
   
3. Backend receives & stores
   messages.push({ id, conversationId, senderId, content, timestamp })
   
4. Backend broadcasts to participants
   socket.to(conversationId).emit('new_message', message)
   
5. Other users receive instantly
   UI updates with new message
```

### Example 3: Create Task
```
1. Manager creates task
   ↓
   
2. POST /v1/tasks
   Body: { sprintId, title, assignedTo, dueDate }
   
3. Backend validates
   - Check if manager has access to sprint
   - Check if assignedTo is in manager's department
   
4. Backend stores
   tasks.push({ id, sprintId, title, assignedTo, status: 'todo' })
   
5. Backend notifies assignee
   socket.to(assignedTo).emit('task_assigned', task)
   
6. Employee sees notification
   "New task assigned: Build login screen"
```

---

## 🔐 Role-Based Access Control

### Data Visibility Matrix

| Role | Organizations | Companies | Departments | Users | Activities | Tasks |
|------|--------------|-----------|-------------|-------|------------|-------|
| **Super Admin** | All | All | All | All | All | All |
| **Admin** | Own | Own org | Own org | Own org | Own org | Own org |
| **Manager** | None | None | Own dept | Own dept | Own dept | Own dept |
| **Employee** | None | None | None | Self | Self | Assigned |

### Implementation in Backend
```javascript
function filterByRole(user, data) {
  if (user.role === 'superAdmin') {
    return data; // See everything
  }
  
  if (user.role === 'admin') {
    return data.filter(item => 
      item.organizationId === user.organizationId
    );
  }
  
  if (user.role === 'manager') {
    return data.filter(item => 
      item.departmentId === user.departmentId
    );
  }
  
  if (user.role === 'employee') {
    return data.filter(item => 
      item.userId === user.id
    );
  }
}
```

---

## 📱 Screen Structure

### Main Navigation (All Roles)
```
┌─────────────────────────────────────────────────────┐
│  [Logo]  Dashboard  Chat  Activity  Tasks  Calls    │
└─────────────────────────────────────────────────────┘
```

### Dashboard (Role-specific content)
```
EMPLOYEE VIEW:
┌─────────────────────────────────────────────────────┐
│  My Activity Today                                   │
│  • Active: 6h 30m  • Screenshots: 39  • Tasks: 5    │
├─────────────────────────────────────────────────────┤
│  My Tasks (5)                                        │
│  • Build login screen [In Progress]                 │
│  • Fix bug #123 [To Do]                             │
├─────────────────────────────────────────────────────┤
│  Recent Chats                                        │
│  • John: "Can you review my PR?"                    │
└─────────────────────────────────────────────────────┘

MANAGER VIEW:
┌─────────────────────────────────────────────────────┐
│  Team Activity (Engineering Dept)                    │
│  • 5 employees  • Avg active: 7h 15m                │
├─────────────────────────────────────────────────────┤
│  Sprint Progress (Sprint 3)                          │
│  • 12 tasks  • 5 done  • 4 in progress  • 3 todo   │
├─────────────────────────────────────────────────────┤
│  Team Members                                        │
│  • John (Active) - 7h 30m today                     │
│  • Jane (Active) - 6h 45m today                     │
└─────────────────────────────────────────────────────┘

ADMIN VIEW:
┌─────────────────────────────────────────────────────┐
│  Company Overview (Acme Corp)                        │
│  • 3 departments  • 25 employees  • 8 projects      │
├─────────────────────────────────────────────────────┤
│  Activity Summary                                    │
│  • Total active time: 180h  • Screenshots: 1,250    │
├─────────────────────────────────────────────────────┤
│  Projects Status                                     │
│  • Project A: 75% complete                          │
│  • Project B: 40% complete                          │
└─────────────────────────────────────────────────────┘
```

---

## 🔄 Real-time Features (WebSocket)

### Events to Implement

#### Chat Events
```javascript
// Client → Server
socket.emit('send_message', { conversationId, content })
socket.emit('typing', { conversationId, userId })
socket.emit('mark_read', { messageId })

// Server → Client
socket.on('new_message', (message) => { /* Update UI */ })
socket.on('user_typing', (userId) => { /* Show indicator */ })
socket.on('message_read', (messageId) => { /* Show checkmark */ })
```

#### Activity Events
```javascript
// Client → Server (every 30s)
socket.emit('activity_update', { 
  userId, activeTime, idleTime, currentApp 
})

// Server → Manager (real-time)
socket.on('employee_activity', (data) => { 
  /* Update dashboard */ 
})
```

#### Call Events
```javascript
// Initiator → Server
socket.emit('call_initiate', { callerId, calleeId, type })

// Server → Callee
socket.on('incoming_call', (caller) => { 
  /* Show call notification */ 
})

// WebRTC signaling
socket.emit('webrtc_offer', { offer, to })
socket.emit('webrtc_answer', { answer, to })
socket.emit('webrtc_ice_candidate', { candidate, to })
```

---

## 📦 File Structure (Simplified)

```
poc_activity_tracker/
├── lib/
│   ├── main.dart
│   ├── core/
│   │   ├── auth/
│   │   ├── network/
│   │   └── constants/
│   ├── domain/
│   │   └── entities/
│   │       ├── user.dart
│   │       ├── activity.dart ← NEW
│   │       ├── task.dart ← NEW
│   │       ├── message.dart ← NEW
│   │       └── call.dart ← NEW
│   ├── providers/
│   │   ├── auth_provider.dart
│   │   ├── activity_provider.dart ← NEW
│   │   ├── task_provider.dart ← NEW
│   │   ├── chat_provider.dart ← NEW
│   │   └── call_provider.dart ← NEW
│   ├── services/
│   │   ├── monitoring_service.dart ← ENHANCE
│   │   ├── socket_service.dart ← NEW
│   │   └── webrtc_service.dart ← NEW
│   └── presentation/
│       └── screens/
│           ├── dashboard/
│           ├── activity/ ← NEW
│           ├── tasks/ ← NEW
│           ├── chat/ ← NEW
│           └── calls/ ← NEW
│
├── simple_backend.js ← ENHANCE
│   • Add activity endpoints
│   • Add task endpoints
│   • Add chat endpoints
│   • Add Socket.io
│   • Add WebRTC signaling
│
└── package.json ← UPDATE
    • Add socket.io
    • Add multer (file upload)
```

---

## ⚡ Quick Implementation Guide

### Step 1: Enhance Backend (2 hours)
```javascript
// Add to simple_backend.js

// Activity endpoints
app.post('/v1/activities/screenshot', uploadScreenshot);
app.post('/v1/activities/website', logWebsiteVisit);
app.post('/v1/activities/file', logFileAccess);
app.get('/v1/activities/timeline', getActivityTimeline);

// Task endpoints
app.get('/v1/projects', getProjects);
app.post('/v1/projects', createProject);
app.get('/v1/sprints', getSprints);
app.post('/v1/tasks', createTask);
app.put('/v1/tasks/:id', updateTask);

// Chat endpoints
app.get('/v1/conversations', getConversations);
app.post('/v1/conversations', createConversation);
app.get('/v1/messages/:conversationId', getMessages);

// Socket.io
io.on('connection', (socket) => {
  socket.on('send_message', handleMessage);
  socket.on('call_initiate', handleCall);
});
```

### Step 2: Create Flutter Screens (4 hours)
```dart
// Activity Screen
ActivityScreen() → Shows timeline of all activities

// Tasks Screen
TasksScreen() → Kanban board with drag-drop

// Chat Screen
ChatScreen() → Message list + input

// Calls Screen
CallsScreen() → Video/audio call UI
```

### Step 3: Connect Everything (2 hours)
- Add Socket.io client
- Connect screens to providers
- Test role-based access
- Polish UI

---

## 🎯 Success Metrics

After 3 days, you should have:

✅ **Module 1: Chat**
- Send/receive messages
- Create group chats
- See online status
- Real-time updates

✅ **Module 2: Activity Monitoring**
- Screenshots captured & displayed
- Website visits logged
- File access tracked
- Activity timeline view
- Role-based filtering

✅ **Module 3: Task Management**
- Create projects & sprints
- Create & assign tasks
- Drag-drop task status
- Add comments
- Role-based visibility

✅ **Module 4: Calls**
- Initiate audio calls
- Accept/reject calls
- Screen sharing
- Call history

---

## 🚨 Common Pitfalls to Avoid

1. **Don't over-engineer** - Use simple in-memory storage
2. **Don't perfect each feature** - Get all 4 modules working first
3. **Don't skip testing** - Test role-based access as you go
4. **Don't ignore the schedule** - Stick to the 3-day plan
5. **Don't add extra features** - Focus on the 4 core modules

---

**Ready to start? Let's begin with Activity Monitoring!**
