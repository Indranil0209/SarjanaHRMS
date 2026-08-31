# Non-IT Company Track - Quick Start Guide

## For Developers

### What Was Built

✅ **Phase 2 Complete:** Frontend Non-IT Company Support with Location Tracking
- Updated authentication context with company_type
- Conditional dashboards for Non-IT companies
- Location tracking components (Badge, HR View, Admin View)
- Non-IT specific signup page

---

## Quick Setup

### 1. Using the Non-IT Signup
```
1. Navigate to /signup-non-it
2. Fill in company details
3. Set password and verify
4. User account created with company_type = 'non-it'
```

### 2. Testing Location Tracking (Frontend)

**For Employee:**
```
1. Login with Non-IT employee account
2. See "Location Tracking" badge on dashboard
3. Click "Enable" button
4. Browser requests geolocation permission
5. Accept permission to start tracking
```

**For HR Manager:**
```
1. Login with Non-IT HR account
2. See "Employee Locations" panel
3. View all employee real-time locations
4. See status (live, recent, idle, offline)
5. Click "Refresh" for manual update
```

**For Admin:**
```
1. Login with Non-IT Admin account
2. See "Dual Location Tracking" panel
3. View employees and HR staff locations
4. Switch tabs to filter by role
5. Monitor company-wide locations
```

---

## Code Structure

### Entry Points for Non-IT Features

**Check if user is Non-IT:**
```javascript
const { isNonIT } = useAuth()

if (isNonIT) {
  // Show Non-IT specific features
}
```

**Get company type:**
```javascript
const { companyType } = useAuth()

switch(companyType) {
  case 'non-it':
    // Non-IT flow
    break
  case 'it':
    // IT flow
    break
}
```

**Enable location tracking:**
```javascript
const locationTracking = useLocationTracking(userId, userRole, isNonIT)

// Toggle tracking
await locationTracking.toggleTracking()

// Check status
if (locationTracking.isTracking) {
  console.log('Currently tracking')
}
```

---

## Component Usage

### EmployeeLocationBadge
Shows tracking status on employee dashboard:
```jsx
<EmployeeLocationBadge
  isTracking={locationTracking.isTracking}
  isEnabled={locationTracking.isEnabled}
  error={locationTracking.error}
  lastUpdate={locationTracking.lastUpdate}
  permissionStatus={locationTracking.permissionStatus}
  onToggle={locationTracking.toggleTracking}
/>
```

### EmployeeLocationTracker
Shows employee locations in HR dashboard:
```jsx
<EmployeeLocationTracker 
  companyId={profile.company_id}
  filter="employee"
/>
```

### DualLocationTracker
Shows all locations in Admin dashboard:
```jsx
<DualLocationTracker 
  companyId={profile.company_id}
/>
```

---

## Testing Scenarios

### Scenario 1: Non-IT Employee Signup
```
1. Go to /signup-non-it
2. Fill form with test data
3. Set company_type to 'non-it' (automatic)
4. Submit
5. Should see "Account created" message
6. Should be able to login with new account
```

### Scenario 2: Location Tracking Enabled
```
1. Login as Non-IT employee
2. See location badge on dashboard
3. Click "Enable"
4. Grant browser permission
5. Badge should show "Tracking Live"
6. Last update should show current time
```

### Scenario 3: Location Tracking Disabled
```
1. Login as Non-IT employee
2. See location badge
3. Click "Disable" (if enabled)
4. Badge should show "Tracking Disabled"
5. No location updates sent
```

### Scenario 4: HR Viewing Locations
```
1. Login as Non-IT HR manager
2. Go to dashboard
3. See "Employee Locations" table
4. Table shows employees with locations
5. Status indicators show (live/recent/idle/offline)
6. Click "Refresh" to update manually
```

### Scenario 5: Admin Dual View
```
1. Login as Non-IT Admin
2. Go to dashboard
3. See "Dual Location Tracking" panel
4. See "All Users", "Field Employees", "HR Staff" tabs
5. Switch tabs to filter
6. See locations for each role
7. Click "Refresh" to update
```

