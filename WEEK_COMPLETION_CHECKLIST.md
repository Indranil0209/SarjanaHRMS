# Week Completion Checklist

## Task Overview
Complete the remaining Non-IT features and backend verification to finalize the week's workflow.

---

## 1. Non-IT Employee Dashboard with Live Location

**Status:** ⏳ IN PROGRESS

**Requirements:**
- Employee can view their own live location only
- Keep all existing IT employee dashboard features
- Add Live Location section
- Show location updates with timestamp
- Link to Google Maps (optional)

**Files to Create/Modify:**
- `src/components/dashboard/NonITEmployeeDashboard.jsx` (NEW)
- `src/pages/Non-IT/EmployeeOwnLocation.jsx` (NEW - for employee's own location view)

**Features:**
- Current location display
- Location history (last 10 check-ins)
- Status indicator (Online/Offline)
- Real-time updates

---

## 2. Company Dashboard (Admin/Super Admin View)

**Status:** ⏳ IN PROGRESS

**Requirements:**
- Similar to IT Company Dashboard
- Show Employee Live Location Tracking (all employees)
- Show HR Live Location Tracking (all HR managers)
- Real-time location updates
- Filter by department

**Files to Create/Modify:**
- `src/components/dashboard/CompanyDashboard.jsx` (NEW)
- Route: `/dashboard/company-overview` (NEW)

**Features:**
- Employee locations map
- HR locations map
- Department-wise filtering
- Location history
- Last updated timestamp

---

## 3. Backend Verification (for Debdip)

**Status:** ⏳ IN PROGRESS

**Checklist:**
- [ ] Verify Non-IT signup email verification flow
- [ ] Test all Non-IT registration APIs
- [ ] Verify database constraints
- [ ] Check auth flow for Non-IT users
- [ ] Test location tracking APIs
- [ ] Document all findings

**Documentation File:**
- `BACKEND_VERIFICATION_REPORT.md` (NEW)

---

## 4. Supabase Configuration

**Status:** ⏳ IN PROGRESS

**SQL Operations:**
- Update `company_type = 'non-it'` for all Non-IT demo users
- Verify users table structure
- Confirm roles are set correctly

**Users to Update:**
- nonitadmin@company.com
- nonithr@company.com
- nonitemployee1@company.com
- nonitemployee2@company.com
- nonitemployee3@company.com

---

## Execution Order

1. ✅ Supabase Configuration (SQL)
2. ⏳ Non-IT Employee Dashboard
3. ⏳ Company Dashboard
4. ⏳ Backend Verification & Documentation

---

## Build & Test Status
- Current Build: ✅ PASSING
- No compilation errors
- All routes configured
- Ready for component additions
