# 🧪 How to Test Non-IT Company Dashboard & Live Tracking

## ⚡ Quick Start (5 minutes)

### Step 1: Access the Application
```
Open your browser and go to:
http://localhost:8000
```

### Step 2: Go to Non-IT Signup
```
Click "Create Account" → Look for "Non-IT Company" option
OR
Go directly to: http://localhost:8000/signup-non-it
```

### Step 3: Create Test Account
```
Fill in the form:
- Full Name: Test Employee
- Company Name: Test Field Company
- Email: testnon-it@company.com
- Password: TestPass123!
- Confirm Password: TestPass123!
- ✓ Accept Terms

Click "Create Account"
```

**Note:** Email verification will be required in Phase 3. For now, you may need to skip or check database directly.

---

## 🔑 Testing with Demo Accounts (Recommended)

### Option 1: Create Test Non-IT Accounts via Database

Since we don't have email verification yet, you can directly insert test accounts:

```sql
-- Create Super Admin for Non-IT company
INSERT INTO users (
  id, email, full_name, role, company_id, is_active, 
  email_verified, company_type
) VALUES (
  gen_random_uuid(), 
  'admin-nit@company.com', 
  'Admin NonIT', 
  'super_admin', 
  (SELECT id FROM companies LIMIT 1), 
  true, 
  true, 
  'non-it'
);

-- Create HR Manager for Non-IT company
INSERT INTO users (
  id, email, full_name, role, company_id, is_active, 
  email_verified, company_type
) VALUES (
  gen_random_uuid(), 
  'hr-nit@company.com', 
  'HR Manager NonIT', 
  'hr_manager', 
  (SELECT id FROM companies LIMIT 1), 
  true, 
  true, 
  'non-it'
);

-- Create Employee for Non-IT company
INSERT INTO users (
  id, email, full_name, role, company_id, is_active, 
  email_verified, company_type
) VALUES (
  gen_random_uuid(), 
  'emp-nit@company.com', 
  'Employee NonIT', 
  'employee', 
  (SELECT id FROM companies LIMIT 1), 
  true, 
  true, 
  'non-it'
);
```

---

## 📱 Testing the Employee Dashboard (Non-IT)

### Step 1: Login as Employee
```
URL: http://localhost:8000/login
Email: emp-nit@company.com (or your test email)
Password: TestPass123!
Click "Sign In"
```

### Step 2: Access Employee Dashboard
```
After login, you should see:
✓ Standard employee dashboard
✓ NEW: Location Tracking Badge (below Key Metrics)
```

### Step 3: Look for Location Badge
```
Location Tracking
├─ Current Status: "Tracking Disabled" (initially)
├─ Button: "Enable" (green)
├─ Last Update: Never
└─ Error Area: (empty if no errors)
```

### Step 4: Enable Location Tracking
```
1. Click the "Enable" button on the badge
2. Browser will ask for permission:
   "Allow this site to access your location?"
   
   Click "Allow" ← IMPORTANT
   
3. Badge should now show:
   ✓ Status: "Tracking Live" (with pulse animation)
   ✓ Last Update: "a few seconds ago"
   ✓ Dot color: Green (animated pulse)
```

### Step 5: Test Location Updates
```
Wait 30 seconds (auto-update interval)
✓ Last Update should change to "30s ago", "1m ago", etc.
✓ Status should remain "Tracking Live"
✓ Green pulse should continue
```

### Step 6: Test Disable
```
1. Click "Disable" button
2. Badge should show:
   ✓ Status: "Tracking Disabled"
   ✓ Button changes to "Enable" (green)
   ✓ Updates stop
```

### Step 7: Test Permission Denied
```
1. Repeat Step 4 but click "Block" instead of "Allow"
2. Badge should show:
   ✓ Status: "Permission Denied"
   ✓ Error message: "Location permission denied"
   ✓ Button still available to retry
```

---

## 👔 Testing the HR Dashboard (Non-IT)

### Step 1: Login as HR Manager
```
URL: http://localhost:8000/login
Email: hr-nit@company.com
Password: TestPass123!
Click "Sign In"
```

### Step 2: Navigate to HR Dashboard
```
URL: http://localhost:8000/dashboard/hr
You should see the HR Dashboard
```

