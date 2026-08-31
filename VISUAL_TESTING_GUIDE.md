# 👀 Visual Testing Guide - Non-IT Dashboard & Location Tracking

## 🎨 What You'll See on Screen

### STEP 1: Login Page
```
┌─────────────────────────────────────────────────────┐
│                   SIGN IN                           │
│                                                     │
│  Email: [_____________________]                    │
│  Password: [_____________________]                 │
│                                                     │
│  [Sign In Button]                                   │
│                                                     │
│  Demo Credentials:                                  │
│  ✓ Super Admin: giwore2911@dolofan.com             │
│  ✓ HR Manager: hef8q@dollicons.com                 │
│  ✓ Employee: zds0i@dollicons.com                   │
│                                                     │
│  [Continue with Google] [Continue with LinkedIn]   │
│                                                     │
│  Create Account? → [Sign Up]                       │
└─────────────────────────────────────────────────────┘
```

**Action:** Enter Non-IT test credentials and click Sign In

---

### STEP 2: Employee Dashboard (Non-IT) - Location Badge

```
┌─────────────────────────────────────────────────────┐
│ Welcome, Test Employee                  [Status ▼]  │
│                                                     │
│ Time: 14:32:45                                      │
│ Monday, July 16, 2026                               │
│                                                     │
├─────────────────────────────────────────────────────┤
│              KEY METRICS                            │
├─────────────────────────────────────────────────────┤
│                                                     │
│  ┌──────────┐  ┌──────────┐  ┌──────────┐         │
│  │ 92%      │  │ 17 days  │  │ 3 tasks  │         │
│  │Attendance│  │ Leave    │  │ Pending  │         │
│  └──────────┘  └──────────┘  └──────────┘         │
│                                                     │
├─────────────────────────────────────────────────────┤
│      📍 LOCATION TRACKING (NEW - Non-IT Only)      │
├─────────────────────────────────────────────────────┤
│                                                     │
│  ┌─────────────────────────────────────────┐       │
│  │ 📍 Location Tracking                    │       │
│  │                                          │       │
│  │ 🟢 Tracking Live  (pulsing animation)  │       │
│  │                                          │       │
│  │ Last update: 5s ago                     │       │
│  │                                          │       │
│  │ [Disable] button (red)                  │       │
│  └─────────────────────────────────────────┘       │
│                                                     │
├─────────────────────────────────────────────────────┤
│              CHARTS SECTION                         │
├─────────────────────────────────────────────────────┤
│  (Charts unchanged - same as IT company)            │
│                                                     │
└─────────────────────────────────────────────────────┘
```

**What to look for:**
- ✅ Location Tracking section appears between Key Metrics and Charts
- ✅ Status shows "Tracking Live" with green pulsing dot
- ✅ "Last update" timestamp displays
- ✅ "Disable" button visible

**Action:** Click "Disable" to see it change to "Enable"

---

### STEP 2B: Employee Dashboard - Permission Denied State

```
┌─────────────────────────────────────────────────────┐
│ Welcome, Test Employee                              │
│                                                     │
│      📍 LOCATION TRACKING (NEW - Non-IT Only)      │
├─────────────────────────────────────────────────────┤
│                                                     │
│  ┌─────────────────────────────────────────┐       │
│  │ 📍 Location Tracking                    │       │
│  │                                          │       │
│  │ ⚠️ Permission Denied (orange/grey dot)  │       │
│  │                                          │       │
│  │ ❌ Error: Location permission denied    │       │
│  │                                          │       │
│  │ Last update: Never                      │       │
│  │                                          │       │
│  │ [Enable] button (green) - Retry option │       │
│  └─────────────────────────────────────────┘       │
│                                                     │
└─────────────────────────────────────────────────────┘
```

**What to look for:**
- ✅ Status shows "Permission Denied"
- ✅ Red error box with explanation
- ✅ Grey/orange status dot
- ✅ "Enable" button available to retry

---

### STEP 3: HR Dashboard - Employee Locations Tracker

