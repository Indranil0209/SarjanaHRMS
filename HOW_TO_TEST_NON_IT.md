# 🎯 HOW TO TEST NON-IT COMPANY DASHBOARD & LIVE TRACKING

**This is your complete testing guide. Read this first!**

---

## 📍 TL;DR (Too Long; Didn't Read)

### In 30 Seconds:
1. Open: `http://localhost:8000/signup-non-it` OR `http://localhost:8000/login`
2. Login as Non-IT employee
3. See location badge on dashboard
4. Click "Enable" and grant permission
5. See "Tracking Live" with green pulsing dot
6. As HR/Admin, see employee locations in table

That's it! 🎉

---

## 🎬 Complete Testing Steps

### PART 1: Create Non-IT Test Account (5 min)

#### Option A: Quick Signup
```
1. Go to: http://localhost:8000/signup-non-it
2. Fill form:
   - Full Name: Test User
   - Company: Test Field Company
   - Email: test@fieldcompany.com
   - Password: Test123!
3. Click "Create Account"

Note: Email verification skipped in Phase 2 (works in Phase 3)
```

#### Option B: Use Database (Skip Email Verification)
```sql
-- Create Non-IT company users

INSERT INTO users (email, full_name, role, company_type, is_active)
VALUES (
  'emp@field.com',
  'Test Employee',
  'employee',
  'non-it',
  true
);

INSERT INTO users (email, full_name, role, company_type, is_active)
VALUES (
  'hr@field.com',
  'HR Manager',
  'hr_manager',
  'non-it',
  true
);

INSERT INTO users (email, full_name, role, company_type, is_active)
VALUES (
  'admin@field.com',
  'Admin',
  'super_admin',
  'non-it',
  true
);
```

---

### PART 2: Test Employee Dashboard (5 min)

#### Step 2.1: Login as Employee
```
URL: http://localhost:8000/login
Email: emp@field.com
Password: Test123!
Click "Sign In"
```

#### Step 2.2: Find Location Badge
```
On dashboard:
1. Look between "Key Metrics" section and "Charts" section
2. Find: "📍 Location Tracking" card
3. Initial state shows:
   - 🔯 Status: "Tracking Disabled"
   - Button: "Enable" (green)
```

#### Step 2.3: Enable Tracking
```
1. Click "Enable" button
2. Browser popup: "Allow this site to access your location?"
3. Click "Allow" (IMPORTANT)
4. Within 2 seconds you should see:
   - 🟢 Status: "Tracking Live"
   - ✨ Green dot (pulsing animation)
   - ⏱️ Last update: "5s ago"
```

#### Step 2.4: Watch It Update
```
1. Wait 30 seconds
2. Watch "Last update" change:
   - "5s ago" → "30s ago" → "1m ago" → "1m 30s ago"
3. Green dot keeps pulsing
4. This is auto-refresh! ✅
```

#### Step 2.5: Disable Tracking
```
1. Click "Disable" button
2. Status changes back to: "Tracking Disabled" 🔯
3. Green dot changes to grey dot
4. Updates stop
```

#### Step 2.6: Test Permission Denied
```
1. Logout and login again
2. Try Step 2.3 but click "Block" instead of "Allow"
3. You should see:
   - ⚠️ Status: "Permission Denied"
   - ❌ Error message in red box
   - Button: "Enable" (to retry)
```

✅ **Employee Dashboard Complete!**

---

### PART 3: Test HR Dashboard (5 min)

#### Step 3.1: Login as HR Manager
```
URL: http://localhost:8000/login
Email: hr@field.com
Password: Test123!
Click "Sign In"
```

#### Step 3.2: Navigate to HR Dashboard
```
URL: http://localhost:8000/dashboard/hr
OR
Click "HR Dashboard" if navigation menu available
```

#### Step 3.3: Find Employee Locations Section
```
Scroll to BOTTOM of dashboard
Find: "👥 Employee Locations" section
(This is NEW for Non-IT companies)
```

