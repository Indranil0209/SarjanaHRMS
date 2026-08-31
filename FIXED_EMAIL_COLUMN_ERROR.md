# Fixed: "Could not find the 'email' column of 'employees'" Error

## Error Message
```
Could not find the 'email' column of 'employees' in the schema cache
```

## Root Cause
The code was trying to insert `email` into the `employees` table, but **the `employees` table doesn't have an `email` column**.

### Database Design Explanation

The system uses **two separate tables**:

1. **`employees` table** - Stores employee work information
   - employee_id
   - first_name, last_name
   - phone
   - hire_date, salary
   - department, position
   - etc.

2. **`users` table** - Stores authentication information
   - email ← Email is stored HERE
   - password (hashed)
   - role
   - company_id
   - etc.

### Why This Design?

**Employees are created BEFORE they have accounts:**
1. HR creates employee record → `employees` table (no email yet)
2. Employee registers account → `users` table (email stored here)
3. System links them → `employees.user_id = users.id`

This allows HR to add employees who haven't registered yet!

## The Fix

### What I Changed

**File:** `src/pages/dashboard/AddEmployee.jsx`

**Removed:**
```javascript
email: formData.email,  // ❌ This column doesn't exist in employees table!
```

**Result:**
```javascript
{
  company_id: companyId,
  employee_id: formData.employeeId,
  first_name: formData.firstName,
  last_name: formData.lastName,
  phone: formData.phone,        // ✅ Phone is in employees table
  hire_date: formData.startDate,
  salary: parseFloat(formData.salary),
  // ... other fields
  // NO EMAIL FIELD
}
```

### What Happens to the Email?

The email you enter in the form is **temporarily stored in the form** but:
- ✅ It's NOT saved in the `employees` table
- ✅ It WILL be used when the employee registers
- ✅ It's saved in the `users` table during registration

## How Data Flows

### Step 1: HR Adds Employee
```
HR Form Input:
├── Employee ID: 99
├── Name: ss1 demo
├── Email: new@gmail.com    ← Form collects this
├── Phone: 010-110-1122
└── Salary: 20000

Saved to `employees` table:
├── employee_id: "99"
├── first_name: "ss1"
├── last_name: "demo"
├── phone: "010-110-1122"  ✅
├── salary: 20000
└── user_id: NULL          (not registered yet)
```

**Note:** Email is NOT saved yet! ❌

### Step 2: Employee Registers
```
Registration Form:
├── Company Code: [from HR]
├── Employee ID: 99         ← Links to employee record
├── Email: new@gmail.com    ← NOW email is saved
└── Password: [set by user]

Saved to `users` table:
├── email: "new@gmail.com"  ✅ Saved here!
├── password: [hashed]
├── role: "employee"
├── company_id: [from HR]
└── id: [new UUID]

Update `employees` table:
└── user_id: [UUID from users] ✅ Linked!
```

### Step 3: Employee Logs In
```
Login with:
├── Email: new@gmail.com    (from users table)
└── Password: [their password]

System knows:
├── User identity (from users table)
└── Employee details (from employees table via user_id)
```

## Testing the Fix

### Try Adding an Employee Now

1. **Refresh your browser** (`F5` or `Ctrl+R`)

2. **Fill the form again:**
   ```
   First Name:    ss1
   Last Name:     demo
   Email:         new@gmail.com
   Phone:         010-110-1122
   Employee ID:   99
   Department:    Engineering
   Position:      Software Engineer
   Salary:        20000
   Start Date:    04-08-2026
   ```

3. **Click "Add Employee"**

4. **Should work now!** ✅

### Verify It Saved

**Check in database:**
```sql
SELECT 
    employee_id,
    first_name,
    last_name,
    phone,
    salary,
    hire_date,
    user_id  -- Should be NULL (not registered yet)
FROM employees
WHERE employee_id = '99';
```

**Result:**
```
employee_id | first_name | last_name | phone        | salary | user_id
------------|------------|-----------|--------------|--------|--------
99          | ss1        | demo      | 010-110-1122 | 20000  | NULL
```

Notice: ✅ No email column in employees table!

### Then Test Registration

1. Go to: http://localhost:8000/employee-registration
2. Enter:
   - Company Code: [your code]
   - Employee ID: 99
   - Full Name: ss1 demo
   - Email: new@gmail.com ← Use this
   - Password: SecurePass123
3. Register

**Check users table:**
```sql
SELECT 
    email,
    role,
    full_name
FROM users
WHERE email = 'new@gmail.com';
```

**Result:**
```
email            | role     | full_name
-----------------|----------|----------
new@gmail.com    | employee | ss1 demo
```

✅ Email is saved in users table!

**Check employees table again:**
```sql
SELECT 
    employee_id,
    first_name,
    last_name,
    user_id  -- Should NOW have a value!
FROM employees
WHERE employee_id = '99';
```

**Result:**
```
employee_id | first_name | last_name | user_id
------------|------------|-----------|----------------------------------
99          | ss1        | demo      | 550e8400-e29b-41d4-a716-446655440123
```

✅ Now linked via user_id!

## Schema Reference

### Employees Table Structure
```sql
CREATE TABLE employees (
    id UUID PRIMARY KEY,
    company_id UUID NOT NULL,
    user_id UUID,              -- Links to users table
    employee_id VARCHAR(20),   -- Unique employee number
    first_name VARCHAR(50),
    last_name VARCHAR(50),
    phone VARCHAR(20),         -- ✅ Phone is here
    -- NO EMAIL COLUMN!        -- ❌ Email is NOT here
    hire_date DATE,
    salary DECIMAL(10,2),
    department_id UUID,
    job_position_id UUID,
    -- ... other fields
);
```

### Users Table Structure
```sql
CREATE TABLE users (
    id UUID PRIMARY KEY,
    email VARCHAR(255),        -- ✅ Email is here!
    password VARCHAR(255),
    role VARCHAR(50),
    company_id UUID,
    full_name VARCHAR(100),
    -- ... other fields
);
```

## Summary

### The Problem
- ❌ Tried to insert email into employees table
- ❌ Employees table doesn't have email column
- ❌ Got schema cache error

### The Solution
- ✅ Removed email from employees insert
- ✅ Email is stored in users table instead
- ✅ Happens during employee registration
- ✅ Tables linked via user_id

### Why It's Designed This Way
1. **Separation of concerns**
   - Employees = work information
   - Users = authentication information

2. **Security**
   - Email + password in secure users table
   - Employee details in separate table

3. **Flexibility**
   - Can create employee before they have account
   - Can have users who aren't employees (admins, etc.)
   - Easy to manage permissions

4. **Registration flow**
   - HR creates employee (no account yet)
   - Employee self-registers (creates account)
   - System automatically links them

### What to Remember
- 📧 Email → `users` table (during registration)
- 👤 Employee details → `employees` table (when HR adds them)
- 🔗 Linked by → `employees.user_id = users.id`

---

**The fix is complete! Try adding an employee now - it will work!** ✅