```
┌─────────────────────────────────────────────────────┐
│ HR Dashboard                        [Refresh] [Status]
│                                                     │
│ [Standard HR sections - unchanged]                 │
│                                                     │
├─────────────────────────────────────────────────────┤
│      👥 EMPLOYEE LOCATIONS (NEW - Non-IT Only)     │
│                          [Refresh ↻] [Auto-refresh] │
├─────────────────────────────────────────────────────┤
│                                                     │
│  Table showing employees:                          │
│  ┌─────────────────────────────────────────────┐   │
│  │ Employee │ Role    │ Coordinates    │ Time  │Status│
│  ├─────────────────────────────────────────────┤   │
│  │ Test Emp │Employee │40.7128, -74.01│ 5m ago│🟢   │
│  │ John Doe │Employee │40.7200, -74.02│12m ago│🔵   │
│  │ Jane Smith│Employee │Offline        │2h ago │⚪   │
│  └─────────────────────────────────────────────┘   │
│                                                     │
│  Status Indicators:                                │
│  🟢 Live (< 5 min)      🔵 Recent (5-30 min)      │
│  🟡 Idle (30-120 min)   ⚪ Offline (> 120 min)     │
│                                                     │
└─────────────────────────────────────────────────────┘
```

**What to look for:**
- ✅ "Employee Locations" section at bottom of HR dashboard
- ✅ Table with columns: Employee, Role, Coordinates, Time, Status
- ✅ Color-coded status indicators (green, blue, yellow, grey)
- ✅ Last update times showing
- ✅ "Refresh" button and auto-refresh info
- ✅ Coordinates displayed (lat, lon)

**Action:** Click "Refresh" button to manually update

---

### STEP 4: Admin Dashboard - Dual Location Tracking

```
┌─────────────────────────────────────────────────────┐
│ Admin Dashboard                     [Refresh] [Status]
│                                                     │
│ [Standard admin sections - unchanged]              │
│                                                     │
├─────────────────────────────────────────────────────┤
│   👁️  DUAL LOCATION TRACKING (NEW - Non-IT Only)   │
│                          [Refresh ↻] Auto-refresh   │
├─────────────────────────────────────────────────────┤
│                                                     │
│  Tabs: [All Users] │ [Field Employees] │ [HR Staff]│
│                                                     │
│  ┌───────────────────────────────────────────────┐ │
│  │ FIELD EMPLOYEES (3)                           │ │
│  ├───────────────────────────────────────────────┤ │
│  │ Employee │ Coordinates    │ Last Seen │Status │ │
│  ├───────────────────────────────────────────────┤ │
│  │Test Emp  │40.7128,-74.010│ 5m ago   │🟢 live│ │
│  │John Doe  │40.7200,-74.015│10m ago   │🔵 rec │ │
│  │Jane Smith│Offline        │ 2h ago   │⚪ off │ │
│  └───────────────────────────────────────────────┘ │
│                                                     │
│  ┌───────────────────────────────────────────────┐ │
│  │ HR STAFF (2)                                  │ │
│  ├───────────────────────────────────────────────┤ │
│  │ HR Manager│40.7150,-74.005│ 3m ago   │🟢 live│ │
│  │ HR Admin  │40.7180,-74.020│ 8m ago   │🔵 rec │ │
│  └───────────────────────────────────────────────┘ │
│                                                     │
│  Status Indicators:                                │
│  🟢 Live    🔵 Recent   🟡 Idle    ⚪ Offline     │
│                                                     │
└─────────────────────────────────────────────────────┘
```

**What to look for:**
- ✅ "Dual Location Tracking" section at bottom of admin dashboard
- ✅ Three tabs visible: All Users, Field Employees, HR Staff
- ✅ Two separate tables (Field Employees, HR Staff)
- ✅ Each table shows: Name, Coordinates, Last Seen, Status
- ✅ Color-coded status indicators
- ✅ Employee/HR counts in tab labels
- ✅ "Refresh" button and auto-refresh indicator

**Action:** Click each tab to filter the view

---

### STEP 5: Tab Switching in Admin Dashboard

