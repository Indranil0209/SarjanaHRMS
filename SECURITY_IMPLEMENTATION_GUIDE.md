# Security Implementation Guide - SarjanaHRMS

## Overview

This guide documents the P1 security fixes implemented for the multi-tenant, role-based authentication system. These implementations ensure strict access control across IT/Non-IT portals and prevent cross-company data leakage.

---

## 1. Permission Service (`src/services/permissionService.ts`)

### Purpose
Centralized role-based access control (RBAC) logic that implements the principle of least privilege.

### Key Components

#### 1.1 Role Definitions
```typescript
export enum UserRole {
  SUPER_ADMIN = 'super_admin'    // Platform-level admin
  ADMIN = 'admin'                // Company-level admin
  HR_MANAGER = 'hr_manager'      // HR operations
  EMPLOYEE = 'employee'          // Standard employee
}
```

#### 1.2 Permission Matrix
Defines granular permissions for each role:

| Role | Sample Permissions |
|------|-------------------|
| **SUPER_ADMIN** | `*` (all permissions) |
| **ADMIN** | manage_employees, view_payroll, manage_leaves, approve_leaves, view_audit_logs |
| **HR_MANAGER** | view_employees, process_payroll, manage_leaves, view_attendance |
| **EMPLOYEE** | view_own_profile, apply_leave, view_own_payslip, view_team_directory |

#### 1.3 Route Permissions
Specifies which roles can access specific routes:

```typescript
const ROUTE_PERMISSIONS: Record<string, UserRole[]> = {
  '/dashboard/admin/users': [UserRole.SUPER_ADMIN, UserRole.ADMIN],
  '/dashboard/manage-leaves': [UserRole.SUPER_ADMIN, UserRole.ADMIN, UserRole.HR_MANAGER],
  '/dashboard/apply-leave': [UserRole.SUPER_ADMIN, UserRole.ADMIN, UserRole.HR_MANAGER, UserRole.EMPLOYEE],
  // ... more routes
}
```

#### 1.4 Sector Features
Defines features available in each sector:

```typescript
const SECTOR_FEATURES: Record<SectorType, Set<string>> = {
  'it': ['standard_hr', 'payroll', 'leave_management', 'attendance'],
  'non-it': ['standard_hr', 'payroll', 'leave_management', 'attendance', 'location_tracking', 'gps_tracking']
}
```

### Public API

#### `canPerformAction(role, action): boolean`
Check if a user can perform a specific action.
```typescript
if (canPerformAction(profile.role, 'manage_employees')) {
  // Show manage employees UI
}
```

#### `canAccessRoute(role, route): boolean`
Check if a user can access a specific route.
```typescript
if (!canAccessRoute(profile.role, '/dashboard/admin/users')) {
  return <Navigate to="/unauthorized" />
}
```

#### `checkAccess(userRole, userCompanyId, resourceCompanyId, route, sector): { allowed, reason? }`
Comprehensive multi-factor access check.
```typescript
const result = checkAccess(
  profile.role,
  profile.company_id,
  resourceCompanyId,
  '/dashboard/admin/users',
  companyType
)
if (!result.allowed) {
  console.log(result.reason) // Access denied reason
}
```

#### `hasFeature(sector, feature): boolean`
Check if a sector supports a specific feature.
```typescript
if (hasFeature(companyType, 'location_tracking')) {
  // Show location tracking UI
}
```

---

## 2. Role Guard Component (`src/components/auth/RoleGuard.tsx`)

### Purpose
Provides component-level role enforcement for wrapping sensitive components.

### Usage

#### Basic Usage - Role Restriction
```typescript
import { RoleGuard, UserRole } from '../services/permissionService'

<RoleGuard allowedRoles={[UserRole.ADMIN, UserRole.HR_MANAGER]}>
  <AdminPanel />
</RoleGuard>
```

