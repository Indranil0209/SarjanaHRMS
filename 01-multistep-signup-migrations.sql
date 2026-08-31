-- ============================================================================
-- Migration: Multi-Tenant Multi-Step Sign-Up System
-- Description: Adds sector isolation, code tracking, and signup session mgmt
-- ============================================================================

-- Step 1: Extend companies table
-- ============================================================================
ALTER TABLE companies ADD COLUMN IF NOT EXISTS (
    sector VARCHAR(20) DEFAULT 'it' CHECK (sector IN ('it', 'non-it')),
    code_status VARCHAR(20) DEFAULT 'active' CHECK (code_status IN ('active', 'used', 'expired')),
    code_generated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    code_expires_at TIMESTAMP DEFAULT DATE_ADD(CURRENT_TIMESTAMP, INTERVAL 30 DAY),
    admin_user_id VARCHAR(36) UNIQUE,
    registration_status VARCHAR(20) DEFAULT 'active' CHECK (registration_status IN ('pending', 'verified', 'active', 'rejected')),
    spoc_name VARCHAR(255),
    spoc_email VARCHAR(255),
    spoc_phone VARCHAR(20),
    max_employees INT DEFAULT 100,
    subscription_tier VARCHAR(20) DEFAULT 'starter' CHECK (subscription_tier IN ('starter', 'pro', 'enterprise'))
);

-- Step 2: Extend users table
-- ============================================================================
ALTER TABLE users ADD COLUMN IF NOT EXISTS (
    sector VARCHAR(20) CHECK (sector IN ('it', 'non-it')),
    registration_step VARCHAR(50),
    registration_code VARCHAR(20),
    code_verified_at TIMESTAMP NULL,
    onboarding_completed_at TIMESTAMP NULL,
    must_change_password BOOLEAN DEFAULT false
);

