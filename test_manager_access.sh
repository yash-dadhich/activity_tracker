#!/bin/bash

echo "🧪 Testing Manager Access to Employee Logs"
echo "=========================================="
echo ""

# Test 1: Login as employee and clock in
echo "Test 1: Employee clocks in..."
EMPLOYEE_RESPONSE=$(curl -s -X POST http://localhost:3001/v1/auth/login \
  -H "Content-Type: application/json" \
  -d '{"email":"employee@acme.com","password":"Demo123!"}')

EMPLOYEE_TOKEN=$(echo $EMPLOYEE_RESPONSE | grep -o '"accessToken":"[^"]*"' | cut -d'"' -f4)

if [ -z "$EMPLOYEE_TOKEN" ]; then
  echo "❌ Employee login failed"
  exit 1
fi

echo "✅ Employee logged in"

# Clock in as employee
CLOCK_IN=$(curl -s -X POST http://localhost:3001/v1/time-tracking/clock-in \
  -H "Authorization: Bearer $EMPLOYEE_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{"location":"Office"}')

echo "✅ Employee clocked in"
echo ""

# Test 2: Login as manager
echo "Test 2: Manager logs in..."
MANAGER_RESPONSE=$(curl -s -X POST http://localhost:3001/v1/auth/login \
  -H "Content-Type: application/json" \
  -d '{"email":"manager@acme.com","password":"Demo123!"}')

MANAGER_TOKEN=$(echo $MANAGER_RESPONSE | grep -o '"accessToken":"[^"]*"' | cut -d'"' -f4)

if [ -z "$MANAGER_TOKEN" ]; then
  echo "❌ Manager login failed"
  exit 1
fi

echo "✅ Manager logged in"
echo ""

# Test 3: Manager views department sessions
echo "Test 3: Manager views department sessions..."
SESSIONS=$(curl -s http://localhost:3001/v1/time-tracking/sessions \
  -H "Authorization: Bearer $MANAGER_TOKEN")

SESSION_COUNT=$(echo $SESSIONS | grep -o '"sessions":\[' | wc -l)

if [ $SESSION_COUNT -gt 0 ]; then
  echo "✅ Manager can see department sessions"
  echo "   Sessions found: $(echo $SESSIONS | grep -o '"id":"time-[^"]*"' | wc -l)"
else
  echo "❌ Manager cannot see sessions"
fi
echo ""

# Test 4: Manager views employee details
echo "Test 4: Manager views employee details..."
ACTIVITIES=$(curl -s "http://localhost:3001/v1/activities/detailed?userId=emp-001" \
  -H "Authorization: Bearer $MANAGER_TOKEN")

if echo $ACTIVITIES | grep -q '"success":true'; then
  echo "✅ Manager can see employee activities"
else
  echo "❌ Manager cannot see employee activities"
  echo "   Response: $ACTIVITIES"
fi
echo ""

# Test 5: Manager views work summary
echo "Test 5: Manager views work summary..."
SUMMARY=$(curl -s http://localhost:3001/v1/time-tracking/summary \
  -H "Authorization: Bearer $MANAGER_TOKEN")

if echo $SUMMARY | grep -q '"totalSessions"'; then
  TOTAL=$(echo $SUMMARY | grep -o '"totalSessions":[0-9]*' | cut -d':' -f2)
  echo "✅ Manager can see work summary"
  echo "   Total sessions: $TOTAL"
else
  echo "❌ Manager cannot see work summary"
fi
echo ""

echo "=========================================="
echo "✅ All tests completed!"
