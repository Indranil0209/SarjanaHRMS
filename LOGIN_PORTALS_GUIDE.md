# Sarjana HRMS - Login Portals Guide

## Quick Overview

The Sarjana HRMS system provides **two separate login portals** optimized for different company types.

---

## 🔷 IT Company Portal

### Access
- **URL:** `http://localhost:5173/login`
- **Component:** `src/pages/Login.tsx`

### Theme & Design
- **Color Scheme:** Blue & Cyan gradient
- **Layout:** Split-screen (left side: branded image, right side: form)
- **Branding:** "Welcome Back" - Technical focus
- **Icons:** Security/Lock focused

### Target Users
- IT Companies
- Software Development Firms
- Technology Organizations
- Tech-enabled Startups

### Demo Users (IT Portal)

| Role | Email | Password | Company |
|------|-------|----------|---------|
| Super Admin | `admin@company.com` | `password123` | Default Company |
| Admin | `john.admin@company.com` | `password123` | Default Company |
| HR Manager | `sarah.hr@company.com` | `password123` | Default Company |
| HR Manager | `emma.hr@company.com` | `password123` | Default Company |
| Employee | `mike.johnson@company.com` | `password123` | Default Company |
| Employee | `jane.smith@company.com` | `password123` | Default Company |

### Features Available
- Standard HR Management
- Real-time Analytics
- Project Management
- Team Collaboration
- Performance Reviews
- Training Records
- Payroll Management
- Leave Management
- Attendance Tracking
- Audit Logs
- System Configuration

### Company ID
`c550e8400-e29b-41d4-a716-446655440000` - Default Company

---

## 🟢 Non-IT Company Portal

### Access
- **URL:** `http://localhost:5173/login-non-it`
- **Component:** `src/pages/LoginNonIT.tsx`

### Theme & Design
- **Color Scheme:** Green gradient (with purple accents)
- **Layout:** Centered card with animated background
- **Branding:** "Location Tracking Enabled" - Location focus
- **Icons:** Location/Map Pin focused
- **Badge:** Green location badge in header

### Target Users
- Retail Companies
- Service Industry
- Delivery Services
- On-Site Field Work Companies
- Distribution Companies
- Store Operations

### Demo Users (Non-IT Portal)

| Role | Email | Password | Department |
|------|-------|----------|------------|
| **Super Admin** | `nonitadmin@company.com` | `password123` | HR |
| **HR Manager** | `nonithr@company.com` | `password123` | HR |
| **Employee** | `nonitemployee1@company.com` | `password123` | Retail Ops (Store Manager) |
| **Employee** | `nonitemployee2@company.com` | `password123` | Retail Ops (Sales Associate) |
| **Employee** | `nonitemployee3@company.com` | `password123` | Retail Ops (Sales Associate) |

### Features Available
- ✓ Real-time Location Tracking
- ✓ Live Employee Location Display
- ✓ Location History
- ✓ Employee Tracking Dashboard
- ✓ Geofencing
- ✓ Attendance from Location
- ✓ Leave Management
- ✓ Payroll Management
- ✓ Performance Reviews
- ✓ Team Directory
- ✓ Field Work Tracking

### Company ID
`c550e8400-e29b-41d4-a716-446655440001` - Non-IT Services Company

---

## Detailed Comparison

### Visual Design

#### IT Portal (Login.tsx)
```
┌─────────────────────────────────────────────────────┐
│                                                       │
│  ┌──────────────┐  ┌──────────────────────────────┐ │
│  │              │  │                              │ │
│  │   Branded    │  │  Sign In Form                │ │
│  │   Image      │  │                              │ │
│  │   + Text     │  │  Email [____]                │ │
│  │              │  │  Password [____]             │ │
│  │   Features   │  │  [Sign In]                   │ │
│  │   List       │  │                              │ │
│  │              │  │  Social Logins               │ │
│  │              │  │  Google | LinkedIn           │ │
│  │              │  │                              │ │
│  └──────────────┘  └──────────────────────────────┘ │
│   (Dark Blue)        (Dark Slate + White)            │
│   40% Width          60% Width                       │
│                                                       │
└─────────────────────────────────────────────────────┘
```

