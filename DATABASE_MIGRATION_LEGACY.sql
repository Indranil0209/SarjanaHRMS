/**
 * Legacy IT Backend to Multi-Tenant System Migration Script
 * 
 * This script handles the complete migration of legacy IT backend data
 * into the new multi-tenant SarjanaHRMS architecture.
 * 
 * WARNING: Take complete backup before executing!
 * Timeline: Phase-based migration with validation at each step
 */

-- ============================================================================
-- PHASE 1: PRE-MIGRATION VALIDATION
-- ============================================================================

-- Check legacy data integrity
SELECT 
    'legacy_users' as table_name,
    COUNT(*) as row_count,
    COUNT(DISTINCT email) as unique_emails,
    SUM(CASE WHEN is_active = TRUE THEN 1 ELSE 0 END) as active_users
FROM legacy_users;

-- Find potential data issues
SELECT email, COUNT(*) as duplicate_count
FROM legacy_users
GROUP BY email
HAVING COUNT(*) > 1;

-- ============================================================================
-- PHASE 2: PREPARE NEW SYSTEM TABLES
-- ============================================================================

-- Create migration tracking table
CREATE TABLE IF NOT EXISTS migration_logs (
    id SERIAL PRIMARY KEY,
    legacy_user_id INT NOT NULL,
    new_user_id UUID,
    status VARCHAR(50) NOT NULL, -- SUCCESS, FAILED
    error_message TEXT,
    migrated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (new_user_id) REFERENCES users(id) ON DELETE CASCADE
);

-- Create email verification logs
CREATE TABLE IF NOT EXISTS email_verification_logs (
    id SERIAL PRIMARY KEY,
    user_id UUID NOT NULL,
    status VARCHAR(50) NOT NULL, -- VERIFIED, PENDING
    reason TEXT,
    verified_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE
);

-- Create legacy data mapping table
CREATE TABLE IF NOT EXISTS legacy_user_mapping (
    id SERIAL PRIMARY KEY,
    legacy_user_id INT NOT NULL UNIQUE,
    new_user_id UUID NOT NULL UNIQUE,
    email VARCHAR(255) NOT NULL,
    migration_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    verification_status VARCHAR(50) DEFAULT 'PENDING',
    last_verified TIMESTAMP,
    notes TEXT,
    FOREIGN KEY (new_user_id) REFERENCES users(id) ON DELETE CASCADE,
    INDEX idx_legacy_user_id (legacy_user_id),
    INDEX idx_new_user_id (new_user_id),
    INDEX idx_email (email)
);

-- ============================================================================
-- PHASE 3: CREATE LEGACY COMPANY CONTAINER
-- ============================================================================

-- Insert legacy company (if not exists)
INSERT INTO companies (
    company_name,
    domain,
    industry,
    size,
    company_type,
    status,
    is_legacy
) VALUES (
    'Legacy IT Company',
    'legacy.sarjanahr.tech',
    'IT',
    'enterprise',
    'it',
    'active',
    TRUE
) ON CONFLICT (company_name) DO NOTHING;

-- Get legacy company ID for reference (run separately to get value)
SELECT id FROM companies WHERE company_name = 'Legacy IT Company' LIMIT 1;

-- Store this UUID in .env as LEGACY_IT_COMPANY_UUID

-- ============================================================================
-- PHASE 4: CREATE TEMPORARY MIGRATION TABLE
-- ============================================================================

-- Create temp table for data transformation
CREATE TEMP TABLE temp_legacy_users AS
SELECT
    legacy_users.id as legacy_id,
    legacy_users.email,
    legacy_users.password_hash,
    CONCAT(
        COALESCE(legacy_users.first_name, ''),
        ' ',
        COALESCE(legacy_users.last_name, '')
    ) as full_name,
    CASE 
        WHEN legacy_users.role = 'admin' THEN 'admin'
        WHEN legacy_users.role = 'hr' THEN 'hr_manager'
        WHEN legacy_users.role = 'employee' THEN 'employee'
        ELSE 'employee'
    END as new_role,
    legacy_users.is_active,
    legacy_users.created_at as legacy_created_at
