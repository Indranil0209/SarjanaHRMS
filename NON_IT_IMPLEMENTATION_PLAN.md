# Non-IT Company Track Implementation Plan

## Overview
This document outlines the complete implementation strategy for adding Non-IT Company support with Live Location Tracking to the existing HRMS system.

## Phase 1: Database & Backend Foundation

### 1.1 Database Schema Updates

#### Update Companies Table
```sql
ALTER TABLE companies ADD COLUMN company_type ENUM('it', 'non-it') DEFAULT 'it';
ALTER TABLE companies ADD COLUMN is_verified BOOLEAN DEFAULT FALSE;
ALTER TABLE companies ADD COLUMN email_verification_token VARCHAR(255) UNIQUE;
ALTER TABLE companies ADD COLUMN email_verified_at TIMESTAMP;
```

#### Create Location Logs Table
```sql
CREATE TABLE location_logs (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  role VARCHAR(50) NOT NULL, -- 'employee', 'hr_manager', 'admin'
  latitude DECIMAL(10, 8) NOT NULL,
  longitude DECIMAL(11, 8) NOT NULL,
  accuracy DECIMAL(10, 2), -- GPS accuracy in meters
  timestamp TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
  INDEX idx_user_timestamp (user_id, timestamp),
  INDEX idx_timestamp (timestamp)
);
```

#### Update Users Table
```sql
ALTER TABLE users ADD COLUMN company_type VARCHAR(50) DEFAULT 'it';
ALTER TABLE users ADD COLUMN location_tracking_enabled BOOLEAN DEFAULT FALSE;
ALTER TABLE users ADD COLUMN last_location_ping TIMESTAMP;
```

### 1.2 Email Verification System

Create email verification workflow:
- Generate unique token on registration
- Send verification email
- Set `is_verified = FALSE` for company
- Block login until verified
- Cleanup expired tokens after 24 hours

---

## Phase 2: Registration & Unified Login Routing

### 2.1 Non-IT Signup Page
- **Path:** `src/pages/SignupNonIT.jsx`
- Company type explicitly set to `'non-it'`
- Post-signup shows pending verification message
- Existing IT signup remains unchanged

### 2.2 Unified Login Logic
- **Path:** `src/pages/Login.tsx` (update existing)
- After authentication, check `company_type` field
- Route based on company type:
  - `'it'` → Standard dashboard
  - `'non-it'` → Dashboard with location tracking

---

## Phase 3: Conditional Dashboard Implementations

### 3.1 Employee Dashboard (Non-IT Mode)
- **File:** `src/components/dashboard/EmployeeDashboard.jsx`
- Add geolocation service hook
- Display tracking status badge
- Send periodic location updates to backend

### 3.2 HR Dashboard (Non-IT Mode)
- **File:** `src/components/dashboard/HRDashboard.jsx`
- Add Employee Live Location Tracking panel
- Display map view or location log table
- Show employee real-time status

### 3.3 Company Dashboard (Non-IT Mode)
- **File:** `src/components/dashboard/AdminDashboard.jsx`
- Add Dual Live Location Tracking interface
- View both Field Employees and HR staff locations
- Master admin control panel

---

## Phase 4: Location Tracking Service

### 4.1 Geolocation Hook
- `src/hooks/useGeolocation.js`
- Request browser permissions
- Handle permission denied gracefully
- Periodic location updates (every 30 seconds for field employees)

### 4.2 Location Update Service
- `src/services/locationService.js`
- Send location to backend API
- Handle network failures
- Retry mechanism

### 4.3 Location Display Components
- `src/components/tracking/EmployeeLocationBadge.jsx`
- `src/components/tracking/LiveLocationMap.jsx`
- `src/components/tracking/LocationLogTable.jsx`

---

## Implementation Strategy

### DRY Principle (Don't Repeat Yourself)
- No separate dashboard files for Non-IT
- Use conditional rendering: `if (company_type === 'non-it') { }`
- Inject tracking components into existing dashboards
- Reuse existing styling and layouts

### Security Constraints
- Authentication check on all location endpoints
- Role-based access control
- HR can only view their company's employees
- Admins can view all
- Location data encrypted in transit (HTTPS/TLS)
- RLS policies for database access

### Error Handling
- Graceful geolocation permission denial
- Network error retry logic
- Fallback UI when tracking unavailable
- User-friendly error messages

---

## File Structure

```
src/
├── pages/
│   ├── SignupNonIT.jsx (NEW)
│   ├── Login.tsx (UPDATE)
│
├── components/
│   ├── dashboard/
│   │   ├── EmployeeDashboard.jsx (UPDATE)
│   │   ├── HRDashboard.jsx (UPDATE)
│   │   ├── AdminDashboard.jsx (UPDATE)
│   │
│   ├── tracking/ (NEW FOLDER)
│   │   ├── EmployeeLocationBadge.jsx
│   │   ├── LiveLocationMap.jsx
│   │   ├── LocationLogTable.jsx
│   │   ├── EmployeeLocationTracker.jsx
│   │   └── DualLocationTracker.jsx
│
├── hooks/ (NEW FOLDER)
│   ├── useGeolocation.js
│   └── useLocationTracking.js
│
├── services/ (NEW FOLDER)
│   ├── locationService.js
│   └── geolocationService.js
│
├── context/ (UPDATE)
│   └── AuthContext.js (UPDATE to include company_type)
```

---

## Key Features

### For Non-IT Employees
✅ Real-time location sharing (with permission)
✅ Location tracking status badge
✅ Disable/enable tracking option
✅ All existing attendance/payroll features

### For Non-IT HR Managers
✅ View employee live locations
✅ Location history logs
✅ Filter by department/location
✅ All existing management features

### For Non-IT Company Admin
✅ View all employee locations (field workers)
✅ View all HR staff locations
✅ Dual tracking interface
✅ Master control dashboard

---

## Testing Checklist

- [ ] Database migration successful
- [ ] Email verification workflow works
- [ ] Login routes correctly based on company_type
- [ ] Geolocation permission handling
- [ ] Location updates sent to backend
- [ ] HR can view employee locations
- [ ] Admin can view all locations
- [ ] No breaking changes to IT company flow
- [ ] Graceful error handling
- [ ] Security tests passed

---

## Timeline Estimate
- Phase 1 (Database): 2-3 hours
- Phase 2 (Registration): 3-4 hours
- Phase 3 (Dashboards): 4-5 hours
- Phase 4 (Tracking Service): 3-4 hours
- Testing & Refinement: 2-3 hours

**Total: ~15-20 hours**

