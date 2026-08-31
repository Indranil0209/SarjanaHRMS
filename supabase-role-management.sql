-- ==============================================
-- SUPABASE ROLE MANAGEMENT SQL HELPERS
-- ==============================================

-- ===== 1. VIEW ALL USERS WITH ROLES =====
-- Use this to see all users and their roles
SELECT 
  id,
  email,
  full_name,
  role,
  is_active,
  email_verified,
  company_id,
  created_at,
  updated_at
FROM users
ORDER BY created_at DESC;

-- ===== 2. VIEW USERS GROUPED BY ROLE =====
-- Count how many users in each role
SELECT 
  role,
  COUNT(*) as total_users,
  STRING_AGG(email, ', ') as emails
FROM users
GROUP BY role
ORDER BY role;

-- ===== 3. CREATE SUPER ADMIN USER =====
-- Replace USER_ID with actual UUID from Supabase Auth
-- Example: INSERT INTO users...
-- Make sure to create the Auth user first!
-- INSERT INTO users (
--   id, 
--   email, 
--   full_name, 
--   first_name,
--   last_name,
--   role, 
--   is_active, 
--   email_verified
-- ) 
-- VALUES (
--   'USER_UUID_HERE',
--   'super-admin@company.com',
--   'Super Admin Name',
--   'Super',
--   'Admin',
--   'super_admin'::user_role,
--   true,
--   true
-- );

-- ===== 4. CREATE ADMIN USER =====
-- INSERT INTO users (
--   id, 
--   email, 
--   full_name, 
--   first_name,
--   last_name,
--   role, 
--   is_active, 
--   email_verified
-- ) 
-- VALUES (
--   'USER_UUID_HERE',
--   'admin@company.com',
--   'Admin Name',
--   'Admin',
--   'User',
--   'admin'::user_role,
--   true,
--   true
-- );

-- ===== 5. CREATE HR MANAGER USER =====
-- INSERT INTO users (
--   id, 
--   email, 
--   full_name, 
--   first_name,
--   last_name,
--   role, 
--   is_active, 
--   email_verified,
--   company_id
-- ) 
-- VALUES (
--   'USER_UUID_HERE',
--   'hr-manager@company.com',
--   'HR Manager Name',
--   'HR',
--   'Manager',
--   'hr_manager'::user_role,
--   true,
--   true,
--   'COMPANY_UUID_HERE'
-- );

-- ===== 6. CREATE EMPLOYEE USER =====
-- INSERT INTO users (
--   id, 
--   email, 
--   full_name, 
--   first_name,
--   last_name,
--   role, 
--   is_active, 
--   email_verified,
--   company_id
-- ) 
-- VALUES (
--   'USER_UUID_HERE',
--   'employee@company.com',
--   'Employee Name',
--   'Employee',
--   'Last',
--   'employee'::user_role,
--   true,
--   true,
--   'COMPANY_UUID_HERE'
-- );

-- ===== 7. UPDATE USER ROLE =====
-- Change a user's role to super_admin
-- UPDATE users 
-- SET role = 'super_admin'::user_role
-- WHERE email = 'user@company.com';

-- Change a user's role to admin
-- UPDATE users 
-- SET role = 'admin'::user_role
-- WHERE email = 'user@company.com';

-- Change a user's role to hr_manager
-- UPDATE users 
-- SET role = 'hr_manager'::user_role
-- WHERE email = 'user@company.com';

-- Change a user's role to employee
-- UPDATE users 
-- SET role = 'employee'::user_role
-- WHERE email = 'user@company.com';

-- ===== 8. DEACTIVATE USER =====
-- UPDATE users 
-- SET is_active = false
-- WHERE email = 'user@company.com';

-- ===== 9. REACTIVATE USER =====
-- UPDATE users 
-- SET is_active = true
-- WHERE email = 'user@company.com';

-- ===== 10. DELETE USER PROFILE =====
-- Note: This deletes the profile but NOT the auth user
-- You must delete auth user from Supabase Auth console separately
-- DELETE FROM users WHERE email = 'user@company.com';

-- ===== 11. FIND USER BY EMAIL =====
-- SELECT * FROM users WHERE email = 'user@company.com';

-- ===== 12. FIND USER BY ID =====
-- SELECT * FROM users WHERE id = 'UUID_HERE';

-- ===== 13. VERIFY ENUM TYPE EXISTS =====
-- This shows the available user_role enum values
SELECT enum_range(NULL::user_role) as available_roles;

-- ===== 14. CREATE MULTIPLE DEMO USERS =====
-- Example with all roles (replace UUIDs with actual values from Auth)
-- INSERT INTO users (
--   id, 
--   email, 
--   full_name, 
--   first_name,
--   last_name,
--   role, 
--   is_active, 
--   email_verified,
--   company_id,
--   phone_number
-- ) 
-- VALUES
--   ('550e8400-e29b-41d4-a716-446655440010', 'demo-super-admin@company.com', 'Demo Super Admin', 'Demo', 'SuperAdmin', 'super_admin'::user_role, true, true, NULL, '+1234567890'),
--   ('550e8400-e29b-41d4-a716-446655440011', 'demo-admin@company.com', 'Demo Admin', 'Demo', 'Admin', 'admin'::user_role, true, true, 'COMPANY_UUID', '+1234567890'),
--   ('550e8400-e29b-41d4-a716-446655440012', 'demo-hr@company.com', 'Demo HR Manager', 'Demo', 'HR', 'hr_manager'::user_role, true, true, 'COMPANY_UUID', '+1234567890'),
--   ('550e8400-e29b-41d4-a716-446655440013', 'demo-employee@company.com', 'Demo Employee', 'Demo', 'Employee', 'employee'::user_role, true, true, 'COMPANY_UUID', '+1234567890');

-- ===== 15. GET USER DETAILS WITH COMPANY INFO =====
-- SELECT 
--   u.id,
--   u.email,
--   u.full_name,
--   u.role,
--   u.is_active,
--   u.created_at,
--   c.company_name,
--   c.industry
-- FROM users u
-- LEFT JOIN companies c ON u.company_id = c.id
-- ORDER BY u.created_at DESC;

-- ===== IMPORTANT NOTES =====
-- 1. Always create Auth user FIRST before creating user profile
-- 2. Copy the exact UUID from Supabase Auth > Users
-- 3. Role values must be EXACT: 'super_admin', 'admin', 'hr_manager', 'employee'
-- 4. Always cast role to user_role type: 'super_admin'::user_role
-- 5. Email must be unique in the users table
-- 6. company_id can be NULL for super_admin (system-wide access)
-- 7. Use email in WHERE clauses to identify users (unique field)
