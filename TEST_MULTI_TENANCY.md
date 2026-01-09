# Multi-Tenancy Testing Checklist

**Quick checklist to verify multi-tenancy is working correctly**

---

## ✅ Pre-Test Verification

### System Status
- [ ] Backend is running on http://localhost:3001
- [ ] Flutter app is running on macOS
- [ ] No error messages in console
- [ ] Login screen is visible

**Check backend:**
```bash
curl http://localhost:3001/health
# Should return: {"status":"healthy"}
```

---

## 🧪 Test Suite

### Test 1: Super Admin - Global Access (5 minutes)

#### Step 1: Login
- [ ] Open Flutter app
- [ ] Enter email: `superadmin@demo.com`
- [ ] Enter password: `Demo123!`
- [ ] Click "Login"
- [ ] ✅ Should see Super Admin Dashboard

#### Step 2: View Organizations
- [ ] Click "Organizations" card
- [ ] ✅ Should see 2 organizations:
  - [ ] Acme Corporation
  - [ ] TechCorp Industries
- [ ] ✅ Both organizations should be visible

#### Step 3: View System Analytics
- [ ] Go back to dashboard
- [ ] ✅ Should see system metrics:
  - [ ] Total Organizations: 2
  - [ ] Total Users: 7
  - [ ] Total Companies: 2
  - [ ] Total Departments: 2

#### Step 4: Logout
- [ ] Click user menu (top right)
- [ ] Click "Logout"
- [ ] ✅ Should return to login screen

**Result:** [ ] PASS / [ ] FAIL

---

### Test 2: Acme Admin - Data Isolation (10 minutes)

#### Step 1: Login
- [ ] Enter email: `admin@acme.com`
- [ ] Enter password: `Demo123!`
- [ ] Click "Login"
- [ ] ✅ Should see Admin Dashboard

#### Step 2: View Companies
- [ ] Click "Companies" card
- [ ] ✅ Should see ONLY 1 company:
  - [ ] Acme Tech Division
- [ ] ❌ Should NOT see:
  - [ ] TechCorp Solutions

#### Step 3: View Departments
- [ ] Go back to dashboard
- [ ] Click "Departments" card
- [ ] ✅ Should see ONLY 1 department:
  - [ ] Engineering
- [ ] ❌ Should NOT see:
  - [ ] Development

#### Step 4: View Team Members
- [ ] Go back to dashboard
- [ ] Click "Team Members" card
- [ ] ✅ Should see ONLY 3 users:
  - [ ] Alice Admin (admin@acme.com)
  - [ ] Mike Manager (manager@acme.com)
  - [ ] John Employee (employee@acme.com)
- [ ] ❌ Should NOT see:
  - [ ] Bob Administrator
  - [ ] Sarah Lead
  - [ ] Emma Developer

#### Step 5: Test Search
- [ ] In Team Members screen
- [ ] Search for "Bob"
- [ ] ✅ Should return 0 results
- [ ] Search for "Alice"
- [ ] ✅ Should return 1 result (Alice Admin)

#### Step 6: Create New Company
- [ ] Go to Companies screen
- [ ] Click "+" button
- [ ] Fill in:
  - [ ] Name: "Acme Innovation Labs"
  - [ ] Location: "San Francisco, CA"
  - [ ] Industry: "Technology"
- [ ] Click "Create Company"
- [ ] ✅ Should see success message
- [ ] ✅ Should see new company in list

#### Step 7: Logout
- [ ] Click user menu
- [ ] Click "Logout"

**Result:** [ ] PASS / [ ] FAIL

---

### Test 3: TechCorp Admin - Data Isolation (10 minutes)

#### Step 1: Login
- [ ] Enter email: `admin@techcorp.com`
- [ ] Enter password: `Demo123!`
- [ ] Click "Login"
- [ ] ✅ Should see Admin Dashboard

