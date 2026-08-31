-- ========================================================
-- DATABASE CLEANUP - KEEP ONLY SPECIFIED USERS
-- ========================================================
-- This script removes all demo/test users except the ones specified
-- ========================================================

-- ========================================================
-- STEP 1: BACKUP - View current users before deletion
-- ========================================================

-- Check all current users
SELECT 
    email,
    role,
    full_name,
    company_id,
    is_active,
    created_at
FROM users
ORDER BY email;

-- Count before cleanup
SELECT COUNT(*) as total_users FROM users;

-- ========================================================
-- STEP 2: DELETE USERS (KEEP ONLY SPECIFIED ONES)
-- ========================================================

-- IT Company - Keep only these 3 users:
-- 1. giwore2911@dolofan.com (Super Admin)
-- 2. hef8q@dollicons.com (HR Manager)
-- 3. zds0i@dollicons.com (Employee)

-- Non-IT Company - Keep only these 3 users:
-- 1. nonitadmin@company.com (Super Admin)
-- 2. nonithr@company.com (HR Manager)
-- 3. nonitemployee1@company.com (Employee)

BEGIN;

-- Delete all users EXCEPT the 6 we want to keep
DELETE FROM users 
WHERE email NOT IN (
    'giwore2911@dolofan.com',
    'hef8q@dollicons.com',
    'zds0i@dollicons.com',
    'nonitadmin@company.com',
    'nonithr@company.com',
    'nonitemployee1@company.com'
);

COMMIT;

-- ========================================================
-- STEP 3: VERIFY DELETION
-- ========================================================

-- Should show only 6 users now
SELECT 
    email,
    role,
    full_name,
    is_active
FROM users
ORDER BY email;

-- Count after cleanup (should be 6)
SELECT COUNT(*) as remaining_users FROM users;

-- ========================================================
-- STEP 4: CLEAN UP RELATED EMPLOYEE RECORDS
-- ========================================================

-- Delete employees that don't have a corresponding user
-- (except those who are pending registration)
DELETE FROM employees 
WHERE user_id IS NOT NULL 
AND user_id NOT IN (SELECT id FROM users);

-- ========================================================
-- STEP 5: VIEW FINAL STATE
-- ========================================================

-- IT Company Users
SELECT 
    u.email,
    u.role,
    u.full_name,
    c.name as company_name,
    c.company_code
FROM users u
LEFT JOIN companies c ON u.company_id = c.id
WHERE u.email IN (
    'giwore2911@dolofan.com',
    'hef8q@dollicons.com',
    'zds0i@dollicons.com'
)
ORDER BY u.email;

-- Non-IT Company Users
SELECT 
    u.email,
    u.role,
    u.full_name,
    c.name as company_name,
    c.company_code
FROM users u
LEFT JOIN companies c ON u.company_id = c.id
WHERE u.email IN (
    'nonitadmin@company.com',
    'nonithr@company.com',
    'nonitemployee1@company.com'
)
ORDER BY u.email;

-- ========================================================
-- OPTIONAL: DELETE FROM AUTH.USERS (SUPABASE AUTH)
-- ========================================================
-- Note: This requires admin/service role access
-- Run this in Supabase Dashboard SQL Editor with service_role

/*
-- Delete auth users except the 6 we want to keep
DELETE FROM auth.users 
WHERE email NOT IN (
    'giwore2911@dolofan.com',
    'hef8q@dollicons.com',
    'zds0i@dollicons.com',
    'nonitadmin@company.com',
    'nonithr@company.com',
    'nonitemployee1@company.com'
);
*/

-- ========================================================
-- SUMMARY OF KEPT USERS
-- ========================================================

SELECT 
    'IT Company' as company_type,
    COUNT(*) as user_count
FROM users
WHERE email IN (
    'giwore2911@dolofan.com',
    'hef8q@dollicons.com',
    'zds0i@dollicons.com'
)
UNION ALL
SELECT 
    'Non-IT Company' as company_type,
    COUNT(*) as user_count
FROM users
WHERE email IN (
    'nonitadmin@company.com',
    'nonithr@company.com',
    'nonitemployee1@company.com'
);

-- ========================================================
-- ROLLBACK (UNCOMMENT IF YOU MADE A MISTAKE)
-- ========================================================
-- ROLLBACK;