### Step 3: Look for Location Tracking Panel
```
Scroll down on the HR Dashboard
You should see NEW section:
"Employee Locations"
├─ Refresh Button
├─ Location Table
│   ├─ Employee Name
│   ├─ Role
│   ├─ Coordinates (lat, lon)
│   ├─ Last Update
│   └─ Status (live/recent/idle/offline)
```

### Step 4: View Employee Locations
```
The table shows:
├─ Employee Name: "Employee NonIT"
├─ Role: employee
├─ Coordinates: 40.7128, -74.0060 (example)
├─ Last Update: "5m ago" (or "live")
└─ Status: 
    ✓ Green dot = "live" (< 5 minutes)
    ✓ Blue dot = "recent" (5-30 minutes)
    ✓ Yellow dot = "idle" (30-120 minutes)
    ✓ Grey dot = "offline" (> 120 minutes)
```

### Step 5: Test Auto-Refresh
```
1. Note the "Last Update" time
2. Wait 30 seconds
3. The time should automatically update
4. No page refresh needed!
```

### Step 6: Test Manual Refresh
```
1. Click the "Refresh" button
2. Table should update immediately
3. Shows fresh data from backend
```

### Step 7: Test Multiple Employees
```
If multiple employees have tracking enabled:
✓ All should appear in table
✓ Each with own status
✓ All updating independently
```

---

## 🏢 Testing the Admin Dashboard (Non-IT)

### Step 1: Login as Admin
```
URL: http://localhost:8000/login
Email: admin-nit@company.com
Password: TestPass123!
Click "Sign In"
```

### Step 2: Navigate to Admin Dashboard
```
URL: http://localhost:8000/dashboard/admin
You should see the Admin Dashboard
```

### Step 3: Look for Dual Location Tracking Panel
```
Scroll down on the Admin Dashboard
You should see NEW section:
"Dual Location Tracking"
├─ 3 Tabs:
│   ├─ All Users (count)
│   ├─ Field Employees (count)
│   └─ HR Staff (count)
├─ Refresh Button
└─ Location Table(s)
```

### Step 4: View All Users Locations
```
1. Click "All Users" tab (should be active by default)
2. See locations table with all users:
   ├─ Field Employees table
   └─ HR Staff table
3. Each shows: Name, Coordinates, Last Update, Status
```

### Step 5: Filter by Employee Role
```
1. Click "Field Employees" tab
2. See only employee locations
3. Count should match number of employees
```

### Step 6: Filter by HR Role
```
1. Click "HR Staff" tab
2. See only HR staff locations
3. Count should match number of HR users
```

### Step 7: Test Dual Tracking Updates
```
1. Enable tracking on employee account (from Step 1-6)
2. Go back to admin dashboard
3. Click "Refresh" button
4. Employee should appear in table
5. Auto-refresh works every 30 seconds too
```

---

## 🔍 Troubleshooting: What to Look For

### Issue: Location Badge Not Showing on Employee Dashboard

**What to Check:**
```
1. Are you logged in as Non-IT company?
   → Check by opening browser console:
      const { isNonIT } = useAuth()
      console.log(isNonIT) // should be true
      
2. Is the component imported?
   → Open DevTools → Elements → Search for "Location Tracking"
   
3. Check browser console for errors
   → F12 → Console tab → Look for red errors
```

**If not showing:**
```
1. Verify company_type field exists in database
2. Verify user.company_type = 'non-it'
3. Clear browser cache: Ctrl+Shift+Del
4. Reload page: Ctrl+Shift+R
```

### Issue: "Permission Denied" Error

**This is EXPECTED behavior!** Do this:

```
1. Click "Enable" again
2. Look for browser permission popup
3. Change permission:
   - Chrome: Settings → Privacy → Site Settings → Location
   - Firefox: Settings → Privacy → Permissions → Location
   - Safari: Develop → Allow Location
4. Allow localhost:8000
5. Try again
```

### Issue: Location not updating on HR/Admin Dashboard

**What to Check:**
```
1. Is employee account still logged in?
2. Did you click "Enable" on location badge?
3. Did you grant browser permission?
4. Wait 30 seconds for auto-refresh
5. Or click "Refresh" button manually
```