#### Step 3.4: View Employees
```
You should see a table showing:
- Column 1: Employee Name
- Column 2: Role (should show "employee")
- Column 3: Coordinates (lat, lon)
- Column 4: Last Update (time)
- Column 5: Status (colored dot: 🟢 🔵 🟡 ⚪)

Example:
┌────────────┬────────┬──────────────────┬─────────┬────────┐
│ Employee   │ Role   │ Coordinates      │ Last    │ Status │
├────────────┼────────┼──────────────────┼─────────┼────────┤
│ Test Emp   │Employee│40.7128, -74.0060 │ 5m ago  │ 🟢     │
│ John Doe   │Employee│40.7200, -74.0076 │12m ago  │ 🔵     │
│ Jane Smith │Employee│Offline           │ 2h ago  │ ⚪     │
└────────────┴────────┴──────────────────┴─────────┴────────┘
```

#### Step 3.5: Test Refresh Button
```
1. Note the "Last Update" times
2. Click [Refresh ↻] button
3. Table should update within 1 second
4. Times may show "now", "1s ago", etc.
```

#### Step 3.6: Test Auto-Refresh
```
1. Watch the table for 30 seconds
2. WITHOUT clicking anything
3. You should see "Last Update" times change automatically
4. This is auto-refresh happening! ✅
```

#### Step 3.7: Status Indicator Meanings
```
🟢 Green (Live):   Updated in last 5 minutes (ACTIVE)
🔵 Blue (Recent):  Updated 5-30 minutes ago
🟡 Yellow (Idle):  Updated 30-120 minutes ago
⚪ Grey (Offline): Updated > 120 minutes ago

What you might see:
- If employee enabled tracking now: 🟢 live
- If employee enabled 10 min ago: 🔵 recent  
- If employee enabled 50 min ago: 🟡 idle
- If employee never enabled: ⚪ offline
```

✅ **HR Dashboard Complete!**

---

### PART 4: Test Admin Dashboard (5 min)

#### Step 4.1: Login as Admin
```
URL: http://localhost:8000/login
Email: admin@field.com
Password: Test123!
Click "Sign In"
```

#### Step 4.2: Navigate to Admin Dashboard
```
URL: http://localhost:8000/dashboard/admin
OR
Click "Admin Dashboard" if navigation menu available
```

#### Step 4.3: Find Dual Location Tracking
```
Scroll to BOTTOM of dashboard
Find: "👁️ Dual Location Tracking" section
(This is NEW for Non-IT companies)
```

#### Step 4.4: See Three Tabs
```
You should see tabs at the top:
┌─────────────────────────────────────────┐
│ [All Users] │ [Field Employees] │ [HR Staff] │
└─────────────────────────────────────────┘

Default: "All Users" is selected
```

#### Step 4.5: View All Users
```
With "All Users" tab active, you see TWO tables:

Table 1: Field Employees (with count)
├─ Columns: Name, Coordinates, Last Update, Status
├─ Shows all employee locations

Table 2: HR Staff (with count)
├─ Columns: Name, Coordinates, Last Update, Status  
├─ Shows all HR manager locations
```

#### Step 4.6: Filter by Employee
```
1. Click [Field Employees] tab
2. Only employee table shows
3. Employee count in tab label: "Field Employees (3)"
4. HR table is hidden
```

#### Step 4.7: Filter by HR
```
1. Click [HR Staff] tab
2. Only HR staff table shows
3. HR count in tab label: "HR Staff (2)"
4. Employee table is hidden
```

#### Step 4.8: Test Refresh
```
1. Click [Refresh ↻] button
2. Both tables update immediately
3. New coordinates and times show
4. Status indicators may change
```

#### Step 4.9: Test Auto-Refresh
```
1. Go to "All Users" tab
2. Watch for 30 seconds (DON'T click anything)
3. You should see times auto-update
4. This confirms auto-refresh works! ✅
```

✅ **Admin Dashboard Complete!**

---

## ✅ Final Verification Checklist

