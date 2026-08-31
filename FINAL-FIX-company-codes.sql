-- ============================================================================
-- FINAL FIX: Backfill company codes for all existing companies with NULL codes
-- ============================================================================

-- Step 1: Create a function to generate company codes (PostgreSQL)
-- (This replicates the JavaScript generateCompanyCode function)
CREATE OR REPLACE FUNCTION generate_company_code(company_name VARCHAR) 
RETURNS VARCHAR AS $$
DECLARE
  prefix VARCHAR(4);
  random_part VARCHAR(10);
  chars VARCHAR := 'ABCDEFGHJKLMNPQRSTUVWXYZ23456789';
  code VARCHAR(20);
  i INT;
BEGIN
  -- Sanitize company name and extract first 4 characters
  prefix := UPPER(SUBSTRING(REPLACE(REPLACE(REPLACE(company_name, ' ', ''), '-', ''), '_', ''), 1, 4));
  
  -- If prefix is too short, pad with 'COMP'
  IF LENGTH(prefix) < 4 THEN
    prefix := SUBSTRING((prefix || 'COMP'), 1, 4);
  END IF;
  
  -- Generate 10-character random suffix
  random_part := '';
  FOR i IN 1..10 LOOP
    random_part := random_part || SUBSTRING(chars, (random() * 32)::INT + 1, 1);
  END LOOP;
  
  code := prefix || '-' || random_part;
  RETURN code;
END;
$$ LANGUAGE plpgsql;

-- Step 2: Backfill existing companies with NULL codes
UPDATE companies
SET company_code = generate_company_code(company_name)
WHERE company_code IS NULL
AND company_name IS NOT NULL;

-- Step 3: Add UNIQUE constraint if it doesn't exist
ALTER TABLE companies ADD CONSTRAINT unique_company_code UNIQUE(company_code);

-- Step 4: Create index for faster lookups
CREATE INDEX IF NOT EXISTS idx_companies_company_code ON companies(company_code);

-- Step 5: Verify the results
SELECT 
  COUNT(*) as total_companies,
  COUNT(CASE WHEN company_code IS NOT NULL THEN 1 END) as companies_with_codes,
  COUNT(CASE WHEN company_code IS NULL THEN 1 END) as companies_without_codes
FROM companies;

-- Step 6: Show sample of updated companies
SELECT id, company_name, company_code, created_at
FROM companies
WHERE company_code IS NOT NULL
ORDER BY created_at DESC
LIMIT 10;