---

## Important Files

| File | Purpose |
|------|---------|
| `src/context/AuthContext.jsx` | Company type state & routing |
| `src/pages/SignupNonIT.tsx` | Non-IT signup form |
| `src/pages/Login.tsx` | Unified login (no changes needed) |
| `src/components/dashboard/EmployeeDashboard.jsx` | Employee dash with location badge |
| `src/components/dashboard/HRDashboard.jsx` | HR dash with employee tracking |
| `src/components/dashboard/AdminDashboard.jsx` | Admin dash with dual tracking |
| `src/components/tracking/*.jsx` | Tracking UI components |
| `src/hooks/useLocationTracking.js` | Location tracking hook |
| `src/services/locationService.js` | Backend API calls |

---

## Environment Setup

### Browser Requirements
- Geolocation API support (all modern browsers)
- Permission popup handling (user grants permission)

### Backend Requirements (Phase 3)
```
1. location_logs table
2. User profile with company_type field
3. Location endpoints:
   - POST /api/locations (send location)
   - GET /api/locations/user/:id (get user location)
   - GET /api/locations/company/:id (get all locations)
4. Email verification system
5. Role-based access control
```

---

## Debugging

### Check Company Type in Browser Console
```javascript
// Get current user's company type
const { profile, companyType, isNonIT } = useAuth()
console.log('Company Type:', companyType)
console.log('Is Non-IT:', isNonIT)
console.log('Profile:', profile)
```

### Check Location Tracking Status
```javascript
const locationTracking = useLocationTracking(userId, userRole, true)
console.log('Tracking Status:', {
  isTracking: locationTracking.isTracking,
  isEnabled: locationTracking.isEnabled,
  lastUpdate: locationTracking.lastUpdate,
  error: locationTracking.error,
  permissionStatus: locationTracking.permissionStatus
})
```

### Common Browser Permission Issues
```
PERMISSION_DENIED: User rejected browser permission
  → Show button to retry with clear instructions

POSITION_UNAVAILABLE: GPS not available
  → Show "Location not available" message

TIMEOUT: Location request took too long
  → Automatic retry after delay

NOT_SUPPORTED: Browser doesn't support geolocation
  → Show "Browser not supported" message
```

---

## Deployment Checklist

- [ ] AuthContext updated (DONE)
- [ ] Dashboards updated (DONE)
- [ ] Tracking components created (DONE)
- [ ] SignupNonIT page created (DONE)
- [ ] No syntax errors (VERIFIED)
- [ ] No breaking changes to IT workflow (VERIFIED)
- [ ] Database migrations ready (PENDING - Phase 3)
- [ ] Backend APIs ready (PENDING - Phase 3)
- [ ] Email verification ready (PENDING - Phase 3)
- [ ] All tests passing (PENDING)
- [ ] Production deployment (PENDING)

---

## Next Steps

### Immediate (Phase 3 - Backend)
1. Database schema updates for company_type field
2. Create location_logs table
3. Implement email verification
4. Create location API endpoints
5. Add role-based access control

### Short Term
1. End-to-end testing of location tracking
2. Performance optimization
3. Browser compatibility testing
4. Error handling improvements

### Medium Term
1. Advanced location analytics
2. Geofencing for automatic check-in/out
3. Location history reports
4. Route tracking for field employees
5. Integration with maps API

---

## Support

### Questions?
- Check NON_IT_IMPLEMENTATION_PLAN.md for architecture details
- Review component JSDoc comments for usage
- Check example test scenarios above

### Issues?
- Check browser console for error messages
- Verify geolocation permission in browser settings
- Ensure backend location endpoints are implemented
- Check network tab for API failures

---

**Ready to Deploy:** Frontend Phase 2 ✅
**Next Milestone:** Backend Phase 3
**Last Updated:** July 16, 2026
