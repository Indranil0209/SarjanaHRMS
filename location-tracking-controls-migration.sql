-- ===================================================================
-- SARJANA HRMS: Company-Level Location Tracking Controls Migration
-- ===================================================================
-- Adds customizable company-level settings for geo-tagging and
-- live location tracking with configurable intervals and radius
-- ===================================================================

-- ===================================================================
-- 1. ADD COLUMNS TO OFFICE_LOCATIONS TABLE
-- ===================================================================
-- Add company-wide location tracking settings to office_locations
ALTER TABLE office_locations 
ADD COLUMN IF NOT EXISTS is_geo_tagging_enabled BOOLEAN DEFAULT true,
ADD COLUMN IF NOT EXISTS is_live_tracking_enabled BOOLEAN DEFAULT false,
ADD COLUMN IF NOT EXISTS tracking_interval_seconds INTEGER DEFAULT 30,
ADD COLUMN IF NOT EXISTS custom_allowed_radius INTEGER DEFAULT 100;

-- Add comments to explain the columns
COMMENT ON COLUMN office_locations.is_geo_tagging_enabled IS 'Enforces coordinate tagging on check-in/check-out. If false, attendance works without location verification.';
COMMENT ON COLUMN office_locations.is_live_tracking_enabled IS 'Controls whether field employees are tracked in real-time during work hours.';
COMMENT ON COLUMN office_locations.tracking_interval_seconds IS 'Interval in seconds for background location pings (15-300 seconds recommended).';
COMMENT ON COLUMN office_locations.custom_allowed_radius IS 'Custom geofence boundary in meters for this office location.';

-- ===================================================================
-- 2. CREATE COMPANY_SETTINGS TABLE (Alternative Approach)
-- ===================================================================
-- This table stores company-wide settings separate from office locations
CREATE TABLE IF NOT EXISTS company_settings (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    company_id UUID NOT NULL UNIQUE REFERENCES companies(id) ON DELETE CASCADE,
    
    -- Location & Tracking Settings
    is_geo_tagging_enabled BOOLEAN DEFAULT true,
    is_live_tracking_enabled BOOLEAN DEFAULT false,
    tracking_interval_seconds INTEGER DEFAULT 30 CHECK (tracking_interval_seconds BETWEEN 15 AND 300),
    default_allowed_radius_meters INTEGER DEFAULT 100 CHECK (default_allowed_radius_meters > 0),
    
    -- Feature Toggles
    require_face_verification BOOLEAN DEFAULT false,
    allow_manual_attendance BOOLEAN DEFAULT false,
    enable_attendance_photos BOOLEAN DEFAULT true,
    
    -- Data Retention
    location_data_retention_days INTEGER DEFAULT 90,
    attendance_photo_retention_days INTEGER DEFAULT 180,
    
    -- Notification Settings
    notify_on_late_checkin BOOLEAN DEFAULT true,
    notify_on_geofence_violation BOOLEAN DEFAULT true,
    notify_on_missing_checkout BOOLEAN DEFAULT true,
    
    -- Metadata
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_by UUID REFERENCES users(id)
);

-- Create index for faster lookups
CREATE INDEX IF NOT EXISTS idx_company_settings_company_id ON company_settings(company_id);

-- ===================================================================
-- 3. CREATE FUNCTION TO GET COMPANY SETTINGS WITH DEFAULTS
-- ===================================================================
CREATE OR REPLACE FUNCTION get_company_location_settings(p_company_id UUID)
RETURNS TABLE (
    company_id UUID,
    is_geo_tagging_enabled BOOLEAN,
    is_live_tracking_enabled BOOLEAN,
    tracking_interval_seconds INTEGER,
    default_allowed_radius_meters INTEGER,
    require_face_verification BOOLEAN
) AS $$
BEGIN
    -- Try to get settings from company_settings table
    RETURN QUERY
    SELECT 
        cs.company_id,
        cs.is_geo_tagging_enabled,
        cs.is_live_tracking_enabled,
        cs.tracking_interval_seconds,
        cs.default_allowed_radius_meters,
        cs.require_face_verification
    FROM company_settings cs
    WHERE cs.company_id = p_company_id;
    
    -- If no settings found, return defaults
    IF NOT FOUND THEN
        RETURN QUERY
        SELECT 
            p_company_id,
            true::BOOLEAN,  -- geo tagging enabled by default
            false::BOOLEAN, -- live tracking disabled by default
            30::INTEGER,    -- 30 second interval
            100::INTEGER,   -- 100 meter radius
            false::BOOLEAN  -- face verification optional
        ;
    END IF;