#### Non-IT Portal (LoginNonIT.tsx)
```
┌─────────────────────────────────────────────────┐
│                                                   │
│  🎨 Animated Gradient Background                 │
│                                                   │
│              📍 Non-IT Portal                     │
│            Location Tracking Enabled             │
│                                                   │
│  ┌──────────────────────────────────────────┐   │
│  │  Sign In                                 │   │
│  │  ───────────────────────────────         │   │
│  │  Email [____]                            │   │
│  │  Password [____]                         │   │
│  │  ☑ Remember me                           │   │
│  │  [📍 Sign In]                            │   │
│  │                                          │   │
│  │  ✓ Real-time Location                    │   │
│  │  ✓ Live Tracking                         │   │
│  │  ✓ Location History                      │   │
│  │  ✓ Employee Tracking                     │   │
│  │                                          │   │
│  │  Demo Credentials...                     │   │
│  │                                          │   │
│  └──────────────────────────────────────────┘   │
│       (Centered Card - Max Width: 28rem)         │
│                                                   │
│  [Back to IT Company Login]                      │
│                                                   │
└─────────────────────────────────────────────────┘
```

### Technical Comparison

| Aspect | IT Portal | Non-IT Portal |
|--------|-----------|---------------|
| **File** | `Login.tsx` | `LoginNonIT.tsx` |
| **Framework** | React + TypeScript | React + TypeScript |
| **Styling** | Tailwind CSS | Tailwind CSS |
| **Icons Library** | Lucide React | Lucide React |
| **Auth Method** | Email + Password | Email + Password |
| **Password Hashing** | Bcrypt | Bcrypt |
| **Responsive** | Yes | Yes |
| **Dark Mode** | Yes | Yes |
| **Social Login** | Google, LinkedIn | Not available |
| **MFA Support** | No (optional) | No (optional) |

### Feature Comparison

| Feature | IT Portal | Non-IT Portal |
|---------|-----------|---------------|
| **Email/Password Login** | ✓ | ✓ |
| **Remember Me** | ✓ | ✓ |
| **Forgot Password** | ✓ | ✗ |
| **Social Login** | ✓ | ✗ |
| **2FA/MFA** | ✓ (setup page) | ✗ |
| **Location Tracking** | Optional | Mandatory |
| **Device ID Tracking** | Not shown | Implied |
| **Geofencing** | Not shown | Available |
| **Real-time Tracking** | Not shown | Featured |
| **Location History** | Not shown | Featured |
| **Employee Map View** | Not shown | Available |
| **Attendance from GPS** | Not shown | Available |

### Database Differences

#### IT Company Database
```
Companies Table:
├── id: c550e8400-e29b-41d4-a716-446655440000
├── name: Default Company
├── industry: Technology
└── settings: {standard HR config}

Users Table:
├── 550e8400-e29b-41d4-a716-446655440000 (Super Admin)
├── 550e8400-e29b-41d4-a716-446655440001 (Admin)
├── 550e8400-e29b-41d4-a716-446655440002 (HR Manager)
├── 550e8400-e29b-41d4-a716-446655440003 (HR Manager)
└── 550e8400-e29b-41d4-a716-446655440004-015 (Employees - 12 total)

Departments:
├── Engineering
├── Human Resources
├── Sales
├── Marketing
├── Finance
└── Operations
```

#### Non-IT Company Database
```
Companies Table:
├── id: c550e8400-e29b-41d4-a716-446655440001
├── name: Non-IT Services Company
├── industry: Retail & Services
└── settings: {HR config + location tracking}

Users Table:
├── 550e8400-e29b-41d4-a716-446655440020 (Super Admin)
├── 550e8400-e29b-41d4-a716-446655440021 (HR Manager)
└── 550e8400-e29b-41d4-a716-446655440022-024 (Employees - 3 total)

Departments:
├── Retail Operations
├── Human Resources
├── Sales & Marketing
└── Finance

Locations Table: (Non-IT specific)
├── Real-time tracking data
├── Location history
├── Geofence boundaries
└── Employee presence logs
```

### Routing

```
Frontend Routes:

Public Routes:
/login ......................... IT Company Login (Login.tsx)
/login-non-it .................. Non-IT Company Login (LoginNonIT.tsx)
/signup ........................ IT Company Signup
/nonit/signup .................. Non-IT Company Signup
/employee-registration ......... Employee Registration

Protected Routes:
/dashboard ..................... Main Dashboard (role-based)
/dashboard/apply-leave ......... Leave Management
/dashboard/payslip ............ Payroll
/dashboard/profile-settings ... User Profile
/dashboard/manage-attendance .. Attendance (Managers/Admin)
/dashboard/admin/users ........ User Management (Admin)
/dashboard/employee-live-location .. Live Location (Non-IT)
```