**Backend Note (Phase 3):**
```
Currently, location data is NOT being sent to backend
because API endpoints don't exist yet (Phase 3).

Once Phase 3 is done:
✓ Click Enable → Location sent every 30 seconds
✓ HR/Admin dashboard pulls real locations
✓ Everything updates live
```

---

## 📊 Testing Data Checklist

### Employee Dashboard (Non-IT)
```
□ Location Badge appears
□ Status shows "Tracking Disabled" initially
□ Enable button is clickable
□ Clicking Enable shows browser permission popup
□ After Allow: Status shows "Tracking Live"
□ Green pulse animation visible
□ Last Update shows recent time
□ Disable button works
□ Clicking Disable stops tracking
□ Permission Denied scenario tested
```

### HR Dashboard (Non-IT)
```
□ "Employee Locations" section visible
□ Table shows employee name(s)
□ Coordinates display correctly
□ Status indicators show (live/recent/idle/offline)
□ Last Update timestamps display
□ Auto-refresh works every 30 seconds
□ Manual "Refresh" button works
□ Loading state visible while fetching
□ Error handling works (if no data)
□ Multiple employees display correctly
```

### Admin Dashboard (Non-IT)
```
□ "Dual Location Tracking" section visible
□ All three tabs present (All, Employees, HR)
□ Default tab is "All Users"
□ Employee table shows employees
□ HR table shows HR staff (if any)
□ Status indicators correct
□ Last Update shows correct times
□ Tab switching works
□ Auto-refresh works
□ Manual refresh works
□ Loading states visible
□ Error handling present
```

---

## 🎬 Complete Testing Workflow

### Scenario 1: Single Employee Tracking
```
Time: 0 min
├─ Employee Login
├─ See location badge
├─ Click "Enable"
├─ Grant permission
└─ Status: "Tracking Live" ✓

Time: 1 min (after 30s auto-refresh)
├─ HR Login
├─ See "Employee Locations"
├─ Employee appears in table
├─ Status: "live" (< 5 min)
└─ Last Update shows time ✓

Time: 10 min
├─ Admin Login
├─ See "Dual Location Tracking"
├─ Employee shows in "Field Employees" tab
├─ Click "All Users" tab
├─ Employee visible with HR staff (if tracking)
└─ All statuses updating ✓
```

### Scenario 2: Permission Denied Then Allowed
```
Time: 0 min
├─ Employee Click "Enable"
├─ Browser asks permission
├─ Employee clicks "Block"
├─ Badge shows "Permission Denied" ✓
└─ HR sees NO location data ✓

Time: 1 min
├─ Employee Click "Enable" again
├─ Browser asks permission again (or User changes setting)
├─ Employee clicks "Allow"
├─ Badge shows "Tracking Live" ✓
└─ HR sees location immediately ✓
```

### Scenario 3: Multiple Employees
```
Setup:
├─ Create 3 test employee accounts
├─ Login as each
├─ Enable tracking
└─ All have company_type = 'non-it'

Testing:
├─ HR Login
├─ "Employee Locations" shows 3 employees ✓
├─ All have coordinates ✓
├─ All have statuses ✓
└─ All update independently ✓

Admin View:
├─ Admin Login
├─ "Field Employees" tab shows 3 ✓
├─ "All Users" shows 3 employees ✓
└─ All status indicators working ✓
```

---

## 📝 Test Report Template

Use this to document your testing:

```markdown
# Non-IT Company Dashboard Testing Report

**Date:** [Date]
**Tester:** [Name]
**Environment:** Local Development

## Employee Dashboard
- [ ] Location badge visible
- [ ] Enable/Disable works
- [ ] Status updates correctly
- [ ] Last update timestamp accurate
- [ ] Permission handling works
- [ ] Errors handled gracefully

**Notes:** [Any observations]

## HR Dashboard
- [ ] Location tracker visible
- [ ] Employees display in table
- [ ] Coordinates show
- [ ] Status indicators correct
- [ ] Auto-refresh works
- [ ] Manual refresh works

**Notes:** [Any observations]

## Admin Dashboard
- [ ] Dual tracker visible
- [ ] All tabs functional
- [ ] Employees/HR separated
- [ ] All users view works
- [ ] Auto-refresh works
- [ ] Manual refresh works

**Notes:** [Any observations]

## Issues Found
1. [Issue 1]
2. [Issue 2]

## Overall Status
- [ ] PASS
- [ ] FAIL
- [ ] PARTIAL
```

