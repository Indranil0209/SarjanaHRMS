# Non-IT Company Track - Routes & Entry Points

## 🔗 Frontend Routes

### Public Routes (No Authentication Required)

```
/signup                      → Regular IT Company Signup
/signup-non-it              → Non-IT Company Signup (NEW)
/login                      → Unified Login (for both company types)
/                           → Home Page
/about                      → About Page
/contact                    → Contact Page
/careers                    → Careers Page
```

### Protected Routes (Authentication Required)

```
/dashboard                  → Main Dashboard
  ├── /dashboard/employee             → Employee Dashboard
  │   └── Location Badge (if Non-IT)
  │
  ├── /dashboard/hr                   → HR Dashboard
  │   └── Employee Locations (if Non-IT)
  │
  ├── /dashboard/admin                → Admin Dashboard
  │   └── Dual Location Tracking (if Non-IT)
  │
  ├── /dashboard/manage-attendance    → Attendance Management
  ├── /dashboard/manage-leaves        → Leave Management
  ├── /dashboard/manage-users         → User Management
  └── ... (other routes unchanged)

/verify-email               → Email Verification Page (NEW)
```

---

## 🎯 Entry Points by Company Type

### For IT Companies (Existing Flow)
```
Flow: Signup (/signup)
      ↓
      Login (/login, company_type = 'it')
      ↓
      Dashboard (/dashboard/employee)
      ↓
      Standard dashboards (no location features)
```

### For Non-IT Companies (New Flow)
```
Flow: Signup (/signup-non-it)
      ↓
      Email Verification (/verify-email)
      ↓
      Login (/login, company_type = 'non-it')
      ↓
      Dashboard (/dashboard/employee)
      ↓
      Dashboards with location features
```

---

## 🔐 Authentication Flow with Company Type

### Current Login Endpoint (Existing)
```javascript
// src/pages/Login.tsx
POST /login
{
  email: "user@company.com",
  password: "password"
}

Returns:
{
  user: { id, email, ... },
  profile: { id, email, company_id, company_type }
}
```

### Non-IT Signup Endpoint (New)
```javascript
// src/pages/SignupNonIT.tsx
POST /signup
{
  email: "user@company.com",
  password: "password",
  full_name: "John Doe",
  company_name: "Field Company Ltd",
  company_type: "non-it"  // ← Explicit flag
}

Returns:
{
  user: { id, email, ... },
  profile: { id, email, company_type: "non-it" }
}
```

---

## 🏃 Runtime Route Selection

### In AuthContext (Authentication Layer)
```javascript
// After login, context determines company type
const { companyType } = useAuth()

// useAuth() now provides:
export value = {
  user,
  profile,
  companyType,        // 'it' or 'non-it'
  isNonIT,             // boolean
  isIT,                // boolean
  signUp,
  signIn,
  signOut,
  ...
}
```

### In Dashboard Components
```javascript
// Dashboards receive company type flag
const { isNonIT } = useAuth()

// Use to conditionally render features
{isNonIT && (
  <LocationTrackingComponent />
)}

{isNonIT && (
  <EmployeeLocationTracker />
)}

{isNonIT && (
  <DualLocationTracker />
)}
```

---

## 🎭 Role-Based Routes (Non-IT Companies)

### Non-IT Employee Routes
```
/dashboard/employee
├── Location Badge (show/hide tracking)
├── Attendance Clock In/Out
├── Leave Requests
├── Task Management
└── Payroll Info
```

### Non-IT HR Manager Routes
```
/dashboard/hr
├── Employee Location Tracker (NEW)
├── Manage Attendance
├── Manage Users
├── Pending Approvals
├── Manage Leaves
└── Process Payroll
```

### Non-IT Company Admin Routes
```
/dashboard/admin
├── Dual Location Tracking (NEW)
│   ├── Field Employees View
│   ├── HR Staff View
│   └── All Users View
├── System Administration
├── User Management
├── Security & Monitoring
└── Analytics & Reports
```

---

## 🌍 Location Tracking Routes (Backend - Phase 3)