#### Step 2: View Companies
- [ ] Click "Companies" card
- [ ] ✅ Should see ONLY 1 company:
  - [ ] TechCorp Solutions
- [ ] ❌ Should NOT see:
  - [ ] Acme Tech Division
  - [ ] Acme Innovation Labs (created in Test 2)

#### Step 3: View Departments
- [ ] Go back to dashboard
- [ ] Click "Departments" card
- [ ] ✅ Should see ONLY 1 department:
  - [ ] Development
- [ ] ❌ Should NOT see:
  - [ ] Engineering

#### Step 4: View Team Members
- [ ] Go back to dashboard
- [ ] Click "Team Members" card
- [ ] ✅ Should see ONLY 3 users:
  - [ ] Bob Administrator (admin@techcorp.com)
  - [ ] Sarah Lead (manager@techcorp.com)
  - [ ] Emma Developer (employee@techcorp.com)
- [ ] ❌ Should NOT see:
  - [ ] Alice Admin
  - [ ] Mike Manager
  - [ ] John Employee

#### Step 5: Test Search
- [ ] In Team Members screen
- [ ] Search for "Alice"
- [ ] ✅ Should return 0 results
- [ ] Search for "Bob"
- [ ] ✅ Should return 1 result (Bob Administrator)

#### Step 6: Create New User
- [ ] Go to Team Members screen
- [ ] Click "+" button
- [ ] Fill in:
  - [ ] Email: "newuser@techcorp.com"
  - [ ] First Name: "New"
  - [ ] Last Name: "User"
  - [ ] Role: "employee"
  - [ ] Company: "TechCorp Solutions"
  - [ ] Department: "Development"
- [ ] Click "Add Team Member"
- [ ] ✅ Should see success message
- [ ] ✅ Should see new user in list

#### Step 7: Logout
- [ ] Click user menu
- [ ] Click "Logout"

**Result:** [ ] PASS / [ ] FAIL

---

### Test 4: Cross-Organization Verification (5 minutes)

#### Step 1: Login as Super Admin
- [ ] Login as `superadmin@demo.com`
- [ ] Navigate to Organizations
- [ ] ✅ Should see both organizations

#### Step 2: Verify Acme Data
- [ ] Navigate to Companies
- [ ] ✅ Should see:
  - [ ] Acme Tech Division
  - [ ] Acme Innovation Labs (created in Test 2)
  - [ ] TechCorp Solutions

#### Step 3: Verify TechCorp Data
- [ ] Navigate to Users
- [ ] ✅ Should see all users including:
  - [ ] newuser@techcorp.com (created in Test 3)
  - [ ] All Acme users
  - [ ] All TechCorp users

#### Step 4: Verify Total Counts
- [ ] ✅ Total Organizations: 2
- [ ] ✅ Total Companies: 3 (Acme Tech + Acme Innovation + TechCorp)
- [ ] ✅ Total Users: 8 (1 super + 3 Acme + 4 TechCorp)

**Result:** [ ] PASS / [ ] FAIL

---

### Test 5: Manager Access (5 minutes)

#### Step 1: Login as Acme Manager
- [ ] Login as `manager@acme.com`
- [ ] ✅ Should see Manager Dashboard
- [ ] ✅ Should see department context: "Engineering"

#### Step 2: View Team
- [ ] Click "View All Members"
- [ ] ✅ Should see team members in Engineering department
- [ ] ❌ Should NOT see TechCorp users

#### Step 3: Login as TechCorp Manager
- [ ] Logout and login as `manager@techcorp.com`
- [ ] ✅ Should see Manager Dashboard
- [ ] ✅ Should see department context: "Development"

#### Step 4: View Team
- [ ] Click "View All Members"
- [ ] ✅ Should see team members in Development department
- [ ] ❌ Should NOT see Acme users

**Result:** [ ] PASS / [ ] FAIL

---

### Test 6: Employee Access (3 minutes)

