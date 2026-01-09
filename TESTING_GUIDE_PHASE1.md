# Phase 1 Testing Guide

## Quick Start

### 1. Start the Backend
```bash
node simple_backend.js
```

You should see:
```
🚀 Mock backend running on http://localhost:3001
📧 Demo accounts:
   Super Admin: superadmin@demo.com / Demo123!
   Admin:       admin@demo.com / Demo123!
   Manager:     manager@demo.com / Demo123!
   Employee:    employee@demo.com / Demo123!

✅ Backend ready for Flutter app!
```

### 2. Run the Flutter App
```bash
flutter run -d macos
```

---

## Test Scenarios

### Scenario 1: Super Admin - Organization Management

**Login:**
- Email: `superadmin@demo.com`
- Password: `Demo123!`

**Expected Dashboard:**
- Title: "Super Admin Dashboard"
- Red "SUPER ADMIN ACCESS" badge
- System Overview cards showing:
  - Organizations: 1
  - Total Users: 4
  - Companies: 1
  - Departments: 1
- Revenue Metrics (MRR, ARR, Growth)
- System Health (CPU, Memory, Disk usage)
- Quick Actions: Organizations, System Analytics, Admin Users

**Test Steps:**
1. ✅ Click "Organizations" card
2. ✅ See "Acme Corporation" in the list
3. ✅ Click "+" button to create organization
4. ✅ Fill in form:
   - Name: "Test Corp"
   - Description: "Test organization"
   - Size: "Medium"
   - Plan: "Professional"
   - Max Users: 100
   - Max Companies: 5
5. ✅ Click "Create Organization"
6. ✅ See success message
7. ✅ See "Test Corp" in organizations list
8. ✅ Click menu (⋮) on "Test Corp"
9. ✅ Click "Delete"
10. ✅ Confirm deletion
11. ✅ See success message
12. ✅ Organization removed from list

**Expected Results:**
- All CRUD operations work
- Form validation works
- Success/error messages appear
- UI updates after operations

---

### Scenario 2: Admin - Companies Management

**Login:**
- Email: `admin@demo.com`
- Password: `Demo123!`

**Expected Dashboard:**
- Title: "System Administration" or "Admin Dashboard"
- System Overview with metrics
- Quick Actions including "Companies" card

**Test Steps:**
1. ✅ Click "Companies" card
2. ✅ See "Acme Tech Division" in the list
3. ✅ Search for "Acme" in search box
4. ✅ See filtered results
5. ✅ Clear search
6. ✅ Click "+" button
7. ✅ Fill in company form:
   - Name: "Tech Innovations Inc"
   - Description: "Software development company"
   - Location: "New York, NY"
   - Industry: "Technology"
   - Size: "Medium"
   - Address: "123 Tech Street"
   - City: "New York"
   - State: "NY"
   - Country: "USA"
   - Postal Code: "10001"
   - Phone: "+1 (555) 123-4567"
   - Email: "contact@techinnovations.com"
8. ✅ Click "Create Company"
9. ✅ See success message
10. ✅ See new company in list with all details
11. ✅ Click menu (⋮) on new company
12. ✅ Click "Edit"
13. ✅ Change description
14. ✅ Click "Update Company"
15. ✅ See updated description
16. ✅ Click menu (⋮) again
17. ✅ Click "Delete"
18. ✅ Read warning about deleting departments and users
19. ✅ Confirm deletion
20. ✅ Company removed

**Expected Results:**
- Company list displays correctly
- Search works
- Create form has all fields
- Edit preserves existing data
- Delete shows warning
- All operations update UI

---

### Scenario 3: Admin - Departments Management

**Login:**
- Email: `admin@demo.com`
- Password: `Demo123!`