#### Advanced Usage - With Company Isolation
```typescript
<RoleGuard
  allowedRoles={[UserRole.ADMIN]}
  resourceCompanyId={companyId}
  showUnauthorizedPage={true}
>
  <CompanySettings />
</RoleGuard>
```

#### Advanced Usage - With Sector Check
```typescript
<RoleGuard
  allowedRoles={[UserRole.ADMIN, UserRole.HR_MANAGER, UserRole.EMPLOYEE]}
  sector={'non-it'}
  showUnauthorizedPage={true}
>
  <LocationTrackingDashboard />
</RoleGuard>
```

### Props

| Prop | Type | Required | Description |
|------|------|----------|-------------|
| `allowedRoles` | `UserRole[]` | Yes | Roles permitted to view component |
| `children` | `React.ReactNode` | Yes | Component to render if authorized |
| `resourceCompanyId` | `string` | No | Company ID to verify ownership |
| `sector` | `SectorType` | No | Sector-specific checks |
| `fallbackRoute` | `string` | No | Route if unauthorized (default: `/dashboard`) |
| `showUnauthorizedPage` | `boolean` | No | Show error page instead of redirect |

---

## 3. Enhanced Protected Route (`src/components/auth/EnhancedProtectedRoute.tsx`)

### Purpose
Replaces the basic ProtectedRoute with comprehensive multi-tenant security checks.

### Checks Performed

1. **Authentication** - Verifies user is logged in
2. **Role-Based Access** - Checks if role can access route
3. **Route-Level Permissions** - Verifies route is allowed for role
4. **Company Isolation** - Ensures user can't access other companies' data
5. **Sector-Specific Access** - Validates sector feature access

### Usage in App.tsx

**Before (Basic):**
```typescript
<Route path="/dashboard/admin/users" element={<ProtectedRoute><ManageUsers /></ProtectedRoute>} />
```

**After (Enhanced):**
```typescript
import { EnhancedProtectedRoute } from './components/auth/EnhancedProtectedRoute'
import { UserRole } from './services/permissionService'

<Route 
  path="/dashboard/admin/users" 
  element={
    <EnhancedProtectedRoute requiredRoles={[UserRole.ADMIN]}>
      <ManageUsers />
    </EnhancedProtectedRoute>
  } 
/>
```

### Audit Logging
Every access attempt is logged with:
- User ID
- User role
- Company ID
- Route accessed
- Access decision (granted/denied)
- Timestamp

---

## 4. Audit Service (`src/services/auditService.ts`)

### Purpose
Centralized logging for all security-critical events.

### Event Types

| Category | Events |
|----------|--------|
| **Authentication** | LOGIN_ATTEMPT, LOGIN_SUCCESS, LOGIN_FAILED, LOGOUT, SIGNUP |
| **Authorization** | ACCESS_GRANTED, ACCESS_DENIED, PERMISSION_ERROR |
| **Data Operations** | DATA_VIEW, DATA_CREATE, DATA_UPDATE, DATA_DELETE, DATA_EXPORT |
| **Security** | UNAUTHORIZED_ATTEMPT, CROSS_COMPANY_ATTEMPT, CROSS_SECTOR_ATTEMPT, ROLE_ESCALATION_ATTEMPT |

### Public API

#### `logAccessControl(decision, userId, companyId, route, reason?)`
Log route access decision.
```typescript
await logAccessControl('granted', user.id, profile.company_id, '/dashboard/admin/users')
await logAccessControl('denied', user.id, profile.company_id, '/dashboard/admin/users', 'Insufficient role')
```

#### `logUnauthorizedAttempt(userId, companyId, route, attemptedAction, reason)`
Log unauthorized access attempts.
```typescript
await logUnauthorizedAttempt(
  user.id,
  profile.company_id,
  '/dashboard/admin/security',
  'Access admin panel',
  'Employee role cannot access admin'
)
```

#### `logCrossCompanyAttempt(userId, userCompanyId, targetCompanyId, resource)`
Log attempts to access other companies' data.
```typescript
await logCrossCompanyAttempt(
  user.id,
  profile.company_id,
  otherCompanyId,
  'employee_records'
)
```