### User Journey

#### IT Company User
```
1. Visit http://localhost:5173/login
2. Enter IT company credentials (admin@company.com)
3. Click Sign In (or use Google/LinkedIn)
4. Redirected to /dashboard
5. Role-based features loaded
```

#### Non-IT Company User
```
1. Visit http://localhost:5173/login-non-it
2. Enter Non-IT company credentials (nonitadmin@company.com)
3. System requests location permission
4. Click Sign In
5. Redirected to /dashboard with location tracking active
6. Location data starts being collected
```

### Security Comparison

| Security Feature | IT Portal | Non-IT Portal |
|------------------|-----------|---------------|
| **Password Hashing** | Bcrypt (10 rounds) | Bcrypt (10 rounds) |
| **HTTPS** | Required (production) | Required (production) |
| **CSRF Protection** | Yes | Yes |
| **SQL Injection Prevention** | Parameterized queries | Parameterized queries |
| **XSS Protection** | React escaping | React escaping |
| **Rate Limiting** | Server-side | Server-side |
| **Session Management** | JWT | JWT |
| **Email Verification** | Yes | Yes |
| **GPS Spoofing Protection** | N/A | Location validation |
| **Device Fingerprinting** | No | Optional |
| **Biometric Login** | No (future) | No (future) |

---

## How to Switch Between Portals

### From IT Portal to Non-IT Portal
1. At IT login page, scroll down
2. Click "Back to Non-IT Portal" link (if available)
3. Or navigate directly to `http://localhost:5173/login-non-it`

### From Non-IT Portal to IT Portal
1. At Non-IT login page, find "← Back to IT Company Login" link
2. Or navigate directly to `http://localhost:5173/login`

---

## Setup & Deployment

### Local Development
```bash
# Start the development server
npm run dev

# Access portals
IT Portal:     http://localhost:5173/login
Non-IT Portal: http://localhost:5173/login-non-it
```

### Production Deployment
```bash
# Build for production
npm run build

# Serve built files
npm run preview

# Deploy to hosting service
# (Same URLs as development)
```

---

## Testing the Portals

### IT Portal Testing
```javascript
// Test credentials
email: admin@company.com
password: password123

// Expected behavior
1. Form submits successfully
2. Success message appears
3. Redirects to dashboard after 1 second
4. Dashboard loads with IT company features
```

### Non-IT Portal Testing
```javascript
// Test credentials
email: nonitadmin@company.com
password: password123

// Expected behavior
1. Browser requests location permission
2. Form submits successfully
3. Success message appears with location badge
4. Redirects to dashboard with location tracking
5. Dashboard shows location-tracking features
```

---

## Future Enhancements

### Planned for Both Portals
- [ ] Biometric login (fingerprint/face)
- [ ] Two-factor authentication (SMS/Email)
- [ ] Social login for Non-IT (upcoming)
- [ ] SSO integration (SAML/OAuth)
- [ ] WebAuthn support
- [ ] Dark mode toggle (already in Non-IT)
- [ ] Multi-language support

### Non-IT Portal Specific
- [ ] QR code attendance
- [ ] Offline mode with sync
- [ ] Augmented reality (AR) site inspection
- [ ] Voice recognition
- [ ] Mobile native apps (iOS/Android)

---

## Summary

| Aspect | IT Portal | Non-IT Portal |
|--------|-----------|---------------|
| **Best For** | Tech Companies | Retail/Services |
| **Theme** | Professional Tech | Location-Focused |
| **Key Feature** | Analytics & Insights | Location Tracking |
| **Use Case** | Office-based teams | Field work teams |
| **Setup Complexity** | Medium | Medium |
| **User Count** | 18+ demo users | 5 demo users |
| **Status** | ✓ Production Ready | ✓ Production Ready |

---

**Both login portals are fully functional and ready for testing!**

For detailed setup instructions, see:
- IT Portal: `hr_management_complete_schema_part2.sql`
- Non-IT Portal: `non_it_demo_credentials.sql`