### Location API Endpoints (To Be Implemented)
```
POST /api/locations
  → Send location update
  ├── Body: { latitude, longitude, accuracy, timestamp }
  └── Auth: Required (user token)

GET /api/locations/user/:id
  → Get user's current location
  ├── Params: user ID
  └── Auth: Required (user or HR/admin)

GET /api/locations/history/:id
  → Get location history
  ├── Params: user ID, date range
  └── Auth: Required (user or HR/admin)

GET /api/locations/company/:id
  → Get all company locations
  ├── Params: company ID
  └── Auth: Required (admin only)

PUT /api/locations/tracking/:id
  → Enable/disable tracking
  ├── Body: { enabled: boolean }
  └── Auth: Required (user)
```

---

## 📡 Component Route Structure

### EmployeeDashboard Component Routes
```
EmployeeDashboard
├── Rendered at: /dashboard/employee
├── Query Params: None
├── Props: From useAuth() & routing context
├── Conditional Sections:
│   ├── Location Badge (if isNonIT)
│   └── Location Tracking Hook
└── State: Uses useLocationTracking hook
```

### HRDashboard Component Routes
```
HRDashboard
├── Rendered at: /dashboard/hr
├── Query Params: None
├── Props: From useAuth() & routing context
├── Conditional Sections:
│   ├── Employee Location Tracker (if isNonIT)
│   └── Uses EmployeeLocationTracker component
└── Props Passed: companyId, filter="employee"
```

### AdminDashboard Component Routes
```
AdminDashboard
├── Rendered at: /dashboard/admin
├── Query Params: None
├── Props: From useAuth() & routing context
├── Conditional Sections:
│   ├── Dual Location Tracker (if isNonIT)
│   └── Uses DualLocationTracker component
└── Props Passed: companyId
```

---

## 🧭 Navigation Flow Diagrams

### IT Company User Journey
```
START
  ↓
[Home Page]
  ↓
[Choose Signup/Login]
  ↓
[Standard Signup] ──→ [Login] ──→ [Dashboard]
                                    ├── Employee Features
                                    ├── Payroll
                                    ├── Attendance
                                    └── (NO Location Tracking)
```

### Non-IT Company User Journey
```
START
  ↓
[Home Page]
  ↓
[Choose Signup/Login]
  ↓
[Non-IT Signup] ──→ [Verify Email] ──→ [Login]
    (company_type:       (Required)         │
     "non-it")                              ↓
                                      [Dashboard]
                                      ├── Employee Features
                                      ├── Payroll
                                      ├── Attendance
                                      └── + Location Tracking
```

---

## 🔀 Conditional Route Rendering

### useAuth Hook Provides Company Type

```javascript
// In any component
const { isNonIT, isIT, companyType } = useAuth()

// Example conditional routes
switch(companyType) {
  case 'non-it':
    // Show Non-IT dashboard features
    return <NonITDashboard />
  
  case 'it':
    // Show IT dashboard features
    return <StandardDashboard />
  
  default:
    // Fallback
    return <DefaultDashboard />
}
```

### URL Remains Unchanged

```
Both IT and Non-IT users go to:
  /dashboard

But different content renders based on:
  const { isNonIT } = useAuth()

This is cleaner than:
  /dashboard/it
  /dashboard/non-it
```

---

## 📍 Deep Link Examples

### Employee Non-IT Dashboard
```
URL: http://localhost:8000/dashboard/employee

Browser shows:
  ✓ Employee Dashboard
  ✓ Location Badge
  ✓ All standard employee features
  ✓ Location Tracking enabled
```

### HR Non-IT Dashboard
```
URL: http://localhost:8000/dashboard/hr

Browser shows:
  ✓ HR Dashboard
  ✓ Employee Location Tracker Table
  ✓ All standard HR features
  ✓ Real-time location updates
```

### Admin Non-IT Dashboard
```
URL: http://localhost:8000/dashboard/admin

Browser shows:
  ✓ Admin Dashboard
  ✓ Dual Location Tracking Panel
  ✓ All standard admin features
  ✓ Company-wide location monitoring
```

---

## 🔍 URL Query Parameters (For Future Use)

### Location Tracking Parameters (Phase 3+)
```
/dashboard/hr?view=locations&role=employee&range=today
  view: 'locations' | 'analytics' | 'standard'
  role: 'employee' | 'hr' | 'all'
  range: 'today' | 'week' | 'month' | 'custom'

/dashboard/admin?tracking=dual&tab=employees&refresh=30
  tracking: 'dual' | 'employees' | 'hr'
  tab: 'all' | 'employees' | 'hr'
  refresh: auto-refresh interval in seconds
```