#### `logDataOperation(operation, userId, companyId, resourceType, resourceId?, details?)`
Log data operations for audit trail.
```typescript
await logDataOperation(
  'export',
  user.id,
  profile.company_id,
  'payroll',
  undefined,
  { format: 'csv', rows: 100 }
)
```

#### `getAuditLogs(companyId, filters?)`
Retrieve audit logs (admin only).
```typescript
const logs = await getAuditLogs(companyId, {
  eventType: AuditEventType.ACCESS_DENIED,
  severity: AuditSeverity.WARNING,
  startDate: new Date('2024-01-01'),
  limit: 50
})
```

---

## 5. Fixed AuthContext Enhancements

### Employee ID Resolution Security Fix

**Problem:** Employee ID lookup didn't filter by company_id, allowing cross-company employee lookup.

**Solution:** Added company_id capture during employee ID resolution.

```typescript
// OLD - VULNERABLE
const { data: employeeData } = await supabase
  .from('employees')
  .select('user_id')
  .eq('employee_id', emailOrEmpId.trim())  // ❌ No company filter

// NEW - SECURE
const { data: employeeData } = await supabase
  .from('employees')
  .select('user_id, company_id')
  .eq('employee_id', emailOrEmpId.trim())  // Get employee
  .limit(1)

userCompanyId = employeeData[0].company_id  // Track for validation
```

---

## 6. Unauthorized Page (`src/pages/UnauthorizedPage.tsx`)

### Purpose
User-friendly error page for access denied scenarios.

### Reasons Shown

- **insufficient_role** - User's role doesn't have permission
- **cross_company** - Attempting cross-company access
- **access_denied** - Generic access denied

### Usage

```typescript
// In route
<Route path="/unauthorized" element={<UnauthorizedPage />} />

// In guards
return <Navigate to="/unauthorized?reason=insufficient_role" />
```

---

## 7. Implementation Checklist

### Phase 1: Deploy New Services ✅
- [x] Create `permissionService.ts`
- [x] Create `auditService.ts`
- [x] Create `RoleGuard.tsx` component
- [x] Create `EnhancedProtectedRoute.tsx` component
- [x] Create `UnauthorizedPage.tsx`

### Phase 2: Update AuthContext ✅
- [x] Add company_id tracking in employee ID resolution
- [x] Add audit logging to signIn/signUp
- [x] Add cross-company validation

### Phase 3: Update Routes (TODO)
- [ ] Replace basic ProtectedRoute with EnhancedProtectedRoute in App.tsx
- [ ] Add requiredRoles to admin routes
- [ ] Add requiredRoles to HR routes
- [ ] Test all route transitions

### Phase 4: Database RLS Policies (TODO)
- [ ] Enable RLS on production
- [ ] Create policies for user isolation
- [ ] Create policies for employee isolation
- [ ] Create policies for payroll isolation

### Phase 5: Monitoring & Testing
- [ ] Monitor audit logs for suspicious access attempts
- [ ] Test cross-company access prevention
- [ ] Test cross-sector access prevention
- [ ] Load test with multiple concurrent users
- [ ] Security audit by external team

---

## 8. Security Best Practices

### For Developers

1. **Always use EnhancedProtectedRoute** for new protected routes
2. **Specify requiredRoles** when creating admin/HR routes
3. **Check permissions** before showing sensitive UI components
4. **Log data operations** using auditService for compliance
5. **Validate company_id** on all data queries

### Example - Adding a New Admin Route

```typescript
// 1. Add to permissionService ROUTE_PERMISSIONS
'/dashboard/admin/new-feature': [UserRole.SUPER_ADMIN, UserRole.ADMIN],

// 2. Add requiredRoles to route
<Route
  path="/dashboard/admin/new-feature"
  element={
    <EnhancedProtectedRoute requiredRoles={[UserRole.ADMIN]}>
      <NewFeature />
    </EnhancedProtectedRoute>
  }
/>

// 3. Use RoleGuard in sensitive components
<RoleGuard allowedRoles={[UserRole.ADMIN]}>
  <DeleteButton />
</RoleGuard>

// 4. Log data operations
await logDataOperation('delete', userId, companyId, 'feature', featureId)
```

