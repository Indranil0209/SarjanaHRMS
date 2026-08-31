-- ============================================================================
-- FIX: Set IT Super Admin to company_type = 'it'
-- ============================================================================
-- Problem: giwore2911@dolofan.com has company_type='non-it' (WRONG)
-- Should be: company_type='it' (IT Company)
-- ============================================================================

-- Step 1: Check current value
SELECT email, company_type, role, full_name FROM users 
WHERE email = 'giwore2911@dolofan.com';

-- Step 2: Update to 'it'
UPDATE users 
SET company_type = 'it' 
WHERE email = 'giwore2911@dolofan.com';

-- Step 3: Verify the fix
SELECT email, company_type, role, full_name FROM users 
WHERE email = 'giwore2911@dolofan.com';

-- Step 4: Also check other IT demo users
SELECT email, company_type, role FROM users 
WHERE email IN (
  'giwore2911@dolofan.com',
  'hef8q@dollicons.com',
  'zds0i@dollicons.com'
);

-- Expected result:
-- giwore2911@dolofan.com  | it | super_admin
-- hef8q@dollicons.com     | it | hr_manager
-- zds0i@dollicons.com     | it | employee
