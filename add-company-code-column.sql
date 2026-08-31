-- Add company_code column to companies table
-- This migration adds support for company codes (e.g., SARJ-HDMU8ASLUA)

ALTER TABLE companies ADD COLUMN IF NOT EXISTS company_code VARCHAR(20) UNIQUE;

-- Index for faster lookups
CREATE INDEX IF NOT EXISTS idx_companies_code ON companies(company_code);

-- Verify the column was added
SELECT column_name, data_type FROM information_schema.columns 
WHERE table_name='companies' AND column_name='company_code';
