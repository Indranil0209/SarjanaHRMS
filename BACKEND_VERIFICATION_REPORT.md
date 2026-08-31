# Backend Verification Report
**Date:** July 16, 2026  
**Assigned to:** Debdip Dutta  
**Status:** ⏳ IN PROGRESS

---

## Overview
This document tracks all backend verification tasks for the Non-IT signup and location tracking features.

---

## 1. Non-IT Signup Email Verification Flow

### Requirements to Verify:
- [ ] Email verification link is sent after signup
- [ ] Email link is valid for 24 hours
- [ ] User cannot log in until email is verified
- [ ] Verification sets `email_verified = true` in users table
- [ ] Resend verification email functionality works

### Test Cases:

**Test 1.1: Signup with Email Verification**
```
Action: Complete Non-IT signup at /nonit/signup
Expected: Confirmation email sent
Result: ______________________________
Notes: ______________________________
```

**Test 1.2: Email Link Verification**
```
Action: Click verification link in email
Expected: email_verified = true in database
Result: ______________________________
Notes: ______________________________
```

**Test 1.3: Login Before Verification**
```
Action: Try to login before verifying email
Expected: Error message "Please verify your email first"
Result: ______________________________
Notes: ______________________________
```

**Test 1.4: Login After Verification**
```
Action: Login after verification
Expected: Access to dashboard
Result: ______________________________
Notes: ______________________________
```

---

## 2. Non-IT Registration APIs

### APIs to Test:

#### 2.1 POST `/api/auth/signup-non-it` (or similar)
```
Method: POST
Endpoint: ___________________________
Status Code: 200 ✓ / ❌
Request Body:
{
  "email": "test@company.com",
  "password": "password123",
  "first_name": "John",
  "last_name": "Doe",
  "company_name": "Non-IT Services"
}
Response: ___________________________
Issues: ___________________________
```

#### 2.2 POST `/api/auth/verify-email`
```
Method: POST
Endpoint: ___________________________
Status Code: 200 ✓ / ❌
Request Body:
{
  "token": "verification_token_here"
}
Response: ___________________________
Issues: ___________________________
```

#### 2.3 POST `/api/auth/resend-verification`
```
Method: POST
Endpoint: ___________________________
Status Code: 200 ✓ / ❌
Request Body:
{
  "email": "test@company.com"
}
Response: ___________________________
Issues: ___________________________
```

---

## 3. Location Tracking APIs

### APIs to Test:

#### 3.1 GET `/api/locations/employee/:id` (Own Location)
```
Method: GET
Endpoint: ___________________________
Status Code: 200 ✓ / ❌
Auth: Required (Bearer Token)
Response Fields:
- [ ] latitude
- [ ] longitude
- [ ] location (address)
- [ ] status (Online/Offline)
- [ ] updated_at
Response: ___________________________
Issues: ___________________________
```

#### 3.2 GET `/api/locations/company/employees` (All Employee Locations)
```
Method: GET
Endpoint: ___________________________
Status Code: 200 ✓ / ❌
Auth: Required (Admin/Super Admin)
Query Params:
- [ ] company_id
- [ ] department_id (optional)
Response: ___________________________
Issues: ___________________________
```

#### 3.3 GET `/api/locations/company/hr-managers` (HR Manager Locations)
```
Method: GET
Endpoint: ___________________________
Status Code: 200 ✓ / ❌
Auth: Required (Admin/Super Admin)
Query Params:
- [ ] company_id
Response: ___________________________
Issues: ___________________________
```

#### 3.4 POST `/api/locations/update` (Update Current Location)
```
Method: POST
Endpoint: ___________________________
Status Code: 200 ✓ / ❌
Auth: Required (Employee)
Request Body:
{
  "latitude": 40.7128,
  "longitude": -74.0060,
  "location": "New York, NY",
  "status": "Online"
}
Response: ___________________________
Issues: ___________________________
```

---

## 4. Database Schema Verification

### Tables to Check:

**4.1 users table**
```sql
-- Required columns
- [ ] id (UUID)
- [ ] email (text)
- [ ] company_type ('it' or 'non-it')
- [ ] role (employee, hr_manager, super_admin, admin)
- [ ] is_active (boolean)
- [ ] email_verified (boolean) ← CRITICAL
- [ ] created_at (timestamp)

Column Verification:
Status: ______________________________
Notes: ______________________________
```