```
When you click "Field Employees" tab:
┌──────────────────────────────────────────────────┐
│ Tabs: [All Users] │ [Field Employees] │ HR Staff │
│                                                  │
│ Only Field Employees table shows:               │
│ ┌────────────────────────────────────────────┐  │
│ │ Employee │ Coordinates    │ Last │ Status  │  │
│ ├────────────────────────────────────────────┤  │
│ │Test Emp  │40.7128,-74.010│ 5m   │🟢 live  │  │
│ │John Doe  │40.7200,-74.015│10m   │🔵 rec   │  │
│ │Jane Smith│Offline        │ 2h   │⚪ off   │  │
│ └────────────────────────────────────────────┘  │
│                                                  │
│ (HR Staff table hidden until clicked)           │
└──────────────────────────────────────────────────┘

When you click "HR Staff" tab:
┌──────────────────────────────────────────────────┐
│ Tabs: [All Users] │ Field Employees │ [HR Staff] │
│                                                  │
│ Only HR Staff table shows:                      │
│ ┌────────────────────────────────────────────┐  │
│ │ HR Name  │ Coordinates    │ Last │ Status  │  │
│ ├────────────────────────────────────────────┤  │
│ │HR Manager│40.7150,-74.005│ 3m   │🟢 live  │  │
│ │HR Admin  │40.7180,-74.020│ 8m   │🔵 rec   │  │
│ └────────────────────────────────────────────┘  │
│                                                  │
│ (Employees table hidden until clicked)          │
└──────────────────────────────────────────────────┘

When you click "All Users" tab:
┌──────────────────────────────────────────────────┐
│ Tabs: [All Users] │ Field Employees │ HR Staff   │
│                                                  │
│ Both tables show side-by-side:                  │
│ ┌────────────────────────────────────────────┐  │
│ │ Field Employees (3) Section                │  │
│ │ [table with 3 rows]                        │  │
│ └────────────────────────────────────────────┘  │
│                                                  │
│ ┌────────────────────────────────────────────┐  │
│ │ HR Staff (2) Section                       │  │
│ │ [table with 2 rows]                        │  │
│ └────────────────────────────────────────────┘  │
└──────────────────────────────────────────────────┘
```

---

## 🎬 Animation & Updates

### Location Badge Status Indicators

```
State 1: Tracking Disabled
┌────────────────────────────┐
│ 🔵 Tracking Disabled       │  (blue/grey dot, no pulse)
│ Last update: Never         │
│ [Enable] button            │
└────────────────────────────┘

State 2: Tracking Live (starts)
┌────────────────────────────┐
│ 🟢 Tracking Live           │  (green dot, pulses once/sec)
│ Last update: 0s ago        │
│ [Disable] button           │
└────────────────────────────┘

State 3: Tracking Live (after 30s)
┌────────────────────────────┐
│ 🟢 Tracking Live           │  (green dot, still pulsing)
│ Last update: 30s ago       │  ← AUTO-UPDATED
│ [Disable] button           │
└────────────────────────────┘

State 4: Permission Denied
┌────────────────────────────┐
│ ⚠️ Permission Denied        │  (yellow/grey dot, no pulse)
│ ❌ Error: Location         │
│    permission denied       │
│ Last update: Never         │
│ [Enable] button (retry)    │
└────────────────────────────┘
```

### Status Indicator Colors

```
On the HR/Admin location tables:

🟢 Live Status (< 5 minutes)
   └─ Green dot with animation
   └─ "live" text next to dot

🔵 Recent Status (5-30 minutes)
   └─ Blue dot (no animation)
   └─ "recent" text next to dot

🟡 Idle Status (30-120 minutes)
   └─ Yellow dot (no animation)
   └─ "idle" text next to dot

⚪ Offline Status (> 120 minutes)
   └─ Grey dot (no animation)
   └─ "offline" text next to dot
```

---

## ⚡ Real-Time Updates (Every 30 Seconds)

```
Timeline of what you'll see:

Time 0:00
├─ Employee Dashboard Location Badge
│  └─ Status: Tracking Live
│  └─ Last update: 0s ago
│
├─ HR Dashboard Employee Table
│  └─ Status: 🟢 live
│  └─ Last Seen: 30s ago (initial)
│
└─ Admin Dashboard
   └─ Status: 🟢 live
   └─ Last Seen: 30s ago (initial)


Time 0:30
├─ Employee Dashboard Location Badge
│  └─ (Auto-updated from browser geolocation)
│  └─ Last update: 30s ago ← CHANGED
│
├─ HR Dashboard Employee Table
│  └─ (Auto-refreshed from backend)
│  └─ Last Seen: 60s ago ← CHANGED
│  └─ Status may change: 🟢 live → 🔵 recent
│
└─ Admin Dashboard
   └─ (Auto-refreshed from backend)
   └─ Last Seen: 60s ago ← CHANGED


Time 1:00
├─ Employee Dashboard Location Badge
│  └─ Last update: 1m ago ← CHANGED
│
├─ HR Dashboard
│  └─ Last Seen: 1m 30s ago ← CHANGED
│
└─ Admin Dashboard
   └─ Last Seen: 1m 30s ago ← CHANGED
```