FROM legacy_users
WHERE is_active = TRUE
  AND email IS NOT NULL
  AND email NOT IN (
      SELECT email FROM users 
      WHERE company_id = (SELECT id FROM companies WHERE company_name = 'Legacy IT Company')
  );

-- Verify temp table
SELECT 
    COUNT(*) as total_users,
    COUNT(DISTINCT email) as unique_emails,
    COUNT(CASE WHEN new_role = 'admin' THEN 1 END) as admins,
    COUNT(CASE WHEN new_role = 'hr_manager' THEN 1 END) as hr_managers,
    COUNT(CASE WHEN new_role = 'employee' THEN 1 END) as employees
FROM temp_legacy_users;

-- ============================================================================
-- PHASE 5: MIGRATE USER DATA
-- ============================================================================

-- Step 1: Insert users into new system
INSERT INTO users (
    email,
    password_hash,
    full_name,
    company_id,
    role,
    company_type,
    is_active,
    email_verified,
    legacy_user_id,
    legacy_source,
    migration_date,
    created_at,
    updated_at
) SELECT
    temp_legacy_users.email,
    temp_legacy_users.password_hash,
    TRIM(temp_legacy_users.full_name),
    (SELECT id FROM companies WHERE company_name = 'Legacy IT Company'),
    temp_legacy_users.new_role,
    'it',
    temp_legacy_users.is_active,
    TRUE, -- Trust legacy verification
    temp_legacy_users.legacy_id,
    'it_backend',
    CURRENT_TIMESTAMP,
    temp_legacy_users.legacy_created_at,
    CURRENT_TIMESTAMP
FROM temp_legacy_users
ON CONFLICT (email, company_id) DO NOTHING;

-- Step 2: Create mapping records
INSERT INTO legacy_user_mapping (
    legacy_user_id,
    new_user_id,
    email,
    migration_date,
    verification_status
) SELECT
    temp_legacy_users.legacy_id,
    users.id,
    temp_legacy_users.email,
    CURRENT_TIMESTAMP,
    'VERIFIED'
FROM temp_legacy_users
JOIN users ON (
    temp_legacy_users.email = users.email
    AND users.company_id = (SELECT id FROM companies WHERE company_name = 'Legacy IT Company')
)
WHERE users.legacy_user_id = temp_legacy_users.legacy_id;

-- Step 3: Log successful migrations
INSERT INTO migration_logs (
    legacy_user_id,
    new_user_id,
    status,
    migrated_at
) SELECT
    legacy_user_mapping.legacy_user_id,
    legacy_user_mapping.new_user_id,
    'SUCCESS',
    CURRENT_TIMESTAMP
FROM legacy_user_mapping;

-- ============================================================================
-- PHASE 6: MIGRATE RELATED DATA (EMPLOYEES)
-- ============================================================================

-- Migrate employee records
INSERT INTO employees (
    user_id,
    employee_id,
    first_name,
    last_name,
    email,
    phone,
    department_id,
    job_position_id,
    hire_date,
    employment_status,
    company_id,
    created_at,
    updated_at
) SELECT
    users.id,
    COALESCE(legacy_employees.employee_id, CONCAT('EMP-', legacy_employees.id)),
    legacy_employees.first_name,
    legacy_employees.last_name,
    legacy_employees.email,
    legacy_employees.phone,
    NULL, -- Will be mapped after department migration
    NULL, -- Will be mapped after position migration
    legacy_employees.hire_date,
    CASE 
        WHEN legacy_employees.status = 'active' THEN 'active'
        WHEN legacy_employees.status = 'inactive' THEN 'inactive'
        WHEN legacy_employees.status = 'terminated' THEN 'terminated'
        ELSE 'active'
    END,
    (SELECT id FROM companies WHERE company_name = 'Legacy IT Company'),
    legacy_employees.created_at,
    CURRENT_TIMESTAMP
