-- ============================================================================
-- VERIFY COMPANY_TYPE VALUES FOR LOGIN BLOCKING
-- ============================================================================
-- Run this in Supabase SQL Editor to check if company_type is set correctly

-- 1. Show all users with company_type
SELECT 
  email, 
  company_type, 
  is_active, 
  email_verified,
  CASE 
    WHEN company_type = 'non-it' THEN '✓ Non-IT Portal Only'
    WHEN company_type = 'it' THEN '✓ IT Portal Only'
    WHEN company_type IS NULL THEN '⚠️ NULL (Defaults to IT)'
    ELSE '❌ ' || company_type
  END as portal_access
FROM users 
ORDER BY email;

-- 2. Count by company_type
SELECT 
  company_type,
  COUNT(*) as count
FROM users
GROUP BY company_type;

-- 3. Show IT portal users (company_type = 'it' or NULL)
SELECT email, company_type FROM users 
WHERE company_type = 'it' OR company_type IS NULL
ORDER BY email;

-- 4. Show Non-IT portal users (company_type = 'non-it')
SELECT email, company_type FROM users 
WHERE company_type = 'non-it'
ORDER BY email;

-- 5. Check for any unusual company_type values
SELECT DISTINCT company_type FROM users;

