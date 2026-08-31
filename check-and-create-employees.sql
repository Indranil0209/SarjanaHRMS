-- ========================================
-- CHECK CURRENT USERS IN DATABASE
-- ========================================

-- 1. Check all users
SELECT 
  id, 
  email, 
  full_name, 
  role, 
  is_active,
  company_id,
  created_at
FROM users
ORDER BY created_at DESC;

-- 2. Count users by role
SELECT 
  role, 
  COUNT(*) as count
FROM users
GROUP BY role;

-- 3. Check if you have an HR Manager
SELECT 
  email, 
  full_name, 
  company_id
FROM users 
WHERE role = 'hr_manager' 
LIMIT 1;

-- ========================================
-- CREATE TEST EMPLOYEES
-- ========================================

-- Option 1: If you have a company_id, use it (replace YOUR_COMPANY_ID)
-- First, find your company_id:
SELECT id, company_name FROM companies LIMIT 5;

-- Then insert employees with that company_id:
/*
INSERT INTO users (email, full_name, role, is_active, company_id)
VALUES 
  ('employee1@company.com', 'Alice Johnson', 'employee', true, 'YOUR_COMPANY_ID'),
  ('employee2@company.com', 'Bob Smith', 'employee', true, 'YOUR_COMPANY_ID'),
  ('employee3@company.com', 'Carol Davis', 'employee', true, 'YOUR_COMPANY_ID'),
  ('employee4@company.com', 'David Wilson', 'employee', true, 'YOUR_COMPANY_ID'),
  ('employee5@company.com', 'Emma Brown', 'employee', true, 'YOUR_COMPANY_ID');
*/

-- Option 2: Insert without company_id (simpler, works with the fix I made)
INSERT INTO users (email, full_name, role, is_active)
VALUES 
  ('alice.johnson@company.com', 'Alice Johnson', 'employee', true),
  ('bob.smith@company.com', 'Bob Smith', 'employee', true),
  ('carol.davis@company.com', 'Carol Davis', 'employee', true),
  ('david.wilson@company.com', 'David Wilson', 'employee', true),
  ('emma.brown@company.com', 'Emma Brown', 'employee', true)
ON CONFLICT (email) DO NOTHING;

-- ========================================
-- VERIFY EMPLOYEES WERE CREATED
-- ========================================

-- Check employees only
SELECT 
  email, 
  full_name, 
  role, 
  is_active
FROM users
WHERE role = 'employee'
ORDER BY full_name;

-- Count total employees
SELECT COUNT(*) as total_employees
FROM users
WHERE role = 'employee';