END;
$$ LANGUAGE plpgsql;

-- ===================================================================
-- 4. CREATE FUNCTION TO INITIALIZE DEFAULT SETTINGS
-- ===================================================================
CREATE OR REPLACE FUNCTION initialize_company_settings(p_company_id UUID)
RETURNS company_settings AS $$
DECLARE
    new_settings company_settings;
BEGIN
    -- Insert default settings if they don't exist
    INSERT INTO company_settings (company_id)
    VALUES (p_company_id)
    ON CONFLICT (company_id) DO NOTHING
    RETURNING * INTO new_settings;
    
    -- If conflict occurred, fetch existing settings
    IF new_settings.id IS NULL THEN
        SELECT * INTO new_settings
        FROM company_settings
        WHERE company_id = p_company_id;
    END IF;
    
    RETURN new_settings;
END;
$$ LANGUAGE plpgsql;

-- ===================================================================
-- 5. CREATE TRIGGER TO AUTO-INITIALIZE SETTINGS FOR NEW COMPANIES
-- ===================================================================
CREATE OR REPLACE FUNCTION auto_initialize_company_settings()
RETURNS TRIGGER AS $$
BEGIN
    -- Automatically create default settings when a new company is created
    INSERT INTO company_settings (company_id)
    VALUES (NEW.id)
    ON CONFLICT (company_id) DO NOTHING;
    
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

DROP TRIGGER IF EXISTS trigger_auto_initialize_company_settings ON companies;
CREATE TRIGGER trigger_auto_initialize_company_settings
    AFTER INSERT ON companies
    FOR EACH ROW
    EXECUTE FUNCTION auto_initialize_company_settings();

-- ===================================================================
-- 6. UPDATE EXISTING OFFICE_LOCATIONS WITH DEFAULT VALUES
-- ===================================================================
-- Set custom_allowed_radius to match existing allowed_radius_meters
UPDATE office_locations
SET custom_allowed_radius = allowed_radius_meters
WHERE custom_allowed_radius IS NULL OR custom_allowed_radius = 100;

-- ===================================================================
-- 7. CREATE VIEW FOR EASY SETTINGS ACCESS
-- ===================================================================
CREATE OR REPLACE VIEW v_company_location_settings AS
SELECT 
    c.id as company_id,
    c.company_name,
    COALESCE(cs.is_geo_tagging_enabled, true) as is_geo_tagging_enabled,
    COALESCE(cs.is_live_tracking_enabled, false) as is_live_tracking_enabled,
    COALESCE(cs.tracking_interval_seconds, 30) as tracking_interval_seconds,
    COALESCE(cs.default_allowed_radius_meters, 100) as default_allowed_radius_meters,
    COALESCE(cs.require_face_verification, false) as require_face_verification,
    COALESCE(cs.allow_manual_attendance, false) as allow_manual_attendance,
    cs.location_data_retention_days,
    cs.updated_at as settings_updated_at
FROM companies c
LEFT JOIN company_settings cs ON c.id = cs.company_id;

-- ===================================================================
-- 8. INITIALIZE SETTINGS FOR ALL EXISTING COMPANIES
-- ===================================================================
INSERT INTO company_settings (company_id)
SELECT id FROM companies
ON CONFLICT (company_id) DO NOTHING;

-- ===================================================================
-- 9. CREATE UPDATED_AT TRIGGER
-- ===================================================================
CREATE OR REPLACE FUNCTION update_company_settings_timestamp()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

DROP TRIGGER IF EXISTS trigger_update_company_settings_timestamp ON company_settings;
CREATE TRIGGER trigger_update_company_settings_timestamp
    BEFORE UPDATE ON company_settings
    FOR EACH ROW
    EXECUTE FUNCTION update_company_settings_timestamp();

-- ===================================================================
-- MIGRATION COMPLETE
-- ===================================================================
-- Summary:
-- ✓ Added location tracking control columns to office_locations
-- ✓ Created company_settings table for centralized company preferences
-- ✓ Created helper functions for settings management
-- ✓ Auto-initialize settings for new companies via trigger
-- ✓ Created view for easy settings access
-- ✓ Initialized settings for all existing companies
-- ===================================================================