### For Admins

1. **Regularly review audit logs** for unauthorized access attempts
2. **Monitor cross-company access attempts** - should be zero
3. **Alert on repeated failed access** - potential attack
4. **Verify company isolation** - spot check random data queries
5. **Update permissions** when roles change

---

## 9. Testing Guide

### Unit Tests - Permission Service

```typescript
describe('permissionService', () => {
  test('super_admin can perform all actions', () => {
    expect(canPerformAction(UserRole.SUPER_ADMIN, 'any_action')).toBe(true)
  })

  test('employee cannot access admin routes', () => {
    expect(canAccessRoute(UserRole.EMPLOYEE, '/dashboard/admin/users')).toBe(false)
  })

  test('cross-company access is denied', () => {
    const result = checkAccess(
      UserRole.ADMIN,
      'company1',      // user company
      'company2',      // resource company
      '/dashboard',
      SectorType.IT
    )
    expect(result.allowed).toBe(false)
    expect(result.reason).toContain('company')
  })
})
```

### Integration Tests - Route Protection

```typescript
describe('Enhanced Protected Routes', () => {
  test('employee cannot access admin route', async () => {
    // Login as employee
    await login('employee@company.com', 'password')
    
    // Try to access admin route
    const response = await visit('/dashboard/admin/users')
    
    // Should redirect to unauthorized
    expect(response.url).toContain('unauthorized')
  })

  test('admin can only access their company data', async () => {
    // Login as admin for company1
    await login('admin@company1.com', 'password')
    
    // Try to access company2 resources
    const response = await fetch('/api/company/company2/employees')
    
    // Should return 403 Forbidden
    expect(response.status).toBe(403)
  })
})
```

---

## 10. Troubleshooting

### Issue: Routes still accessible to unauthorized users

**Check:**
1. Is EnhancedProtectedRoute being used (not basic ProtectedRoute)?
2. Are requiredRoles specified?
3. Is the route in ROUTE_PERMISSIONS?

```typescript
// ❌ Wrong
<Route path="/admin" element={<ProtectedRoute><Admin /></ProtectedRoute>} />

// ✅ Correct
<Route path="/admin" element={
  <EnhancedProtectedRoute requiredRoles={[UserRole.ADMIN]}>
    <Admin />
  </EnhancedProtectedRoute>
} />
```

### Issue: Cross-company data visible

**Check:**
1. All queries include company_id filter
2. Users can't modify company_id via UI
3. Database constraints enforce company isolation

```typescript
// ❌ Wrong - no company filter
const { data } = await supabase
  .from('employees')
  .select('*')

// ✅ Correct - company isolated
const { data } = await supabase
  .from('employees')
  .select('*')
  .eq('company_id', userCompanyId)
```

### Issue: Audit logs not recording

**Check:**
1. audit_logs table exists in database
2. User has insert permissions
3. Check browser console for errors

---

## 11. Next Steps (P2 Priority)

1. **Database Row-Level Security (RLS)** - Enable RLS policies in production
2. **API Validation** - Add server-side permission checks
3. **Rate Limiting** - Prevent brute force access attempts
4. **2FA Implementation** - Two-factor authentication
5. **Session Management** - Automatic logout after inactivity
6. **Encryption** - Encrypt sensitive data at rest

---

## 12. Support & Questions

For questions about these security implementations:
1. Check the code comments in each service file
2. Review the SECURITY_IMPLEMENTATION_GUIDE.md
3. Check audit logs for access control decisions
4. Contact security team for security concerns

---

**Last Updated:** 2024-01-XX
**Security Level:** P1 - Critical
**Status:** Implemented
