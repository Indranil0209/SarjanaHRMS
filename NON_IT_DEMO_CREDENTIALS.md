# Non-IT Demo Credentials

This document provides all demo credentials for testing the Non-IT portal of the Sarjana HRMS system.

## Overview

The Non-IT portal is a specialized login interface for non-IT companies that includes location tracking and live employee tracking features. This is distinct from the IT company portal which uses a different login page.

## Setup Instructions

### 1. Import the SQL File

To set up the Non-IT demo credentials in your database, run the SQL file:

```bash
psql -U your_user -d your_database -f non_it_demo_credentials.sql
```

Or if using a GUI tool like pgAdmin:
1. Open `non_it_demo_credentials.sql`
2. Copy all content
3. Execute in your database query tool

### 2. Verify Installation

After running the SQL, verify the demo data by querying:

```sql
SELECT * FROM users WHERE company_id = 'c550e8400-e29b-41d4-a716-446655440001';
```

You should see 5 users created for the Non-IT company.

## Demo Credentials

### Non-IT Company Demo Data

**Company Name:** Non-IT Services Company  
**Company ID:** `c550e8400-e29b-41d4-a716-446655440001`  
**Portal URL:** `http://localhost:5173/login-non-it`

### Login Credentials

All demo users use the password: **`password123`**

#### 1. Super Admin
- **Email:** `nonitadmin@company.com`
- **Password:** `password123`
- **Name:** Non-IT Admin
- **Role:** Super Admin
- **Access:** Full system access, company settings, user management

#### 2. HR Manager
- **Email:** `nonithr@company.com`
- **Password:** `password123`
- **Name:** Non-IT HR Manager
- **Role:** HR Manager
- **Access:** HR functions, employee management, leave approvals, payroll

#### 3. Employee 1 (Store Manager)
- **Email:** `nonitemployee1@company.com`
- **Password:** `password123`
- **Name:** Priya Sharma
- **Role:** Employee
- **Department:** Retail Operations
- **Position:** Store Manager
- **Access:** Employee dashboard, location tracking, leave requests

#### 4. Employee 2 (Sales Associate)
- **Email:** `nonitemployee2@company.com`
- **Password:** `password123`
- **Name:** Rajesh Patel
- **Role:** Employee
- **Department:** Retail Operations
- **Position:** Sales Associate
- **Access:** Employee dashboard, location tracking, leave requests

#### 5. Employee 3 (Sales Associate)
- **Email:** `nonitemployee3@company.com`
- **Password:** `password123`
- **Name:** Anjali Verma
- **Role:** Employee
- **Department:** Retail Operations
- **Position:** Sales Associate
- **Access:** Employee dashboard, location tracking, leave requests

## Company Structure

### Departments
- **Retail Operations** - Store operations and customer service
- **Human Resources** - People management and HR services
- **Sales & Marketing** - Sales and marketing initiatives
- **Finance** - Financial operations

### Job Positions
- Store Manager (Grade A)
- Sales Associate (Grade C)
- HR Coordinator (Grade B)
- Delivery Driver (Grade C)

### Employee Information
All employees are configured with:
- **Salary:** 250,000 - 600,000 INR (depending on role)
- **Hire Date:** January - February 2024
- **Status:** Active
- **Leave Balance:** 20 annual leaves each

## Login URLs

### IT Company Portal
```
http://localhost:5173/login
```
Credentials: admin@company.com / password123

### Non-IT Company Portal
```
http://localhost:5173/login-non-it
```
Credentials: nonitadmin@company.com / password123

## Features Available in Non-IT Portal

✓ Real-time Location Tracking  
✓ Live Employee Location Display  
✓ Location History  
✓ Employee Tracking Dashboard  
✓ Leave Management  
✓ Attendance Tracking  
✓ Payroll Management  
✓ Performance Reviews  
✓ Team Directory  

## Testing Scenarios

### Scenario 1: Super Admin Setup
1. Log in with Super Admin credentials
2. Verify company settings
3. Check employee list and locations
4. Configure company policies

### Scenario 2: HR Manager Operations
1. Log in with HR Manager credentials
2. View and approve leave requests
3. Process payroll
4. View employee records
5. Track employee locations

### Scenario 3: Employee Portal
1. Log in with Employee credentials
2. Check location tracking status
3. Submit leave request
4. View payslip
5. Check team directory

## Database Details

### Bcrypt Hash Information
- **Password:** `password123`
- **Bcrypt Hash:** `$2a$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi`

### UUIDs Used
- Company ID: `c550e8400-e29b-41d4-a716-446655440001`
- User IDs: `550e8400-e29b-41d4-a716-446655440020` to `550e8400-e29b-41d4-a716-446655440024`
- Employee IDs: `e550e8400-e29b-41d4-a716-446655440020` to `e550e8400-e29b-41d4-a716-446655440024`
- Department IDs: `d550e8400-e29b-41d4-a716-446655440010` to `d550e8400-e29b-41d4-a716-446655440013`

## Common Tasks

### Change Password
To change a demo user's password:
```sql
UPDATE users SET password_hash = 'new_hash' WHERE email = 'nonitadmin@company.com';
```

### Deactivate User
```sql
UPDATE users SET is_active = false WHERE email = 'nonitemployee1@company.com';
```

### Reset All Demo Data
To reset all Non-IT demo data:
```sql
DELETE FROM leave_balances WHERE company_id = 'c550e8400-e29b-41d4-a716-446655440001';
DELETE FROM employees WHERE company_id = 'c550e8400-e29b-41d4-a716-446655440001';
DELETE FROM job_positions WHERE company_id = 'c550e8400-e29b-41d4-a716-446655440001';
DELETE FROM departments WHERE company_id = 'c550e8400-e29b-41d4-a716-446655440001';
DELETE FROM users WHERE company_id = 'c550e8400-e29b-41d4-a716-446655440001';
DELETE FROM companies WHERE id = 'c550e8400-e29b-41d4-a716-446655440001';
```

Then re-run the SQL file.

## Troubleshooting

### Login Failed
- Verify credentials are correct
- Check if user is active: `SELECT * FROM users WHERE email = 'nonitadmin@company.com';`
- Verify company is active: `SELECT * FROM companies WHERE id = 'c550e8400-e29b-41d4-a716-446655440001';`

### Missing Employees
- Verify employees are created: `SELECT * FROM employees WHERE company_id = 'c550e8400-e29b-41d4-a716-446655440001';`
- Check for foreign key constraints

### Location Tracking Not Working
- Verify `tracking_enabled` is true in company settings
- Check browser location permissions
- Verify GPS is enabled on device

## Support

For issues or questions:
1. Check the SQL error messages
2. Verify all foreign keys are satisfied
3. Check Kiro browser console for JavaScript errors
4. Review server logs for API errors

---

**Last Updated:** July 16, 2026  
**Version:** 1.0  
**Status:** Ready for Testing