---

## 🛣️ Routing Configuration (React Router)

### Current Setup (To Be Updated)
```javascript
// In App.tsx or main routing file
<Routes>
  <Route path="/signup" element={<Signup />} />
  <Route path="/signup-non-it" element={<SignupNonIT />} />  {/* NEW */}
  <Route path="/login" element={<Login />} />
  
  <Route path="/dashboard" element={<ProtectedRoute><Dashboard /></ProtectedRoute>}>
    <Route path="employee" element={<EmployeeDashboard />} />
    <Route path="hr" element={<HRDashboard />} />
    <Route path="admin" element={<AdminDashboard />} />
    {/* ... other routes */}
  </Route>
</Routes>
```

---

## 🎫 Protected Route Implementation

### Example: ProtectedRoute Component
```javascript
function ProtectedRoute({ children }) {
  const { user, profile, loading } = useAuth()
  
  if (loading) return <LoadingSpinner />
  
  if (!user || !profile) {
    return <Navigate to="/login" replace />
  }
  
  // Route renders with company_type available via useAuth()
  return children
}

// Usage:
<Route 
  path="/dashboard" 
  element={
    <ProtectedRoute>
      <Dashboard />
    </ProtectedRoute>
  } 
/>
```

---

## 🔐 Access Control by Role

### Non-IT Employee
```
Can Access:
  ✓ /dashboard/employee
  ✗ /dashboard/hr (no access)
  ✗ /dashboard/admin (no access)

Features Visible:
  ✓ Location Badge
  ✓ Enable/Disable Tracking
  ✓ Standard features
```

### Non-IT HR Manager
```
Can Access:
  ✓ /dashboard/employee (own profile)
  ✓ /dashboard/hr
  ✗ /dashboard/admin (no access)

Features Visible:
  ✓ Employee Location Tracker
  ✓ HR Management Features
  ✓ Standard features
```

### Non-IT Admin
```
Can Access:
  ✓ /dashboard/employee (own profile)
  ✓ /dashboard/hr
  ✓ /dashboard/admin

Features Visible:
  ✓ Dual Location Tracker
  ✓ System Administration
  ✓ All features
```

---

## 📊 Route Statistics

### Total Routes
```
Public Routes: 6
  - Home, About, Contact, Careers
  - Signup (IT)
  - Signup (Non-IT) ← NEW

Protected Routes: 10+
  - Dashboard (main)
  - Employee Dashboard + Location (Non-IT)
  - HR Dashboard + Tracking (Non-IT)
  - Admin Dashboard + Dual Tracking (Non-IT)
  - Attendance, Leaves, Payroll, etc.
  - Email Verification ← NEW

API Routes (Backend - Phase 3): 5+
  - Location endpoints
  - Verification endpoints
  - Tracking control endpoints
```

---

## ✅ Route Testing Checklist

### Manual Testing
- [ ] /signup → IT company signup works
- [ ] /signup-non-it → Non-IT company signup works
- [ ] /login → Can login with both company types
- [ ] /dashboard → Routes to correct dashboard
- [ ] /dashboard/employee → Employee features show, Location badge shows for Non-IT
- [ ] /dashboard/hr → HR features show, Location tracker shows for Non-IT
- [ ] /dashboard/admin → Admin features show, Dual tracker shows for Non-IT

### Integration Testing (Phase 3)
- [ ] Location updates route correctly
- [ ] Email verification routes work
- [ ] Authentication errors route to login
- [ ] Unauthorized access denied
- [ ] Deep links work properly

---

## 🚀 Route Deployment Notes

### No Route Changes Required
```
✓ Existing routes unchanged
✓ Only added /signup-non-it
✓ Conditional rendering handles rest
✓ Backward compatible
✓ No URL structure changes
```

### Backend Routes (Phase 3)
```
Must implement:
  POST /api/locations
  GET /api/locations/user/:id
  GET /api/locations/history/:id
  GET /api/locations/company/:id
  PUT /api/locations/tracking/:id
  POST /verify-email
  GET /verify-email/:token
```

---

**Status:** ✅ Frontend Routing Complete  
**Next:** Phase 3 Backend API Routes  
**Last Updated:** July 16, 2026
