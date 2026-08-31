-- ============================================================================
-- ENABLE ALL DISABLED USERS
-- ============================================================================
-- This script enables all users that are currently disabled (is_active = false)

-- 1. Enable all users
UPDATE users SET is_active = true WHERE is_active = false;

-- 2. Verify all users are now active
SELECT email, is_active, role, company_type FROM users ORDER BY email;

-- 3. Enable all companies
UPDATE companies SET is_active = true WHERE is_active = false;

-- 4. Check specific Non-IT employees
SELECT id, email, full_name, is_active, company_type FROM users 
WHERE email LIKE 'nonit%' OR company_type = 'non-it';

-- 5. Enable specific employees if needed
UPDATE users SET is_active = true 
WHERE email IN (
  'nonitemployee1@company.com',
  'nonitemployee2@company.com',
  'nonitemployee3@company.com',
  'nonithr@company.com',
  'nonitadmin@company.com'
);

-- 6. Verify email verification status
UPDATE users SET email_verified = true WHERE email_verified = false;

-- 7. Final check - show all users
SELECT 
  email, 
  full_name, 
  role, 
  company_type, 
  is_active, 
  email_verified,
  created_at
FROM users 
ORDER BY email;