-- Step 3: Create company_registration_codes table
-- ============================================================================
CREATE TABLE IF NOT EXISTS company_registration_codes (
    id VARCHAR(36) PRIMARY KEY,
    company_id VARCHAR(36) NOT NULL,
    code VARCHAR(20) UNIQUE NOT NULL,
    code_status VARCHAR(20) NOT NULL DEFAULT 'active' CHECK (code_status IN ('active', 'used', 'expired', 'revoked')),
    generated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    expires_at TIMESTAMP DEFAULT DATE_ADD(CURRENT_TIMESTAMP, INTERVAL 30 DAY),
    used_at TIMESTAMP NULL,
    used_by_user_id VARCHAR(36) NULL,
    usage_count INT DEFAULT 0,
    max_uses INT DEFAULT -1,
    created_by VARCHAR(36),
    notes LONGTEXT,
    
    FOREIGN KEY (company_id) REFERENCES companies(id) ON DELETE CASCADE,
    FOREIGN KEY (used_by_user_id) REFERENCES users(id) ON DELETE SET NULL,
    FOREIGN KEY (created_by) REFERENCES users(id) ON DELETE SET NULL,
    
    INDEX idx_code (code),
    INDEX idx_company_id (company_id),
    INDEX idx_code_status (code_status),
    INDEX idx_expires_at (expires_at)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Step 4: Create code_usage_audit table
-- ============================================================================
CREATE TABLE IF NOT EXISTS code_usage_audit (
    id VARCHAR(36) PRIMARY KEY,
    code_id VARCHAR(36) NOT NULL,
    user_id VARCHAR(36),
    action VARCHAR(50),
    ip_address VARCHAR(45),
    user_agent LONGTEXT,
    metadata JSON,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    
    FOREIGN KEY (code_id) REFERENCES company_registration_codes(id) ON DELETE CASCADE,
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE SET NULL,
    
    INDEX idx_code_id (code_id),
    INDEX idx_created_at (created_at),
    INDEX idx_action (action)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Step 5: Create signup_sessions table
-- ============================================================================
CREATE TABLE IF NOT EXISTS signup_sessions (
    id VARCHAR(36) PRIMARY KEY,
    email VARCHAR(255) UNIQUE NOT NULL,
    sector VARCHAR(20) NOT NULL CHECK (sector IN ('it', 'non-it')),
    role VARCHAR(50) NOT NULL,
    company_id VARCHAR(36),
    company_code VARCHAR(20),
    employee_id VARCHAR(20),
    
    step_current VARCHAR(50),
    step_completed JSON,
    form_data LONGTEXT,  -- Encrypted JSON
    
    started_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    last_activity_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    expires_at TIMESTAMP DEFAULT DATE_ADD(CURRENT_TIMESTAMP, INTERVAL 7 DAY),
    status VARCHAR(50) DEFAULT 'active' CHECK (status IN ('active', 'completed', 'abandoned', 'expired')),
    
    created_user_id VARCHAR(36),
    
    FOREIGN KEY (company_id) REFERENCES companies(id) ON DELETE SET NULL,
    FOREIGN KEY (created_user_id) REFERENCES users(id) ON DELETE SET NULL,
    
    INDEX idx_email (email),
    INDEX idx_status (status),
    INDEX idx_expires_at (expires_at),
    INDEX idx_sector_role (sector, role)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Step 6: Create company_quotas table
-- ============================================================================
CREATE TABLE IF NOT EXISTS company_quotas (
    id VARCHAR(36) PRIMARY KEY,
    company_id VARCHAR(36) UNIQUE NOT NULL,
    
    max_employees INT DEFAULT 100,
    current_employees INT DEFAULT 0,
    
    max_hr_managers INT DEFAULT 5,
    current_hr_managers INT DEFAULT 0,
    
    max_admins INT DEFAULT 2,
    current_admins INT DEFAULT 1,
    
    storage_gb INT DEFAULT 10,
    api_calls_monthly INT DEFAULT 10000,
    
    last_updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    
    FOREIGN KEY (company_id) REFERENCES companies(id) ON DELETE CASCADE,
    INDEX idx_company_id (company_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Step 7: Create indexes for performance
-- ============================================================================
CREATE INDEX IF NOT EXISTS idx_companies_sector ON companies(sector);
CREATE INDEX IF NOT EXISTS idx_companies_code_status ON companies(code_status);
CREATE INDEX IF NOT EXISTS idx_companies_registration_status ON companies(registration_status);
CREATE INDEX IF NOT EXISTS idx_users_sector ON users(sector);
CREATE INDEX IF NOT EXISTS idx_users_registration_step ON users(registration_step);
CREATE INDEX IF NOT EXISTS idx_users_company_id_sector ON users(company_id, sector);

-- Step 8: Add check constraints
-- ============================================================================
ALTER TABLE companies ADD CONSTRAINT chk_company_code_format 
CHECK (company_code REGEXP '^[A-Z0-9]{4}-[A-Z0-9]{10}$');

ALTER TABLE users ADD CONSTRAINT chk_password_set_when_active 
CHECK (
  (password_hash IS NOT NULL AND email_verified = true) 
  OR (password_hash IS NULL AND email_verified = false)
);

-- Step 9: Create views for easier querying
-- ============================================================================

-- View: Active company codes for signup
CREATE OR REPLACE VIEW active_company_codes AS
SELECT 
    crc.id,
    crc.code,
    crc.company_id,
    c.company_name,
    c.sector,
    crc.usage_count,
    crc.max_uses,
    CASE 
        WHEN NOW() > crc.expires_at THEN 'expired'
        WHEN crc.code_status = 'revoked' THEN 'revoked'
        WHEN crc.max_uses > 0 AND crc.usage_count >= crc.max_uses THEN 'limit_reached'
        ELSE 'active'
    END AS effective_status
FROM company_registration_codes crc
JOIN companies c ON crc.company_id = c.id
WHERE crc.code_status IN ('active', 'used') AND NOW() <= crc.expires_at;

-- View: Signup funnel metrics
CREATE OR REPLACE VIEW signup_funnel_metrics AS
SELECT 
    sector,
    role,
    COUNT(*) as total_sessions,
    SUM(CASE WHEN status = 'completed' THEN 1 ELSE 0 END) as completed,
    SUM(CASE WHEN status = 'active' THEN 1 ELSE 0 END) as in_progress,
    SUM(CASE WHEN status = 'abandoned' THEN 1 ELSE 0 END) as abandoned,
    SUM(CASE WHEN status = 'expired' THEN 1 ELSE 0 END) as expired,
    ROUND(
        SUM(CASE WHEN status = 'completed' THEN 1 ELSE 0 END) * 100.0 / COUNT(*),
        2
    ) as completion_rate_percent
FROM signup_sessions
WHERE started_at >= DATE_SUB(NOW(), INTERVAL 30 DAY)
GROUP BY sector, role;

-- Step 10: Create procedures for common operations
-- ============================================================================

-- Procedure: Generate and assign company code
DELIMITER $$
CREATE PROCEDURE sp_generate_company_code(
    IN p_company_id VARCHAR(36),
    IN p_created_by_user_id VARCHAR(36),
    OUT p_generated_code VARCHAR(20),
    OUT p_success BOOLEAN
)
BEGIN
    DECLARE v_code VARCHAR(20);
    DECLARE v_attempts INT DEFAULT 0;
    DECLARE v_max_attempts INT DEFAULT 10;
    DECLARE v_code_exists BOOLEAN;
    
    SET p_success = FALSE;
    
    -- Attempt to generate unique code (up to 10 tries)
    WHILE v_attempts < v_max_attempts DO
        -- Generate code: PREFIX-RANDOM
        SET v_code = CONCAT(
            SUBSTRING('ABCDEFGHJKLMNPQRSTUVWXYZ', FLOOR(RAND()*26)+1, 1),
            SUBSTRING('ABCDEFGHJKLMNPQRSTUVWXYZ', FLOOR(RAND()*26)+1, 1),
            SUBSTRING('ABCDEFGHJKLMNPQRSTUVWXYZ', FLOOR(RAND()*26)+1, 1),
            SUBSTRING('ABCDEFGHJKLMNPQRSTUVWXYZ', FLOOR(RAND()*26)+1, 1),
            '-',
            SUBSTRING('ABCDEFGHJKLMNPQRSTUVWXYZ23456789', FLOOR(RAND()*32)+1, 1),
            SUBSTRING('ABCDEFGHJKLMNPQRSTUVWXYZ23456789', FLOOR(RAND()*32)+1, 1),
            SUBSTRING('ABCDEFGHJKLMNPQRSTUVWXYZ23456789', FLOOR(RAND()*32)+1, 1),
            SUBSTRING('ABCDEFGHJKLMNPQRSTUVWXYZ23456789', FLOOR(RAND()*32)+1, 1),
            SUBSTRING('ABCDEFGHJKLMNPQRSTUVWXYZ23456789', FLOOR(RAND()*32)+1, 1),
            SUBSTRING('ABCDEFGHJKLMNPQRSTUVWXYZ23456789', FLOOR(RAND()*32)+1, 1),
            SUBSTRING('ABCDEFGHJKLMNPQRSTUVWXYZ23456789', FLOOR(RAND()*32)+1, 1),
            SUBSTRING('ABCDEFGHJKLMNPQRSTUVWXYZ23456789', FLOOR(RAND()*32)+1, 1),
            SUBSTRING('ABCDEFGHJKLMNPQRSTUVWXYZ23456789', FLOOR(RAND()*32)+1, 1),
            SUBSTRING('ABCDEFGHJKLMNPQRSTUVWXYZ23456789', FLOOR(RAND()*32)+1, 1)
        );
        
        -- Check if code already exists
        SELECT COUNT(*) > 0 INTO v_code_exists FROM company_registration_codes WHERE code = v_code;
        
        IF NOT v_code_exists THEN
            -- Insert new code
            INSERT INTO company_registration_codes (
                id, company_id, code, code_status, created_by
            ) VALUES (
                UUID(), p_company_id, v_code, 'active', p_created_by_user_id
            );
            
            SET p_generated_code = v_code;
            SET p_success = TRUE;
            LEAVE;
        END IF;
        
        SET v_attempts = v_attempts + 1;
    END WHILE;
END$$
DELIMITER ;

-- Procedure: Validate company code and return company details
DELIMITER $$
CREATE PROCEDURE sp_validate_company_code(
    IN p_code VARCHAR(20),
    OUT p_valid BOOLEAN,
    OUT p_company_id VARCHAR(36),
    OUT p_company_name VARCHAR(255),
    OUT p_sector VARCHAR(20),
    OUT p_error_message VARCHAR(255)
)
BEGIN
    DECLARE v_code_id VARCHAR(36);
    DECLARE v_expires_at TIMESTAMP;
    DECLARE v_usage_count INT;
    DECLARE v_max_uses INT;
    
    SET p_valid = FALSE;
    
    -- Find the code
    SELECT id, company_id, expires_at, usage_count, max_uses
    INTO v_code_id, p_company_id, v_expires_at, v_usage_count, v_max_uses
    FROM company_registration_codes
    WHERE code = p_code AND code_status IN ('active', 'used');
    
    -- Validate code exists
    IF v_code_id IS NULL THEN
        SET p_error_message = 'INVALID_CODE: Code not found or inactive';
        RETURN;
    END IF;
    
    -- Check expiration
    IF NOW() > v_expires_at THEN
        UPDATE company_registration_codes SET code_status = 'expired' WHERE id = v_code_id;
        SET p_error_message = 'CODE_EXPIRED: Code has expired';
        RETURN;
    END IF;
    
    -- Check usage limit
    IF v_max_uses > 0 AND v_usage_count >= v_max_uses THEN
        SET p_error_message = 'CODE_LIMIT_REACHED: Maximum uses exceeded';
        RETURN;
    END IF;
    
    -- Get company details
    SELECT company_name, sector INTO p_company_name, p_sector FROM companies WHERE id = p_company_id;
    
    SET p_valid = TRUE;
END$$
DELIMITER ;

-- Step 11: Verify migrations
-- ============================================================================
SELECT 
    'Companies table' as component,
    (SELECT COUNT(*) FROM information_schema.COLUMNS WHERE TABLE_NAME='companies' AND COLUMN_NAME='sector') as sector_col,
    (SELECT COUNT(*) FROM information_schema.COLUMNS WHERE TABLE_NAME='companies' AND COLUMN_NAME='company_code') as code_col
UNION ALL
SELECT 
    'Users table',
    (SELECT COUNT(*) FROM information_schema.COLUMNS WHERE TABLE_NAME='users' AND COLUMN_NAME='sector'),
    (SELECT COUNT(*) FROM information_schema.COLUMNS WHERE TABLE_NAME='users' AND COLUMN_NAME='registration_step')
UNION ALL
SELECT 
    'Registration codes table',
    (SELECT COUNT(*) FROM information_schema.TABLES WHERE TABLE_NAME='company_registration_codes'),
    0
UNION ALL
SELECT 
    'Signup sessions table',
    (SELECT COUNT(*) FROM information_schema.TABLES WHERE TABLE_NAME='signup_sessions'),
    0
UNION ALL
SELECT 
    'Company quotas table',
    (SELECT COUNT(*) FROM information_schema.TABLES WHERE TABLE_NAME='company_quotas'),
    0;

-- ============================================================================
-- Migration Complete
-- ============================================================================
-- All tables, columns, indexes, views, and procedures created successfully.
-- Next: Deploy backend APIs and frontend components
-- ============================================================================