---

## 🔧 Advanced Testing (For Developers)

### Browser Console Testing

```javascript
// Check company type
const { profile, companyType, isNonIT } = useAuth()
console.log('Company Type:', companyType)
console.log('Is Non-IT:', isNonIT)
console.log('Profile:', profile)

// Check location tracking status
const { 
  isTracking, 
  isEnabled, 
  location, 
  permissionStatus 
} = useLocationTracking(userId, userRole, isNonIT)

console.log({
  isTracking,
  isEnabled,
  location,
  permissionStatus
})

// Check geolocation support
console.log('Geolocation supported:', !!navigator.geolocation)

// Get current location (one-time)
navigator.geolocation.getCurrentPosition(
  (pos) => console.log('Location:', pos.coords),
  (err) => console.log('Error:', err)
)
```

### Network Testing

```
1. Open DevTools → Network tab
2. Enable tracking on employee account
3. Look for API calls to:
   - POST /api/locations (Phase 3)
   - GET /api/locations/company/:id (Phase 3)
   - PUT /api/locations/tracking/:id (Phase 3)

Note: These won't work until Phase 3 backend is implemented
```

### Performance Testing

```
1. Enable tracking on 10 test accounts
2. Open Admin dashboard
3. Monitor:
   - Page load time
   - Auto-refresh time (30s interval)
   - Memory usage
   - CPU usage
   - Network bandwidth

Should see:
✓ < 2 second load time
✓ < 500ms refresh time
✓ No memory leaks
✓ Minimal CPU while idle
✓ Low bandwidth (just location data)
```

---

## ✅ When Everything Works

You should see:

### Employee View
```
Dashboard
├─ Key Metrics (attendance, leaves, tasks)
├─ Location Tracking ← NEW
│  ├─ Status: "Tracking Live" (green pulse)
│  ├─ Last Update: "30s ago" (auto-updating)
│  ├─ Error: (none)
│  └─ Button: "Disable" (red)
├─ Charts
└─ Other sections (unchanged)
```

### HR View
```
Dashboard
├─ HR specific sections (unchanged)
├─ Employee Locations ← NEW
│  ├─ Table with employees
│  ├─ Each row:
│  │  ├─ Name: "Employee NonIT"
│  │  ├─ Role: employee
│  │  ├─ Lat,Lon: 40.7128, -74.0060
│  │  ├─ Last Update: "5m ago"
│  │  └─ Status: 🟢 live
│  └─ Refresh button
└─ Other sections (unchanged)
```

### Admin View
```
Dashboard
├─ Admin sections (unchanged)
├─ Dual Location Tracking ← NEW
│  ├─ Tabs: [All Users] [Field Employees] [HR Staff]
│  ├─ All Users Tab:
│  │  ├─ Field Employees table (3 employees)
│  │  └─ HR Staff table (2 managers)
│  ├─ Refresh button
│  └─ Auto-updates every 30s
└─ Other sections (unchanged)
```

---

## 🚫 What Won't Work Yet (Phase 3 Required)

```
❌ Location data not actually being saved to backend
   → Because API endpoints don't exist yet

❌ HR/Admin not seeing live updates across page refresh
   → Because data not persisted yet

❌ Email verification on signup
   → Because email system not implemented

❌ Exact coordinates (will show demo data)
   → Because backend not sending real locations

✅ But the UI is all there and ready!
✅ Once Phase 3 backend is done, it all works!
```

---

## 📞 Still Have Questions?

1. **Check the docs:**
   - NON_IT_QUICK_START.md
   - IMPLEMENTATION_SUMMARY.md
   - NON_IT_PHASE_2_COMPLETE.md

2. **Search code for examples:**
   - Look in tracking component files
   - Check dashboard components
   - Review useLocationTracking hook

3. **Check browser console:**
   - F12 → Console
   - Look for error messages
   - Use provided console testing code above

---

**Happy Testing!** 🎉

The frontend is ready. Backend (Phase 3) will make live tracking fully functional.