#### Step 1: Login as Acme Employee
- [ ] Login as `employee@acme.com`
- [ ] ✅ Should see Employee Dashboard
- [ ] ✅ Should see personal activity data

#### Step 2: Login as TechCorp Employee
- [ ] Logout and login as `employee@techcorp.com`
- [ ] ✅ Should see Employee Dashboard
- [ ] ✅ Should see personal activity data

**Result:** [ ] PASS / [ ] FAIL

---

## 📊 Test Results Summary

### Overall Results
- [ ] Test 1: Super Admin - Global Access
- [ ] Test 2: Acme Admin - Data Isolation
- [ ] Test 3: TechCorp Admin - Data Isolation
- [ ] Test 4: Cross-Organization Verification
- [ ] Test 5: Manager Access
- [ ] Test 6: Employee Access

### Pass/Fail Count
- Total Tests: 6
- Passed: ___
- Failed: ___
- Pass Rate: ___%

---

## 🐛 Issues Found

### Issue 1
- **Test:** _______________
- **Description:** _______________
- **Severity:** [ ] Critical [ ] High [ ] Medium [ ] Low
- **Status:** [ ] Open [ ] Fixed

### Issue 2
- **Test:** _______________
- **Description:** _______________
- **Severity:** [ ] Critical [ ] High [ ] Medium [ ] Low
- **Status:** [ ] Open [ ] Fixed

---

## ✅ Success Criteria

Multi-tenancy is working correctly if:

- [ ] Super Admin can see all organizations (2)
- [ ] Super Admin can see all companies (3)
- [ ] Super Admin can see all users (8)
- [ ] Acme Admin can only see Acme data
- [ ] TechCorp Admin can only see TechCorp data
- [ ] Acme Admin cannot see TechCorp data
- [ ] TechCorp Admin cannot see Acme data
- [ ] Data created in one org is not visible in another
- [ ] Search only returns results from user's organization
- [ ] All CRUD operations work correctly

---

## 🚀 Quick API Tests

If you want to test the API directly:

### Test Super Admin
```bash
# Login
curl -X POST http://localhost:3001/v1/auth/login \
  -H "Content-Type: application/json" \
  -d '{"email":"superadmin@demo.com","password":"Demo123!"}'

# Get companies (use token from login)
curl http://localhost:3001/v1/admin/companies \
  -H "Authorization: Bearer <TOKEN>"

# Expected: 3 companies
```

### Test Acme Admin
```bash
# Login
curl -X POST http://localhost:3001/v1/auth/login \
  -H "Content-Type: application/json" \
  -d '{"email":"admin@acme.com","password":"Demo123!"}'

# Get companies (use token from login)
curl http://localhost:3001/v1/admin/companies \
  -H "Authorization: Bearer <TOKEN>"

# Expected: 2 companies (Acme only)
```

### Test TechCorp Admin
```bash
# Login
curl -X POST http://localhost:3001/v1/auth/login \
  -H "Content-Type: application/json" \
  -d '{"email":"admin@techcorp.com","password":"Demo123!"}'

# Get companies (use token from login)
curl http://localhost:3001/v1/admin/companies \
  -H "Authorization: Bearer <TOKEN>"

# Expected: 1 company (TechCorp only)
```

---

## 📝 Notes

### Testing Environment
- Date: _______________
- Tester: _______________
- Backend Version: _______________
- Flutter Version: _______________
- Platform: macOS

### Additional Notes
_______________________________________________
_______________________________________________
_______________________________________________

---

## ✅ Sign-Off

- [ ] All tests completed
- [ ] All tests passed
- [ ] No critical issues found
- [ ] Multi-tenancy is working correctly
- [ ] Ready for production

**Tester Signature:** _______________  
**Date:** _______________

---

**Status:** [ ] PASS / [ ] FAIL  
**Multi-Tenancy:** [ ] WORKING / [ ] NOT WORKING  
**Ready for Production:** [ ] YES / [ ] NO