### Employee Dashboard ✅
- [ ] Location badge visible between Key Metrics and Charts
- [ ] Badge shows "Tracking Disabled" initially
- [ ] "Enable" button is green and clickable
- [ ] Clicking Enable shows browser permission popup
- [ ] After Allow: Shows "Tracking Live" with green dot
- [ ] Green dot has pulsing animation
- [ ] Last update shows and updates every 30s
- [ ] "Disable" button works and stops tracking
- [ ] Permission denied scenario works

### HR Dashboard ✅
- [ ] "Employee Locations" section visible at bottom
- [ ] Table shows all employees
- [ ] Table has 5 columns: Name, Role, Coordinates, Time, Status
- [ ] Status indicators show colors: 🟢 🔵 🟡 ⚪
- [ ] "Refresh" button works
- [ ] Auto-refresh works without clicking
- [ ] Times update every 30 seconds
- [ ] Multiple employees show correctly

### Admin Dashboard ✅
- [ ] "Dual Location Tracking" section visible at bottom
- [ ] Three tabs present: All Users, Field Employees, HR Staff
- [ ] All Users tab shows both tables
- [ ] Field Employees tab shows only employees
- [ ] HR Staff tab shows only HR staff
- [ ] Tab labels show counts (e.g., "Field Employees (3)")
- [ ] "Refresh" button works
- [ ] Auto-refresh works
- [ ] All statuses and times updating

---

## 🎓 Understanding What You're Testing

### What IS Working (Phase 2 ✅)
```
✅ Non-IT signup page (with company_type: 'non-it')
✅ Auth system recognizes company type
✅ Dashboards conditionally render for Non-IT
✅ Location badge UI (all features)
✅ Location tracker UI (all features)
✅ Dual tracker UI (all features)
✅ Enable/disable buttons work
✅ Status indicators work
✅ Color coding works
✅ Tab switching works
✅ Refresh buttons work
✅ Smooth animations work
```

### What's NOT Working Yet (Needs Phase 3 Backend ⏳)
```
⏳ Actual location data from browser geolocation
⏳ Sending location to backend
⏳ Retrieving live location from backend
⏳ Email verification on signup
⏳ Persisting location data
⏳ Showing real coordinates
⏳ Backend auto-refresh (only frontend simulated)
```

**Note:** The UI is 100% ready. Once Phase 3 backend is done, everything becomes fully functional.

---

## 🔍 Troubleshooting

### Location Badge Not Showing?
```
Check 1: Are you logged in as Non-IT?
→ Open console: F12 → Console
→ Type: const { isNonIT } = useAuth(); console.log(isNonIT)
→ Should show: true

Check 2: Clear cache
→ Press: Ctrl+Shift+Del
→ Clear cache and reload: Ctrl+Shift+R

Check 3: Check for errors
→ Open: F12 → Console
→ Look for red error messages
→ Take note of any errors
```

### "Permission Denied" Shows?
```
This is EXPECTED if you clicked "Block"!

To fix:
1. Click "Enable" again
2. Browser will ask again
3. Click "Allow" this time
4. Status should become "Tracking Live"

OR manually change browser permissions:
Chrome: Settings → Privacy → Site Settings → Location
Firefox: Preferences → Privacy → Permissions → Location
Safari: Develop → Allow Location
```

### Employee Locations Not Showing on HR/Admin?
```
Possible causes:
1. Employee hasn't enabled tracking yet
   → Solution: Enable tracking on employee account

2. Employee denied permission
   → Solution: Click Allow on employee location badge

3. Auto-refresh hasn't happened yet
   → Solution: Wait 30 seconds or click Refresh button

4. Only 1 employee tracking, but multiple show
   → This is fine, might be test data or other employees

Check: 
- Has employee account enabled tracking? ✓
- Did employee grant permission? ✓
- Have you waited 30+ seconds? ✓
- Does manual refresh work? ✓
```

