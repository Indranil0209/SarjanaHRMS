-- ========================================================
-- QUICK SCRIPT: Add Test Employee Records
-- ========================================================
-- Use this script to add employee records so they can register
-- Replace the company_id with your actual company ID
-- ========================================================

-- Step 1: Find your company ID and company code
-- Run this first to get your company information
SELECT 
    id as company_id,
    name as company_name,
    company_code
FROM companies
ORDER BY created_at DESC
LIMIT 5;

-- ========================================================
-- Step 2: Insert Test Employees
-- Replace 'YOUR_COMPANY_ID_HERE' with actual company ID from Step 1
-- ========================================================

-- Test Employee 1: John Doe
INSERT INTO employees (
    company_id,
    employee_id,
    first_name,
    last_name,
    date_of_birth,
    gender,
    phone,
    hire_date,
    employment_status,
    work_location
) VALUES (
    'YOUR_COMPANY_ID_HERE',  -- ⚠️ REPLACE THIS with your company ID
    'EMP123',                -- Employee can register with this ID
    'John',
    'Doe',
    '1990-01-15',
    'Male',
    '+1234567890',
    CURRENT_DATE,
    'active',
    'Main Office'
);

-- Test Employee 2: Jane Smith
INSERT INTO employees (
    company_id,
    employee_id,
    first_name,
    last_name,
    date_of_birth,
    gender,
    phone,
    hire_date,
    employment_status,
    work_location
) VALUES (
    'YOUR_COMPANY_ID_HERE',  -- ⚠️ REPLACE THIS with your company ID
    'EMP456',                -- Employee can register with this ID
    'Jane',
    'Smith',
    '1992-05-20',
    'Female',
    '+1234567891',
    CURRENT_DATE,
    'active',
    'Main Office'
);

-- Test Employee 3: Bob Johnson
INSERT INTO employees (
    company_id,
    employee_id,
    first_name,
    last_name,
    date_of_birth,
    gender,
    phone,
    hire_date,
    employment_status,
    work_location
) VALUES (
    'YOUR_COMPANY_ID_HERE',  -- ⚠️ REPLACE THIS with your company ID
    'EMP789',                -- Employee can register with this ID
    'Bob',
    'Johnson',
    '1988-03-10',
    'Male',
    '+1234567892',
    CURRENT_DATE,
    'active',
    'Remote'
);

-- ========================================================
-- Step 3: Verify the records were created
-- ========================================================
SELECT 
    employee_id,
    first_name,
    last_name,
    phone,
    hire_date,
    employment_status,
    user_id  -- Should be NULL (not registered yet)
FROM employees
WHERE employee_id IN ('EMP123', 'EMP456', 'EMP789')
ORDER BY employee_id;

-- ========================================================
-- INSTRUCTIONS FOR EMPLOYEE REGISTRATION:
-- ========================================================
-- After running this script, employees can register at:
-- http://localhost:8000/employee-registration
--
-- They need:
-- 1. Company Code (from Step 1 query above)
-- 2. Employee ID (EMP123, EMP456, or EMP789)
-- 3. Their email address
-- 4. Create a password
--
-- Example registration:
-- - Company Code: [From your database]
-- - Employee ID: EMP123
-- - Full Name: John Doe
-- - Email: john.doe@company.com
-- - Password: SecurePass123
-- ========================================================

-- ========================================================
-- BONUS: Add employees with department and position
-- (Optional - only if you have departments and positions set up)
-- ========================================================

-- First, check available departments
-- SELECT id, name FROM departments;

-- Then check available job positions
-- SELECT id, title FROM job_positions;

-- Insert employee with department and position
-- INSERT INTO employees (
--     company_id,
--     employee_id,
--     first_name,
--     last_name,
--     department_id,      -- From departments query
--     job_position_id,    -- From job_positions query
--     hire_date,
--     salary,
--     employment_status
-- ) VALUES (
--     'YOUR_COMPANY_ID_HERE',
--     'EMP999',
--     'Alice',
--     'Williams',
--     'YOUR_DEPARTMENT_ID',
--     'YOUR_POSITION_ID',
--     CURRENT_DATE,
--     65000.00,
--     'active'
-- );