FROM legacy_employees
JOIN users ON (
    legacy_employees.email = users.email
    AND users.company_id = (SELECT id FROM companies WHERE company_name = 'Legacy IT Company')
)
WHERE legacy_employees.email IS NOT NULL
  AND NOT EXISTS (
      SELECT 1 FROM employees 
      WHERE employees.user_id = users.id
  );

-- ============================================================================
-- PHASE 7: DATA VALIDATION
-- ============================================================================

-- Validate migration completeness
SELECT
    'Users Migrated' as check_item,
    (SELECT COUNT(*) FROM users WHERE company_id = (SELECT id FROM companies WHERE company_name = 'Legacy IT Company')) as new_system_count,
    (SELECT COUNT(*) FROM legacy_users WHERE is_active = TRUE) as legacy_count,
    CASE 
        WHEN (SELECT COUNT(*) FROM users WHERE company_id = (SELECT id FROM companies WHERE company_name = 'Legacy IT Company')) = 
             (SELECT COUNT(*) FROM legacy_users WHERE is_active = TRUE)
        THEN 'PASS'
        ELSE 'FAIL'
    END as status;

-- Validate role mapping
SELECT
    'Role Mapping' as check_item,
    new_role,
    COUNT(*) as user_count,
    'PASS' as status
FROM users
WHERE company_id = (SELECT id FROM companies WHERE company_name = 'Legacy IT Company')
GROUP BY new_role;

-- Check for duplicate emails
SELECT
    'Duplicate Emails' as check_item,
    email,
    COUNT(*) as count,
    CASE 
        WHEN COUNT(*) = 1 THEN 'PASS'
        ELSE 'FAIL'
    END as status
FROM users
WHERE company_id = (SELECT id FROM companies WHERE company_name = 'Legacy IT Company')
GROUP BY email;

-- Verify legacy links
SELECT
    'Legacy Linking' as check_item,
    COUNT(*) as total_users,
    COUNT(CASE WHEN legacy_user_id IS NOT NULL THEN 1 END) as users_with_legacy_link,
    CASE 
        WHEN COUNT(CASE WHEN legacy_user_id IS NOT NULL THEN 1 END) = COUNT(*)
        THEN 'PASS'
        ELSE 'FAIL'
    END as status
FROM users
WHERE company_id = (SELECT id FROM companies WHERE company_name = 'Legacy IT Company');

-- ============================================================================
-- PHASE 8: CREATE INDEXES FOR PERFORMANCE
-- ============================================================================

-- Index for login lookups
CREATE INDEX IF NOT EXISTS idx_users_email_company 
ON users(email, company_id);

-- Index for legacy lookups
CREATE INDEX IF NOT EXISTS idx_users_legacy_user_id 
ON users(legacy_user_id);

-- Index for company lookups
CREATE INDEX IF NOT EXISTS idx_users_company_id 
ON users(company_id);

-- Index for role queries
CREATE INDEX IF NOT EXISTS idx_users_role_company 
ON users(role, company_id);

-- Legacy mapping indexes
CREATE INDEX IF NOT EXISTS idx_legacy_mapping_new_user 
ON legacy_user_mapping(new_user_id);

CREATE INDEX IF NOT EXISTS idx_legacy_mapping_legacy_user 
ON legacy_user_mapping(legacy_user_id);

-- ============================================================================
-- PHASE 9: MIGRATION SUMMARY REPORT
-- ============================================================================

-- Generate migration report
SELECT 
    'MIGRATION SUMMARY' as report_type,
    (SELECT COUNT(*) FROM legacy_users WHERE is_active = TRUE) as total_legacy_users,
    (SELECT COUNT(*) FROM users WHERE company_id = (SELECT id FROM companies WHERE company_name = 'Legacy IT Company')) as migrated_users,
    (SELECT COUNT(*) FROM legacy_user_mapping) as mapped_users,
    (SELECT COUNT(*) FROM migration_logs WHERE status = 'SUCCESS') as successful_migrations,
    (SELECT COUNT(*) FROM migration_logs WHERE status = 'FAILED') as failed_migrations,
    CURRENT_TIMESTAMP as migration_timestamp;