**4.2 employee_locations table** (if exists)
```sql
-- Required columns
- [ ] id (UUID)
- [ ] employee_id (UUID) - FK to employees
- [ ] latitude (float)
- [ ] longitude (float)
- [ ] location (text)
- [ ] status (text)
- [ ] updated_at (timestamp)

Column Verification:
Status: ______________________________
Notes: ______________________________
```

**4.3 attendance table** (for fallback location data)
```sql
-- Check if it has location fields
- [ ] location (text)
- [ ] latitude (float) - optional
- [ ] longitude (float) - optional

Column Verification:
Status: ______________________________
Notes: ______________________________
```

---

## 5. Authentication Flow Verification

### Test Cases:

**Test 5.1: IT User Login**
```
Email: giwore2911@dolofan.com
Password: password123
Expected Dashboard: HRDashboard (IT)
Result: ______________________________
Notes: ______________________________
```

**Test 5.2: Non-IT HR Manager Login**
```
Email: nonithr@company.com
Password: password123
Expected Dashboard: NonITHRDashboard (with location tracking)
Result: ______________________________
Notes: ______________________________
```

**Test 5.3: Non-IT Employee Login**
```
Email: nonitemployee1@company.com
Password: password123
Expected Dashboard: NonITEmployeeDashboard (with own location)
Result: ______________________________
Notes: ______________________________
```

**Test 5.4: Admin/Super Admin Login**
```
Email: nonitadmin@company.com
Password: password123
Expected Dashboard: CompanyDashboard (with all locations)
Result: ______________________________
Notes: ______________________________
```

---

## 6. Frontend Feature Verification

### Non-IT Features to Test:

**Test 6.1: NonITHRDashboard Live Location Button**
```
Action: Login as nonithr@company.com, click "Employee Live Location"
Expected: Navigate to /dashboard/employee-live-location
Shows: List of all employee locations
Result: ______________________________
Notes: ______________________________
```

**Test 6.2: NonITEmployeeDashboard Own Location**
```
Action: Login as nonitemployee1@company.com
Expected: Dashboard shows "Your Live Location" card
Shows: Current location, GPS coordinates, last updated
Result: ______________________________
Notes: ______________________________
```

**Test 6.3: CompanyDashboard All Locations**
```
Action: Login as nonitadmin@company.com
Expected: Dashboard shows all employee and HR locations
Shows: Stats (Total Employees, Online Count, HR Managers)
Result: ______________________________
Notes: ______________________________
```

---

## 7. Issues Found

| Issue # | Component | Severity | Description | Resolution |
|---------|-----------|----------|-------------|------------|
| | | | | |
| | | | | |
| | | | | |

---

## 8. API Response Times

| Endpoint | Response Time | Status |
|----------|---------------|--------|
| /api/auth/signup-non-it | ___ ms | ✓/❌ |
| /api/locations/employee/:id | ___ ms | ✓/❌ |
| /api/locations/company/employees | ___ ms | ✓/❌ |
| /api/locations/company/hr-managers | ___ ms | ✓/❌ |

---

## 9. Security Checks

- [ ] Email verification is enforced
- [ ] Unauthorized users cannot access location data
- [ ] Employees can only see their own location
- [ ] HR managers can see their company's locations only
- [ ] Admins can see all locations (if company admin)
- [ ] No sensitive data leaked in API responses
- [ ] SQL injection protection verified
- [ ] CORS headers configured correctly

---

## 10. Final Recommendations

```
Based on verification findings, recommend:

1. ________________________________________
2. ________________________________________
3. ________________________________________
4. ________________________________________
```

---

## Sign Off

**Verified By:** ________________________  
**Date:** ________________________  
**Status:** ✅ COMPLETE / ⏳ IN PROGRESS / ❌ FAILED

---

## Next Steps
- [ ] Deploy to production if all tests pass
- [ ] Monitor error logs for first 24 hours
- [ ] Gather user feedback
- [ ] Document any issues for next sprint