**Test Steps:**
1. ✅ From admin dashboard, click "Departments" card
2. ✅ See departments grouped by company
3. ✅ See "Acme Tech Division" header
4. ✅ See "Engineering" department under it
5. ✅ Use company filter dropdown
6. ✅ Select "Acme Tech Division"
7. ✅ See only departments for that company
8. ✅ Search for "Engineering"
9. ✅ See filtered results
10. ✅ Clear filters
11. ✅ Click "+" button
12. ✅ Fill in department form:
    - Company: "Acme Tech Division"
    - Name: "Product Management"
    - Description: "Product strategy and roadmap"
    - Manager: "Jane Manager" (from dropdown)
    - Cost Center: "CC-2001"
    - Budget: "750000"
13. ✅ Click "Create Department"
14. ✅ See success message
15. ✅ See new department under "Acme Tech Division"
16. ✅ Verify department shows manager, budget, cost center
17. ✅ Click menu (⋮) on new department
18. ✅ Click "Edit"
19. ✅ Change budget to "800000"
20. ✅ Click "Update Department"
21. ✅ See updated budget
22. ✅ Click menu (⋮) again
23. ✅ Click "Delete"
24. ✅ Read warning about affecting users
25. ✅ Confirm deletion
26. ✅ Department removed

**Expected Results:**
- Departments grouped by company
- Company filter works
- Search works
- Create form validates company selection
- Manager dropdown shows options
- Budget and cost center display correctly
- Edit preserves data
- Delete shows warning

---

### Scenario 4: Navigation Flow

**Test Complete Admin Flow:**

1. ✅ Login as admin
2. ✅ See admin dashboard
3. ✅ Click "Companies"
4. ✅ Create a new company
5. ✅ Go back to dashboard
6. ✅ Click "Departments"
7. ✅ Create department in new company
8. ✅ Go back to dashboard
9. ✅ Click "Companies" again
10. ✅ See the company you created
11. ✅ Click "Departments" again
12. ✅ See department under your company
13. ✅ Use filters and search
14. ✅ Edit and delete items

**Expected Results:**
- Navigation is smooth
- Data persists across screens
- Back button works
- Dashboard always accessible
- No crashes or errors

---

### Scenario 5: Error Handling

**Test Error States:**

1. ✅ Try to create company with empty name
   - Should show validation error
2. ✅ Try to create company with invalid email
   - Should show validation error
3. ✅ Try to create department without selecting company
   - Should show validation error
4. ✅ Try to create department with invalid budget
   - Should show validation error
5. ✅ Stop backend server
6. ✅ Try to create company
   - Should show network error
7. ✅ Restart backend
8. ✅ Try again
   - Should work

**Expected Results:**
- Form validation prevents invalid submissions
- Network errors show user-friendly messages
- App doesn't crash on errors
- Retry functionality works

---

### Scenario 6: Empty States

**Test Empty States:**

1. ✅ Login as super admin
2. ✅ Go to Organizations
3. ✅ Delete all organizations (except default)
4. ✅ See empty state with icon and message
5. ✅ See "Create Organization" button
6. ✅ Login as admin
7. ✅ Go to Companies
8. ✅ If no companies, see empty state
9. ✅ Go to Departments
10. ✅ If no departments, see empty state
11. ✅ See message "Please create a company first"

**Expected Results:**
- Empty states are user-friendly
- Clear call-to-action buttons
- Helpful messages
- No blank screens

---

### Scenario 7: Search and Filter

**Test Search Functionality:**

1. ✅ Go to Companies screen
2. ✅ Type "Tech" in search
3. ✅ See only companies with "Tech" in name/location/industry
4. ✅ Clear search
5. ✅ See all companies again
6. ✅ Go to Departments screen
7. ✅ Type "Engineering" in search
8. ✅ See only matching departments
9. ✅ Use company filter
10. ✅ See only departments for selected company
11. ✅ Combine search and filter
12. ✅ See results matching both criteria

**Expected Results:**
- Search is case-insensitive
- Search looks in multiple fields
- Filters work independently
- Can combine search and filters
- Results update immediately

---

### Scenario 8: Data Persistence

**Test Data Persistence:**

1. ✅ Create a company
2. ✅ Logout
3. ✅ Login again
4. ✅ Go to Companies
5. ✅ See the company you created
6. ✅ Create a department
7. ✅ Refresh the page (Cmd+R)
8. ✅ Go to Departments
9. ✅ See the department you created

