-- Create user_settings table for storing user preferences like location tracking
-- This table stores user-specific settings including location tracking preferences for Non-IT employees

CREATE TABLE IF NOT EXISTS user_settings (
    id BIGINT PRIMARY KEY GENERATED ALWAYS AS IDENTITY,
    user_id UUID NOT NULL UNIQUE REFERENCES users(id) ON DELETE CASCADE,
    location_tracking_enabled BOOLEAN DEFAULT false,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Create index for faster lookups
CREATE INDEX IF NOT EXISTS idx_user_settings_user_id ON user_settings(user_id);

-- Add trigger to automatically update the updated_at timestamp
CREATE OR REPLACE FUNCTION update_user_settings_timestamp()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trigger_user_settings_updated_at
BEFORE UPDATE ON user_settings
FOR EACH ROW
EXECUTE FUNCTION update_user_settings_timestamp();

-- Add comment to the table
COMMENT ON TABLE user_settings IS 'Stores user-specific settings including location tracking preferences';
COMMENT ON COLUMN user_settings.location_tracking_enabled IS 'Boolean flag to enable/disable location tracking for the user (default: false for privacy)';
