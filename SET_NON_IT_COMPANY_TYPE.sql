-- ============================================
-- SUPABASE CONFIGURATION FOR NON-IT USERS
-- ============================================
-- Purpose: Set company_type = 'non-it' for all Non-IT demo users
-- Date: July 16, 2026
-- Action: RUN THIS SCRIPT IN SUPABASE SQL EDITOR

-- Step 1: Update company_type for Non-IT users
UPDATE public.users 
SET company_type = 'non-it' 
WHERE email IN (
  'nonitadmin@company.com',
  'nonithr@company.com',
  'nonitemployee1@company.com',
  'nonitemployee2@company.com',
  'nonitemployee3@company.com'
);

-- Step 2: Verify the update - run this to confirm
SELECT 
  email, 
  role, 
  company_type,
  is_active,
  email_verified,
  created_at
FROM public.users 
WHERE email IN (
  'nonitadmin@company.com',
  'nonithr@company.com',
  'nonitemployee1@company.com',
  'nonitemployee2@company.com',
  'nonitemployee3@company.com'
)
ORDER BY email;

-- Expected Output:
-- ================================================
-- email                      | role        | company_type | is_active | email_verified
-- ================================================
-- nonitadmin@company.com     | super_admin | non-it       | true      | true
-- nonitemployee1@company.com | employee    | non-it       | true      | true
-- nonitemployee2@company.com | employee    | non-it       | true      | true
-- nonitemployee3@company.com | employee    | non-it       | true      | true
-- nonithr@company.com        | hr_manager  | non-it       | true      | true
-- ================================================

-- Step 3: Verify IT users still have correct company_type
SELECT 
  email, 
  role, 
  company_type
FROM public.users 
WHERE email = 'giwore2911@dolofan.com'
   OR email = 'hef8q@dollicons.com'
   OR email = 'zds0i@dollicons.com';

-- Expected Output:
-- ================================================
-- email                      | role        | company_type
-- ================================================
-- giwore2911@dolofan.com     | super_admin | it
-- hef8q@dollicons.com        | hr_manager  | it
-- zds0i@dollicons.com        | employee    | it
-- ================================================