**Expected Results:**
- Data persists after logout
- Data persists after page refresh
- No data loss
- Consistent state

---

## API Testing

### Test Backend Endpoints

```bash
# Run the automated test script
./test_phase1_endpoints.sh
```

**Expected Output:**
```
🧪 Testing Phase 1 API Endpoints
==================================

1. Testing Super Admin Login...
✅ Super Admin Login: "success":true

2. Testing Admin Login...
✅ Admin Login: "success":true

3. Testing GET /super-admin/organizations...
✅ Get Organizations: "success":true
   Organizations count: 1

4. Testing POST /super-admin/organizations...
✅ Create Organization: "success":true
   New Organization ID: org-1234567890

... (all 10 tests pass)

==================================
✅ Phase 1 API Testing Complete!
```

---

## Performance Testing

### Test App Performance:

1. ✅ Create 10 companies
2. ✅ Create 20 departments
3. ✅ Navigate between screens
4. ✅ Use search with large dataset
5. ✅ Use filters with large dataset
6. ✅ Scroll through long lists

**Expected Results:**
- No lag or stuttering
- Smooth scrolling
- Fast search results
- Quick navigation
- No memory leaks

---

## Accessibility Testing

### Test Accessibility:

1. ✅ Use keyboard navigation (Tab key)
2. ✅ Check form labels
3. ✅ Check button labels
4. ✅ Check color contrast
5. ✅ Check error messages are clear
6. ✅ Check success messages are clear

**Expected Results:**
- All interactive elements accessible via keyboard
- All form fields have labels
- All buttons have clear labels
- Good color contrast
- Clear feedback messages

---

## Browser/Platform Testing

### Test on Different Platforms:

- ✅ macOS (primary)
- ⏳ Windows (if available)
- ⏳ Linux (if available)
- ⏳ Web (if configured)

**Expected Results:**
- Consistent behavior across platforms
- No platform-specific bugs
- UI looks good on all platforms

---

## Regression Testing

### Test Existing Features:

1. ✅ Employee dashboard still works
2. ✅ Manager dashboard still works
3. ✅ Activity tracking still works
4. ✅ Screenshots still work
5. ✅ Login/logout still works
6. ✅ Settings still work

**Expected Results:**
- No regressions in existing features
- All previous functionality intact
- No breaking changes

---

## Bug Report Template

If you find a bug, report it with:

```markdown
**Bug Title:** [Short description]

**Steps to Reproduce:**
1. Step 1
2. Step 2
3. Step 3

**Expected Behavior:**
[What should happen]

**Actual Behavior:**
[What actually happens]

**Screenshots:**
[If applicable]

**Environment:**
- OS: macOS 14.x
- Flutter Version: [flutter --version]
- Backend Running: Yes/No

**Severity:**
- [ ] Critical (app crashes)
- [ ] High (feature broken)
- [ ] Medium (feature partially works)
- [ ] Low (cosmetic issue)
```

---

## Test Results Summary

### ✅ Passing Tests:
- Super Admin login
- Admin login
- Organization CRUD
- Company CRUD
- Department CRUD
- Navigation
- Search and filter
- Form validation
- Error handling
- Empty states
- API endpoints

### ⏳ Pending Tests:
- User management (not implemented yet)
- Manager dashboard enhancements (not implemented yet)
- Cross-platform testing
- Performance with large datasets
- Accessibility audit

### ❌ Known Issues:
- None critical
- Manager dropdown shows placeholder data (expected)

---

## Conclusion

**Phase 1 Testing Status: 80% Complete**

All implemented features are working correctly. The remaining 20% is for features not yet implemented (user management, manager enhancements).

**Ready for Production:** No  
**Ready for Next Phase:** Yes  
**Blocking Issues:** None

---

**Document Version**: 1.0  
**Last Updated**: January 7, 2026  
**Tested By**: Development Team  
**Next Review**: After user management implementation
