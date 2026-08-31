# ⚡ Quick Test Card - Non-IT Dashboard in 5 Minutes

## 🚀 Start Testing Right Now

### URL to Test
```
http://localhost:8000/signup-non-it
OR
http://localhost:8000/login
```

---

## 📝 Quick Signup

**Go to:** http://localhost:8000/signup-non-it

```
Full Name:        Test User
Company Name:     Test Field Company
Email:            test-nit@company.com
Password:         TestPass123!
Confirm Password: TestPass123!
✓ Accept Terms

Click "Create Account"
```

---

## 🔑 Or Use Direct Login

**Go to:** http://localhost:8000/login

```
Email:    emp-nit@company.com
Password: TestPass123!

Click "Sign In"
```

*Note: You may need to create these accounts in database first (see TESTING_NON_IT_LIVE.md)*

---

## 👀 What to Look For (Employee)

### ✅ Check for Location Badge
```
After login → Go to /dashboard/employee

Scroll down to find:
"📍 Location Tracking" section

Below "Key Metrics" section
Before "Charts" section
```

### ✅ Test Enable Button
```
1. See: "🔯 Tracking Disabled"
2. Click: "Enable" button
3. Allow: Browser permission popup
4. See: "🟢 Tracking Live" (with green pulse)
5. See: "Last update: 5s ago" (auto-updates)
```

### ✅ Test Disable Button
```
1. Click: "Disable" button
2. See: "🔯 Tracking Disabled" again
3. See: Button changes to "Enable"
```

---

## 👔 HR Manager View (Employee)

### ✅ Check for Employee Locations Table
```
After login as HR → Go to /dashboard/hr

Scroll down to find:
"👥 Employee Locations" section

Shows table with:
- Employee names
- Role
- Coordinates (lat, lon)
- Last update time
- Status indicators (🟢 🔵 🟡 ⚪)
```

### ✅ Test Refresh Button
```
1. See: "Refresh" button
2. Click: "Refresh"
3. Table: Updates immediately
4. Wait: 30 seconds
5. See: Auto-refresh happens
```

---

## 🏢 Admin View (Company)

### ✅ Check for Dual Location Tracker
```
After login as Admin → Go to /dashboard/admin

Scroll down to find:
"👁️ Dual Location Tracking" section

See three tabs:
- [All Users]
- [Field Employees]
- [HR Staff]
```

### ✅ Test Tab Switching
```
1. Click: "Field Employees" tab
   → Shows only employees

2. Click: "HR Staff" tab
   → Shows only HR staff

3. Click: "All Users" tab
   → Shows both tables
```

### ✅ Test Table Updates
```
1. Wait: 30 seconds
2. See: "Last Seen" times update
3. See: Statuses may change (🟢→🔵→🟡→⚪)
4. Click: "Refresh" button
5. See: Immediate update
```

---

## 🎨 Visual Checklist

### Employee Dashboard
- [ ] Location badge appears
- [ ] Status shows "Tracking Disabled" initially
- [ ] Enable button is green
- [ ] After Enable: Status shows "Tracking Live"
- [ ] Green dot is visible and pulsing
- [ ] Last update shows time
- [ ] After wait: Time updates to "30s ago", "1m ago", etc.
- [ ] Disable button is red
- [ ] After Disable: Back to "Tracking Disabled"

### HR Dashboard
- [ ] Location section appears
- [ ] Table has columns: Employee, Role, Coordinates, Time, Status
- [ ] Employee names show
- [ ] Coordinates display (numbers)
- [ ] Last update times show
- [ ] Status indicators visible (colored dots)
- [ ] Refresh button exists
- [ ] After clicking refresh: Updates immediately
- [ ] After 30 seconds: Auto-refresh happens

### Admin Dashboard
- [ ] Dual tracking section appears
- [ ] Three tabs visible
- [ ] "All Users" tab selected by default
- [ ] Two tables show (Field Employees, HR Staff)
- [ ] Tab counts show (e.g., "All Users (5)")
- [ ] Clicking tabs filters the view
- [ ] Each table has same columns as HR
- [ ] Refresh button works
- [ ] Auto-refresh works

---

## 🔧 Troubleshooting Quick Fix

### Location Badge Not Showing?
```
1. Check: Are you logged in as Non-IT?
   → Open browser console: F12 → Console
   → Type: const { isNonIT } = useAuth(); console.log(isNonIT)
   → Should show: true

2. Clear cache: Ctrl+Shift+Del
3. Reload: Ctrl+Shift+R
4. Check console for red errors: F12 → Console
```

### Permission Denied Error?
```
This is EXPECTED if you click "Block"!

To fix:
1. Click "Enable" again
2. Click "Allow" this time
3. Status should show "Tracking Live"
```

### Table Not Showing Locations?
```
1. Go back to employee account
2. Enable tracking on location badge
3. Wait 30 seconds
4. Go back to HR/Admin account
5. Click "Refresh" button
6. Employees should appear
```

### Auto-refresh Not Working?
```
1. Check internet connection
2. Check backend is running
3. Wait 30 seconds
4. Manually click "Refresh" button
5. Should update immediately
```

---

## 📊 Status Indicators Meaning

```
🟢 Live      = Updated in last 5 minutes (actively tracking)
🔵 Recent    = Updated 5-30 minutes ago (recently tracked)
🟡 Idle      = Updated 30-120 minutes ago (hasn't moved recently)
⚪ Offline   = Updated > 120 minutes ago (not tracking)
```

---

## ⏱️ Timeline

```
Time 0:00    → Click Enable → Status: Tracking Live, Last: 0s
Time 0:30    → Auto-update  → Last: 30s ago
Time 1:00    → Auto-update  → Last: 1m ago
Time 1:30    → Auto-update  → Last: 1m 30s ago
Time 5:00    → Status changes from 🟢 live to 🔵 recent
Time 10:00   → Status changes from 🔵 recent to 🟡 idle
```

---

## 🎯 Success Criteria

**You'll know it's working when:**

✅ Employee can enable/disable tracking  
✅ Badge shows correct status  
✅ Last update timestamp changes  
✅ HR sees employee locations in table  
✅ Admin sees employees and HR in dual view  
✅ Tab switching works on admin dashboard  
✅ Refresh buttons update data  
✅ Auto-refresh works every 30 seconds  
✅ Status indicators update correctly  

---

## 📞 Next Steps

If everything works:
```
✓ Frontend Phase 2 is complete!
✓ Your Non-IT dashboard is working!
```

If something doesn't work:
```
→ Check TESTING_NON_IT_LIVE.md for detailed troubleshooting
→ Check VISUAL_TESTING_GUIDE.md for what things should look like
→ Check browser console: F12 → Console
```

---

## 🚀 What's NOT Working Yet (Normal)

```
❌ Exact coordinates (will be demo data)
   → Phase 3: Backend will provide real locations

❌ Email verification on signup
   → Phase 3: Email system implementation

❌ Locations don't persist after refresh
   → Phase 3: Backend storage needed

❌ Real tracking across browser restarts
   → Phase 3: Server will track updates

But the UI is 100% there! ✅
```

---

**Happy Testing!** 🎉

*For detailed guide: See TESTING_NON_IT_LIVE.md*  
*For visual reference: See VISUAL_TESTING_GUIDE.md*  
*For architecture: See IMPLEMENTATION_SUMMARY.md*
