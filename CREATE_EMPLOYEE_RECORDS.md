# How to Create Employee Records for Registration

## Problem
You're seeing this error: **"No employee record found matching this Employee ID"**

This happens because the system requires HR/Admin to create employee records BEFORE employees can register their accounts.

## Solution: Create Employee Records First

### Step 1: Login as HR Manager or Admin

Use one of these accounts:
- **HR Manager:** `sarah.hr@company.com` / `password123`
- **Admin:** `admin@company.com` / `password123`

### Step 2: Create Employee Record via HR Dashboard

1. Navigate to the HR Dashboard
2. Look for "Add Employee" or "Employee Management" section
3. Fill in employee details including:
   - Employee ID (e.g., EMP123)
   - First Name
   - Last Name
   - Department
   - Hire Date
   - etc.

### Step 3: Employee Can Now Register

Once the HR/Admin creates the employee record, the employee can:
1. Go to the employee registration page
2. Enter their Company Code
3. Enter their Employee ID (the one created by HR)
4. Fill in email and password
5. Complete registration

---

## Alternative: Add Employee Record Directly via SQL

If you don't have the HR dashboard ready, you can add employee records directly to the database:

### Quick SQL Script

```sql
-- First, get your company_id
SELECT id, name, company_code FROM companies;

-- Insert a test employee record
INSERT INTO employees (
    company_id,
    employee_id,
    first_name,
    last_name,
    hire_date,
    employment_status
) VALUES (
    'YOUR_COMPANY_ID_HERE',  -- Replace with actual company ID from above query
    'EMP123',                -- This is the Employee ID the user will enter
    'John',                  -- First name
    'Doe',                   -- Last name
    CURRENT_DATE,            -- Hire date
    'active'                 -- Employment status
);
```

### Example with Complete Data

```sql
-- Insert employee with full details
INSERT INTO employees (
    company_id,
    employee_id,
    first_name,
    last_name,
    date_of_birth,
    gender,
    phone,
    address,
    emergency_contact_name,
    emergency_contact_phone,
    hire_date,
    salary,
    employment_status,
    work_location
) VALUES (
    'c550e8400-e29b-41d4-a716-446655440000',  -- Your company ID
    'EMP123',                                  -- Employee ID (user enters this)
    'John',
    'Doe',
    '1990-01-15',
    'Male',
    '+1234567890',
    '123 Main St, City, State 12345',
    'Jane Doe',
    '+1234567891',
    '2024-08-20',
    75000.00,
    'active',
    'Main Office'
);
```

### Verify the Record Was Created

```sql
SELECT 
    employee_id,
    first_name,
    last_name,
    hire_date,
    employment_status
FROM employees
WHERE employee_id = 'EMP123';
```

---

## Test the Registration Flow

1. **Create Employee Record** (via HR Dashboard or SQL above)
   - Employee ID: `EMP123`
   - Name: John Doe

2. **Get Your Company Code**
   ```sql
   SELECT company_code FROM companies LIMIT 1;
   ```

3. **Go to Employee Registration Page**
   - URL: http://localhost:8000/employee-registration

4. **Fill the Registration Form**
   - Company Code: (from step 2)
   - Employee ID: `EMP123`
   - Email: john.doe@company.com
   - Password: SecurePass123
   - Confirm Password: SecurePass123
   - Full Name: John Doe

5. **Submit** - Should work now! ✅

---

## Common Issues

### Issue 1: "No employee record found"
**Cause:** Employee ID doesn't exist in database
**Solution:** Create the employee record first using HR dashboard or SQL script above

### Issue 2: "Company code not found"
**Cause:** Invalid company code
**Solution:** Get the correct company code from database:
```sql
SELECT id, name, company_code FROM companies;
```

### Issue 3: "Employee already registered"
**Cause:** This employee_id is already linked to a user account
**Solution:** Use a different employee_id or check if the account already exists

---

## Best Practice Workflow

1. **HR/Admin creates employee records** when someone is hired
2. **HR sends employee their Employee ID** via email or orientation
3. **Employee uses Employee ID to register** their own account
4. **System links the account** to the existing employee record

This ensures data integrity and proper employee onboarding!
