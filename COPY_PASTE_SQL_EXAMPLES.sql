-- ============================================================
-- COPY & PASTE SQL EXAMPLES FOR USER AND ROLE MANAGEMENT
-- Just copy the section you need and paste into Supabase SQL Editor
-- ============================================================

-- ============================================================
-- SECTION 1: CHECK YOUR SETUP
-- ============================================================

-- Check if user_role enum exists and what roles are available
SELECT enum_range(NULL::user_role) as available_roles;

-- Check what companies exist (you'll need IDs for user assignment)
SELECT id, company_name, status 
FROM companies 
LIMIT 10;

-- Check existing users
SELECT id, email, full_name, role, is_active, created_at
FROM users
ORDER BY created_at DESC;


-- ============================================================
-- SECTION 2: CREATE SUPER ADMIN USER
-- ============================================================
-- Prerequisites: 
-- 1. Create Auth user: admin@company.com in Supabase Console
-- 2. Copy the User ID from Auth console
-- 3. Replace 'YOUR_USER_ID_HERE' below with copied ID

INSERT INTO users (
  id,
  email,
  full_name,
  first_name,
  last_name,
  role,
  is_active,
  email_verified
)
VALUES (
  'YOUR_USER_ID_HERE',
  'admin@company.com',
  'System Administrator',
  'System',
  'Admin',
  'super_admin'::user_role,
  true,
  true
);


-- ============================================================
-- SECTION 3: CREATE ADMIN USER
-- ============================================================

INSERT INTO users (
  id,
  email,
  full_name,
  first_name,
  last_name,
  role,
  is_active,
  email_verified
)
VALUES (
  'YOUR_USER_ID_HERE',
  'administrator@company.com',
  'Company Administrator',
  'Company',
  'Admin',
  'admin'::user_role,
  true,
  true
);


-- ============================================================
-- SECTION 4: CREATE HR MANAGER USER
-- ============================================================
-- Note: HR Manager must belong to a company
-- First run this to get your company ID:
-- SELECT id, company_name FROM companies LIMIT 1;

INSERT INTO users (
  id,
  email,
  full_name,
  first_name,
  last_name,
  role,
  is_active,
  email_verified,
  company_id
)
VALUES (
  'YOUR_USER_ID_HERE',
  'hr.manager@company.com',
  'HR Manager',
  'HR',
  'Manager',
  'hr_manager'::user_role,
  true,
  true,
  'YOUR_COMPANY_ID_HERE'
);


-- ============================================================
-- SECTION 5: CREATE EMPLOYEE USER
-- ============================================================

INSERT INTO users (
  id,
  email,
  full_name,
  first_name,
  last_name,
  role,
  is_active,
  email_verified,
  company_id
)
VALUES (
  'YOUR_USER_ID_HERE',
  'employee@company.com',
  'John Employee',
  'John',
  'Employee',
  'employee'::user_role,
  true,
  true,
  'YOUR_COMPANY_ID_HERE'
);


-- ============================================================
-- SECTION 6: CREATE MULTIPLE USERS AT ONCE
-- ============================================================
-- This creates 4 demo users with different roles
-- Replace the UUIDs and company ID with your actual values

INSERT INTO users (
  id,
  email,
  full_name,
  first_name,
  last_name,
  role,
  is_active,
  email_verified,
  company_id
)
VALUES
  (
    'SUPER_ADMIN_UUID_HERE',
    'super-admin-demo@company.com',
    'Super Admin Demo',
    'Super',
    'Admin',
    'super_admin'::user_role,
    true,
    true,
    NULL
  ),
  (
    'ADMIN_UUID_HERE',
    'admin-demo@company.com',
    'Admin Demo',
    'Admin',
    'Demo',
    'admin'::user_role,
    true,
    true,
    NULL
  ),
  (
    'HR_MANAGER_UUID_HERE',
    'hr-demo@company.com',
    'HR Manager Demo',
    'HR',
    'Demo',
    'hr_manager'::user_role,
    true,
    true,
    'YOUR_COMPANY_ID_HERE'
  ),
  (
    'EMPLOYEE_UUID_HERE',
    'employee-demo@company.com',
    'Employee Demo',
    'Employee',
    'Demo',
    'employee'::user_role,
    true,
    true,
    'YOUR_COMPANY_ID_HERE'
  );


-- ============================================================
-- SECTION 7: UPDATE USER ROLE
-- ============================================================
-- Change an existing user's role

-- Change to super_admin
UPDATE users 
SET role = 'super_admin'::user_role,
    updated_at = NOW()
WHERE email = 'employee@company.com';

-- Change to admin
UPDATE users 
SET role = 'admin'::user_role,
    updated_at = NOW()
WHERE email = 'employee@company.com';

-- Change to hr_manager
UPDATE users 
SET role = 'hr_manager'::user_role,
    updated_at = NOW()
WHERE email = 'employee@company.com';

-- Change to employee
UPDATE users 
SET role = 'employee'::user_role,
    updated_at = NOW()
WHERE email = 'someone@company.com';


-- ============================================================
-- SECTION 8: UPDATE USER ACTIVE STATUS
-- ============================================================

-- Deactivate a user
UPDATE users 
SET is_active = false,
    updated_at = NOW()
WHERE email = 'employee@company.com';

-- Reactivate a user
UPDATE users 
SET is_active = true,
    updated_at = NOW()
WHERE email = 'employee@company.com';


-- ============================================================
-- SECTION 9: UPDATE USER PROFILE INFO
-- ============================================================

UPDATE users
SET 
  full_name = 'Updated Full Name',
  first_name = 'Updated First',
  last_name = 'Updated Last',
  phone_number = '+1234567890',
  updated_at = NOW()
WHERE email = 'user@company.com';


-- ============================================================
-- SECTION 10: ASSIGN USER TO COMPANY
-- ============================================================

UPDATE users
SET 
  company_id = 'YOUR_COMPANY_ID_HERE',
  updated_at = NOW()
WHERE email = 'employee@company.com';


-- ============================================================
-- SECTION 11: QUERY USERS BY ROLE
-- ============================================================

-- Get all super admins
SELECT id, email, full_name, created_at
FROM users
WHERE role = 'super_admin'::user_role
ORDER BY created_at DESC;

-- Get all admins
SELECT id, email, full_name, created_at
FROM users
WHERE role = 'admin'::user_role
ORDER BY created_at DESC;

-- Get all HR managers
SELECT id, email, full_name, company_id, created_at
FROM users
WHERE role = 'hr_manager'::user_role
ORDER BY created_at DESC;

-- Get all employees
SELECT id, email, full_name, company_id, created_at
FROM users
WHERE role = 'employee'::user_role
ORDER BY created_at DESC;


-- ============================================================
-- SECTION 12: DETAILED USER INFO WITH COMPANY
-- ============================================================

SELECT 
  u.id,
  u.email,
  u.full_name,
  u.first_name,
  u.last_name,
  u.role,
  u.is_active,
  u.email_verified,
  u.created_at,
  u.phone_number,
  c.id as company_id,
  c.company_name,
  c.industry,
  c.status
FROM users u
LEFT JOIN companies c ON u.company_id = c.id
ORDER BY u.created_at DESC;


-- ============================================================
-- SECTION 13: COUNT USERS BY ROLE AND COMPANY
-- ============================================================

SELECT 
  c.company_name,
  u.role,
  COUNT(u.id) as total_users,
  STRING_AGG(u.email, ', ') as emails
FROM users u
LEFT JOIN companies c ON u.company_id = c.id
GROUP BY c.company_name, u.role
ORDER BY c.company_name, u.role;


-- ============================================================
-- SECTION 14: FIND A SPECIFIC USER
-- ============================================================

-- By email
SELECT id, email, full_name, role, is_active, company_id, created_at
FROM users
WHERE email = 'user@company.com';

-- By name
SELECT id, email, full_name, role, is_active, company_id, created_at
FROM users
WHERE full_name ILIKE '%john%';

-- By ID (UUID)
SELECT id, email, full_name, role, is_active, company_id, created_at
FROM users
WHERE id = 'YOUR_UUID_HERE';


-- ============================================================
-- SECTION 15: DELETE USER PROFILE
-- ============================================================
-- This deletes the user profile only
-- You must delete the Auth user separately from Supabase Auth console
-- BE CAREFUL - This cannot be undone!

DELETE FROM users 
WHERE email = 'user.to.delete@company.com';


-- ============================================================
-- SECTION 16: VERIFY USER WAS CREATED
-- ============================================================

SELECT 
  id,
  email,
  full_name,
  role,
  is_active,
  email_verified,
  created_at
FROM users
WHERE email = 'your-newly-created-email@company.com';


-- ============================================================
-- SECTION 17: CHECK FOR DUPLICATE EMAILS
-- ============================================================

SELECT email, COUNT(*) as count
FROM users
GROUP BY email
HAVING COUNT(*) > 1;


-- ============================================================
-- SECTION 18: GET SUMMARY STATISTICS
-- ============================================================

SELECT 
  COUNT(*) as total_users,
  COUNT(CASE WHEN role = 'super_admin'::user_role THEN 1 END) as super_admins,
  COUNT(CASE WHEN role = 'admin'::user_role THEN 1 END) as admins,
  COUNT(CASE WHEN role = 'hr_manager'::user_role THEN 1 END) as hr_managers,
  COUNT(CASE WHEN role = 'employee'::user_role THEN 1 END) as employees,
  COUNT(CASE WHEN is_active = true THEN 1 END) as active_users,
  COUNT(CASE WHEN is_active = false THEN 1 END) as inactive_users
FROM users;


-- ============================================================
-- SECTION 19: EXPORT USER DATA
-- ============================================================
-- Get all user data in a readable format for export

SELECT 
  u.id,
  u.email,
  u.full_name,
  u.first_name,
  u.last_name,
  u.phone_number,
  u.role::text as role,
  u.is_active,
  u.email_verified,
  COALESCE(c.company_name, 'N/A') as company,
  u.created_at,
  u.updated_at
FROM users u
LEFT JOIN companies c ON u.company_id = c.id
ORDER BY u.created_at DESC;


-- ============================================================
-- REMEMBER:
-- 1. Always create Auth user FIRST in Supabase Console
-- 2. Copy the UUID from Auth user list
-- 3. Use that UUID in the 'id' field when inserting
-- 4. Role must be cast to user_role type: 'super_admin'::user_role
-- 5. Email must be unique in the users table
-- 6. is_active and email_verified default to true for new users
-- ============================================================
