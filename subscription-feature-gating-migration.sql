-- ===================================================================
-- SARJANA HRMS: Subscription & Feature Gating Migration
-- ===================================================================
-- This migration creates the subscription and feature gating system
-- with 4 pricing tiers: FREE_TRIAL, STANDARD, POWER, PREMIUM
-- ===================================================================

-- Enable UUID extension if not already enabled
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- ===================================================================
-- 1. CREATE SUBSCRIPTION PACKAGES TABLE
-- ===================================================================
CREATE TABLE IF NOT EXISTS subscription_packages (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    package_name VARCHAR(50) UNIQUE NOT NULL,
    display_name VARCHAR(100) NOT NULL,
    description TEXT,
    price_per_employee_per_day DECIMAL(10,2) NOT NULL DEFAULT 0,
    features JSONB NOT NULL DEFAULT '[]',
    is_active BOOLEAN DEFAULT true,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- ===================================================================
-- 2. SEED SUBSCRIPTION PACKAGES WITH 4 TIERS
-- ===================================================================

-- Clear existing packages if any
TRUNCATE TABLE subscription_packages CASCADE;

-- Tier 1: FREE TRIAL
INSERT INTO subscription_packages (package_name, display_name, description, price_per_employee_per_day, features) VALUES
(
    'FREE_TRIAL',
    'Free Trial',
    'Perfect for testing - 14 days free access to basic HRMS features',
    0,
    '["EMPLOYEE_MGMT", "BASIC_ATTENDANCE", "BASIC_REPORTS"]'::jsonb
);

-- Tier 2: STANDARD
INSERT INTO subscription_packages (package_name, display_name, description, price_per_employee_per_day, features) VALUES
(
    'STANDARD',
    'Standard HRMS',
    'Perfect for growing companies with essential HR needs',
    4,
    '["EMPLOYEE_MGMT", "BASIC_ATTENDANCE", "BASIC_PAYROLL", "MOBILE_APP", "CUSTOM_WORKFLOWS"]'::jsonb
);

-- Tier 3: POWER
INSERT INTO subscription_packages (package_name, display_name, description, price_per_employee_per_day, features) VALUES
(
    'POWER',
    'Power HRMS',
    'Advanced tools for data-driven HR management',
    7,
    '["EMPLOYEE_MGMT", "BASIC_ATTENDANCE", "ADVANCED_PAYROLL", "AI_ANALYTICS", "CUSTOM_REPORTS", "API_ACCESS"]'::jsonb
);

-- Tier 4: PREMIUM
INSERT INTO subscription_packages (package_name, display_name, description, price_per_employee_per_day, features) VALUES
(
    'PREMIUM',
    'Premium HRMS',
    'Complete solution with live tracking and real-time verification',
    9,
    '["EMPLOYEE_MGMT", "BASIC_ATTENDANCE", "ADVANCED_PAYROLL", "AI_ANALYTICS", "LIVE_LOCATION_TRACKING", "REALTIME_FACE_VERIFICATION", "COMPLIANCE_TOOLS"]'::jsonb
);

-- ===================================================================
-- 3. CREATE COMPANY SUBSCRIPTIONS TABLE
-- ===================================================================
CREATE TABLE IF NOT EXISTS company_subscriptions (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    company_id UUID NOT NULL REFERENCES companies(id) ON DELETE CASCADE,
    package_id UUID NOT NULL REFERENCES subscription_packages(id) ON DELETE RESTRICT,
    unique_license_code VARCHAR(20) UNIQUE NOT NULL,
    employee_count INTEGER NOT NULL DEFAULT 1,
    duration_days INTEGER NOT NULL DEFAULT 1,
    total_amount DECIMAL(12,2) NOT NULL DEFAULT 0,
    payment_status VARCHAR(20) NOT NULL DEFAULT 'PENDING' CHECK (payment_status IN ('PENDING', 'PAID', 'EXPIRED', 'CANCELLED')),
    payment_method VARCHAR(50),
    payment_transaction_id VARCHAR(100),
    activated_at TIMESTAMP WITH TIME ZONE,
    expires_at TIMESTAMP WITH TIME ZONE,
    auto_renew BOOLEAN DEFAULT false,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    created_by UUID REFERENCES users(id),
    CONSTRAINT positive_employee_count CHECK (employee_count > 0),
    CONSTRAINT positive_duration CHECK (duration_days > 0)
);

-- ===================================================================
-- 4. CREATE INDEXES FOR PERFORMANCE
-- ===================================================================
CREATE INDEX IF NOT EXISTS idx_company_subscriptions_company ON company_subscriptions(company_id);
CREATE INDEX IF NOT EXISTS idx_company_subscriptions_package ON company_subscriptions(package_id);
CREATE INDEX IF NOT EXISTS idx_company_subscriptions_license ON company_subscriptions(unique_license_code);
CREATE INDEX IF NOT EXISTS idx_company_subscriptions_status ON company_subscriptions(payment_status);
CREATE INDEX IF NOT EXISTS idx_company_subscriptions_expires ON company_subscriptions(expires_at);

-- ===================================================================
-- 5. CREATE FUNCTION TO GENERATE UNIQUE LICENSE CODES
-- ===================================================================
CREATE OR REPLACE FUNCTION generate_unique_license_code(package_prefix VARCHAR)
RETURNS VARCHAR AS $$
DECLARE
    new_code VARCHAR(20);
    code_exists BOOLEAN;
BEGIN
    LOOP
        -- Generate format: SRJ-{PREFIX}-{8_RANDOM_CHARS}
        new_code := 'SRJ-' || package_prefix || '-' || 
                    UPPER(SUBSTRING(MD5(RANDOM()::TEXT || CLOCK_TIMESTAMP()::TEXT) FROM 1 FOR 8));
        
        -- Check if code already exists
        SELECT EXISTS(
            SELECT 1 FROM company_subscriptions WHERE unique_license_code = new_code
        ) INTO code_exists;
        
        -- Exit loop if unique code found
        EXIT WHEN NOT code_exists;
    END LOOP;
    
    RETURN new_code;
END;
$$ LANGUAGE plpgsql;

-- ===================================================================
-- 6. CREATE FUNCTION TO CHECK FEATURE ACCESS
-- ===================================================================
CREATE OR REPLACE FUNCTION check_company_feature_access(
    p_company_id UUID,
    p_feature_name VARCHAR
)
RETURNS BOOLEAN AS $$
DECLARE
    has_access BOOLEAN := false;
BEGIN
    -- Check if company has an active subscription with the required feature
    SELECT EXISTS(
        SELECT 1
        FROM company_subscriptions cs
        JOIN subscription_packages sp ON cs.package_id = sp.id
        WHERE cs.company_id = p_company_id
        AND cs.payment_status = 'PAID'
        AND cs.expires_at > NOW()
        AND sp.features @> to_jsonb(ARRAY[p_feature_name])
    ) INTO has_access;
    
    RETURN has_access;
END;
$$ LANGUAGE plpgsql;

-- ===================================================================
-- 7. CREATE UPDATED_AT TRIGGER FUNCTION
-- ===================================================================
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- ===================================================================
-- 8. APPLY TRIGGERS
-- ===================================================================
DROP TRIGGER IF EXISTS update_subscription_packages_updated_at ON subscription_packages;
CREATE TRIGGER update_subscription_packages_updated_at
    BEFORE UPDATE ON subscription_packages
    FOR EACH ROW
    EXECUTE FUNCTION update_updated_at_column();

DROP TRIGGER IF EXISTS update_company_subscriptions_updated_at ON company_subscriptions;
CREATE TRIGGER update_company_subscriptions_updated_at
    BEFORE UPDATE ON company_subscriptions
    FOR EACH ROW
    EXECUTE FUNCTION update_updated_at_column();

-- ===================================================================
-- 9. CREATE SUBSCRIPTION AUDIT LOG TABLE
-- ===================================================================
CREATE TABLE IF NOT EXISTS subscription_audit_logs (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    subscription_id UUID REFERENCES company_subscriptions(id) ON DELETE CASCADE,
    company_id UUID REFERENCES companies(id) ON DELETE CASCADE,
    action VARCHAR(50) NOT NULL,
    details JSONB,
    performed_by UUID REFERENCES users(id),
    ip_address INET,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_subscription_audit_logs_subscription ON subscription_audit_logs(subscription_id);
CREATE INDEX IF NOT EXISTS idx_subscription_audit_logs_company ON subscription_audit_logs(company_id);
CREATE INDEX IF NOT EXISTS idx_subscription_audit_logs_created ON subscription_audit_logs(created_at);


