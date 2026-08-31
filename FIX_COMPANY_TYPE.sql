-- ============================================================================
-- FIX COMPANY_TYPE VALUES FOR LOGIN BLOCKING
-- ============================================================================
-- Run this in Supabase SQL Editor to set correct company_type values
-- This ensures login blocking works correctly

-- Step 1: Set company_type for Non-IT employees
UPDATE users SET company_type = 'non-it' 
WHERE email IN (
  'nonitadmin@company.com',
  'nonitemployee1@company.com',
  'nonitemployee2@company.com',
  'nonitemployee3@company.com',
  'nonithr@company.com',
  'bashamohassin@gmail.com'
);

-- Step 2: Set company_type for IT employees
UPDATE users SET company_type = 'it' 
WHERE email IN (
  'giwore2911@dolofan.com',
  'hef8q@dollicons.com',
  'zds0i@dollicons.com'
);

-- Step 3: Verify the fix was successful
SELECT 
  email, 
  company_type, 
  is_active,
  CASE 
    WHEN company_type = 'non-it' THEN '✓ Can use Non-IT portal'
    WHEN company_type = 'it' THEN '✓ Can use IT portal'
    ELSE '❌ ERROR'
  END as status
FROM users 
WHERE email IN (
  'nonitadmin@company.com',
  'nonitemployee1@company.com',
  'nonitemployee2@company.com',
  'nonitemployee3@company.com',
  'nonithr@company.com',
  'bashamohassin@gmail.com',
  'giwore2911@dolofan.com',
  'hef8q@dollicons.com',
  'zds0i@dollicons.com'
)
ORDER BY email;