---

## 🔘 Button States & Actions

### Location Badge Buttons

```
DISABLED State (Tracking Disabled):
┌─────────────┐
│   Enable    │  Green background
│             │  Clickable
│             │  Hover: darker green
└─────────────┘

ENABLED State (Tracking Active):
┌─────────────┐
│   Disable   │  Red background
│             │  Clickable
│             │  Hover: darker red
└─────────────┘
```

### Refresh Buttons

```
READY State:
┌─────────────┐
│ ↻ Refresh   │  Blue background
│             │  Clickable
│             │  Shows "Refresh"
└─────────────┘

LOADING State (while refreshing):
┌─────────────┐
│ ↻ Refreshing│  Blue background
│             │  Not clickable
│             │  Spinner animation on ↻
└─────────────┘

DONE State:
┌─────────────┐
│ ↻ Refresh   │  Back to normal
│             │  Clickable again
│             │  Latest data shown
└─────────────┘
```

---

## 📊 Table Examples

### Employee Locations Table (HR View)

```
Complete Example with Real Data:

┌─────────────────────────────────────────────────────────────────┐
│ 👥 Employee Locations (3)                        [Refresh ↻]    │
├─────────────────────────────────────────────────────────────────┤
│                                                                 │
│ ┌───────────────────────────────────────────────────────────┐  │
│ │ Employee    │ Role     │ Location          │ Time   │Status│  │
│ ├───────────────────────────────────────────────────────────┤  │
│ │ John Smith  │ Employee │ 40.7128, -74.0060 │ 2m ago │ 🟢  │  │
│ │ Jane Wilson │ Employee │ 40.7282, -74.0076 │ 8m ago │ 🔵  │  │
│ │ Mike Brown  │ Employee │ Offline           │ 1h ago │ ⚪  │  │
│ │ Sarah Jones │ Employee │ 40.7100, -73.9950 │12m ago │ 🟡  │  │
│ └───────────────────────────────────────────────────────────┘  │
│                                                                 │
│ Legend:                                                         │
│ 🟢 live (< 5 min)  |  🔵 recent (5-30 min)  |  🟡 idle (30-120 min)  |  ⚪ offline (> 120 min)
│                                                                 │
└─────────────────────────────────────────────────────────────────┘
```

---

## 🎯 Key Visual Elements Summary

| Element | What It Looks Like | What It Means |
|---------|-------------------|--------------|
| 🟢 Green dot (pulsing) | Animated green circle | Employee tracking live |
| 🔵 Blue dot | Static blue circle | Employee tracked recently |
| 🟡 Yellow dot | Static yellow circle | Employee idle for 30+ min |
| ⚪ Grey dot | Static grey circle | Employee offline > 2 hours |
| "Tracking Live" | Green status text | Currently sending location |
| "Tracking Disabled" | Grey status text | Not tracking |
| "Permission Denied" | Orange/red warning | Browser permission needed |
| Last update: 30s ago | Timestamp | When location was last updated |
| [Refresh ↻] | Blue button | Click to manually refresh |
| Auto-refresh indicator | Info text | Shows it's auto-updating |

---

## ✅ Success Indicators

When everything is working correctly, you'll see:

**On Employee Dashboard:**
```
✓ Location badge visible
✓ Green pulsing dot when enabled
✓ Grey dot when disabled
✓ Timestamps updating every 30s
✓ Last update changing (0s, 30s, 1m, etc)
```

**On HR Dashboard:**
```
✓ Employee locations table present
✓ Multiple employees listed
✓ Colored status dots
✓ Coordinates showing
✓ Times updating every 30s
✓ Statuses: 🟢 🔵 🟡 ⚪
```

**On Admin Dashboard:**
```
✓ Dual tracking section visible
✓ Three functional tabs
✓ Separate Employee/HR tables
✓ Counts showing in tabs
✓ All employees and HR staff listed
✓ Times and statuses updating
```

---

**Ready to see it in action? Start with Step 1: Login Page!** 👆