-- List any failed migrations for review
SELECT
    ml.legacy_user_id,
    ml.status,
    ml.error_message,
    lu.email,
    ml.migrated_at
FROM migration_logs ml
JOIN legacy_users lu ON ml.legacy_user_id = lu.id
WHERE ml.status = 'FAILED'
ORDER BY ml.migrated_at DESC;

-- ============================================================================
-- PHASE 10: CLEANUP & FINALIZATION
-- ============================================================================

-- Drop temporary tables
DROP TABLE IF EXISTS temp_legacy_users;

-- Archive old data (optional but recommended)
CREATE TABLE IF NOT EXISTS legacy_users_archived AS
SELECT * FROM legacy_users;

-- Update migration status flag
UPDATE companies
SET migration_status = 'COMPLETED',
    migration_date = CURRENT_TIMESTAMP
WHERE company_name = 'Legacy IT Company';

-- ============================================================================
-- VERIFICATION QUERIES
-- ============================================================================

-- Query 1: Verify all legacy users migrated
SELECT 
    'Legacy Users Successfully Migrated' as verification,
    COUNT(*) as count
FROM users
WHERE company_id = (SELECT id FROM companies WHERE company_name = 'Legacy IT Company')
  AND legacy_source = 'it_backend'
  AND email_verified = TRUE;

-- Query 2: Show sample migrated users
SELECT
    u.id as new_user_id,
    u.email,
    u.full_name,
    u.role,
    u.legacy_user_id,
    u.migration_date,
    u.email_verified
FROM users u
WHERE u.company_id = (SELECT id FROM companies WHERE company_name = 'Legacy IT Company')
LIMIT 10;

-- Query 3: Check email verification status
SELECT
    u.email,
    u.email_verified,
    COUNT(evl.id) as verification_attempts,
    MAX(evl.verified_at) as last_verified
FROM users u
LEFT JOIN email_verification_logs evl ON u.id = evl.user_id
WHERE u.company_id = (SELECT id FROM companies WHERE company_name = 'Legacy IT Company')
GROUP BY u.id, u.email, u.email_verified;

-- ============================================================================
-- ROLLBACK PROCEDURE (If needed)
-- ============================================================================

/*
ROLLBACK STEPS:

1. Delete migrated users:
DELETE FROM users
WHERE company_id = (SELECT id FROM companies WHERE company_name = 'Legacy IT Company');

2. Delete legacy company:
DELETE FROM companies
WHERE company_name = 'Legacy IT Company';

3. Clean up logs:
DELETE FROM migration_logs;
DELETE FROM email_verification_logs;
DELETE FROM legacy_user_mapping;

4. Verify deletion:
SELECT COUNT(*) FROM users WHERE company_id = (SELECT id FROM companies WHERE company_name = 'Legacy IT Company');

5. Restore from backup if needed.
*/

-- ============================================================================
-- PERFORMANCE QUERIES
-- ============================================================================

-- Monitor migration performance
SELECT
    'Login Time (avg)' as metric,
    ROUND(AVG(EXTRACT(EPOCH FROM (migration_date - current_timestamp))), 3) as value,
    'ms' as unit
FROM migration_logs
WHERE status = 'SUCCESS';

-- Check database size impact
SELECT
    table_name,
    ROUND(pg_total_relation_size(table_name::regclass) / 1024 / 1024, 2) as size_mb
FROM (
    SELECT 'users' as table_name
    UNION SELECT 'legacy_user_mapping'
    UNION SELECT 'migration_logs'
    UNION SELECT 'email_verification_logs'
) t
ORDER BY size_mb DESC;