### Nothing Updates Automatically?
```
This is expected for Phase 2!
Backend (Phase 3) will provide real auto-refresh.

For now:
✅ Manual refresh works (click Refresh button)
✅ UI updates when you click Refresh
✅ Timestamps shown are accurate
✅ Auto-refresh simulation works on employee badge

Once Phase 3 backend is live:
✅ Real auto-refresh every 30s
✅ Live coordinates from GPS
✅ Multi-user updates
```

---

## 💡 Pro Testing Tips

### Tip 1: Test Multiple Scenarios
```
1. Single employee tracking enabled
   → Only they appear on HR/Admin

2. Multiple employees tracking enabled
   → All appear with different statuses

3. Some employees with permission denied
   → They show in tables but status is "offline"

4. Test each role separately:
   → Login as employee
   → Logout and login as HR
   → Logout and login as admin
```

### Tip 2: Watch the Animations
```
When tracking enabled:
✅ Green dot pulses (every ~1 second)
✅ Last update timestamp changes every 30s
✅ Status indicator colors are correct

These visual cues confirm everything is working!
```

### Tip 3: Use Browser DevTools
```
F12 → Console to check:
- Company type: isNonIT (should be true)
- Auth state: profile data correct
- Location: navigator.geolocation working
- Errors: Any red messages in console
```

### Tip 4: Document Your Testing
```
As you test, note:
- What worked
- What didn't work
- Timestamps of tests
- Browser used
- Any error messages
- Screenshots if possible
```

---

## 📊 Expected Results

### Employee Test (Should Take ~2 minutes)
```
✅ Login: Success (user redirected to dashboard)
✅ See badge: Location badge visible
✅ Enable: Button clickable, popup appears
✅ Allow: Status shows "Tracking Live"
✅ Wait: Timestamps auto-update every 30s
✅ Disable: Button works, tracking stops
```

### HR Test (Should Take ~2 minutes)
```
✅ Login: Success (user redirected to HR dashboard)
✅ See table: Employee Locations table visible
✅ Refresh: Button works, data updates
✅ Auto-refresh: Timestamps update without clicking
✅ Multiple rows: All employees show with data
```

### Admin Test (Should Take ~2 minutes)
```
✅ Login: Success (user redirected to admin dashboard)
✅ See tabs: Three tabs visible and clickable
✅ All Users: Both tables show
✅ Filter: Tab switching works
✅ Refresh: Both buttons and auto-refresh work
✅ Data: All employees and HR visible
```

---

## 📝 Test Report Template

```markdown
# Non-IT Dashboard Test Report

**Date:** [Date]
**Tester:** [Your Name]

## Employee Dashboard Test
- Time taken: ____ minutes
- All checks passed: [ ] Yes [ ] No
- Issues found: [List any]

## HR Dashboard Test  
- Time taken: ____ minutes
- All checks passed: [ ] Yes [ ] No
- Issues found: [List any]

## Admin Dashboard Test
- Time taken: ____ minutes
- All checks passed: [ ] Yes [ ] No
- Issues found: [List any]

## Overall Result
[ ] PASS - Everything works as expected
[ ] FAIL - Issues found (see above)
[ ] PARTIAL - Some features work, some don't

## Additional Notes
[Any observations]
```

---

## 🎉 Success!

When you've completed all steps and everything works:

```
✅ Frontend Phase 2 is complete and working!
✅ Non-IT company track is ready!
✅ Location tracking UI is fully functional!
✅ All dashboards display correctly!
```

**Next Phase:** Phase 3 Backend Implementation (Location API, Email Verification, etc.)

---

## 📚 Additional Resources

For more details, see:
- **QUICK_TEST_CARD.md** - Quick 5-minute reference
- **VISUAL_TESTING_GUIDE.md** - What things should look like
- **TESTING_NON_IT_LIVE.md** - Comprehensive testing guide
- **IMPLEMENTATION_SUMMARY.md** - Architecture overview
- **NON_IT_QUICK_START.md** - Developer guide

---

**Ready to test? Start with Step 1: Create Account!** 🚀

Good luck! 🎯
