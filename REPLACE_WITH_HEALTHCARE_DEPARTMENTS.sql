-- ========================================================
-- REPLACE IT DEPARTMENTS WITH HEALTHCARE DEPARTMENTS
-- ========================================================
-- This script removes IT departments and adds healthcare ones
-- ========================================================

-- STEP 1: View current departments
SELECT id, name FROM departments ORDER BY name;

-- ========================================================
-- STEP 2: DELETE OLD IT DEPARTMENTS
-- ========================================================

BEGIN;

DELETE FROM departments WHERE name IN (
    'Engineering',
    'Software Development',
    'IT',
    'DevOps',
    'Product',
    'Customer Service'
);

-- ========================================================
-- STEP 3: ADD HEALTHCARE DEPARTMENTS
-- ========================================================

DO $$
DECLARE
    v_company_id UUID;
BEGIN
    -- Get company ID automatically
    SELECT id INTO v_company_id FROM companies ORDER BY created_at LIMIT 1;
    
    IF v_company_id IS NULL THEN
        RAISE EXCEPTION 'No company found';
    END IF;
    
    -- Insert healthcare departments
    INSERT INTO departments (company_id, name, description, created_at) VALUES
    (v_company_id, 'Reception', 'Front desk and patient reception', NOW()),
    (v_company_id, 'Doctor', 'Medical doctors and physicians', NOW()),
    (v_company_id, 'Nurse', 'Nursing staff', NOW()),
    (v_company_id, 'Billing', 'Billing and insurance', NOW()),
    (v_company_id, 'Sales', 'Sales and business development', NOW()),
    (v_company_id, 'Marketing', 'Marketing and communications', NOW())
    ON CONFLICT DO NOTHING;
    
    RAISE NOTICE 'Healthcare departments added successfully!';
END $$;

COMMIT;

-- ========================================================
-- STEP 4: DELETE OLD IT POSITIONS
-- ========================================================

BEGIN;

DELETE FROM job_positions WHERE title IN (
    'Software Engineer',
    'Senior Software Engineer',
    'Tech Lead',
    'DevOps Engineer',
    'QA Engineer',
    'Product Manager',
    'Product Designer',
    'Customer Support Representative',
    'Customer Service Manager'
);

-- ========================================================
-- STEP 5: ADD HEALTHCARE POSITIONS
-- ========================================================

DO $$
DECLARE
    v_company_id UUID;
BEGIN
    SELECT id INTO v_company_id FROM companies ORDER BY created_at LIMIT 1;
    
    -- Insert healthcare positions
    INSERT INTO job_positions (company_id, title, description, created_at) VALUES
    -- Reception positions
    (v_company_id, 'Receptionist', 'Front desk receptionist', NOW()),
    (v_company_id, 'Senior Receptionist', 'Senior receptionist', NOW()),
    (v_company_id, 'Reception Manager', 'Reception management', NOW()),
    
    -- Doctor positions
    (v_company_id, 'General Physician', 'General practice doctor', NOW()),
    (v_company_id, 'Specialist Doctor', 'Specialist physician', NOW()),
    (v_company_id, 'Senior Doctor', 'Senior physician', NOW()),
    (v_company_id, 'Chief Medical Officer', 'Head of medical staff', NOW()),
    
    -- Nurse positions
    (v_company_id, 'Staff Nurse', 'General nursing staff', NOW()),
    (v_company_id, 'Senior Nurse', 'Senior nursing staff', NOW()),
    (v_company_id, 'Nursing Supervisor', 'Nursing supervision', NOW()),
    (v_company_id, 'Head Nurse', 'Chief nursing officer', NOW()),
    
    -- Billing positions
    (v_company_id, 'Billing Clerk', 'Billing operations', NOW()),
    (v_company_id, 'Billing Specialist', 'Billing and insurance specialist', NOW()),
    (v_company_id, 'Billing Manager', 'Billing department head', NOW()),
    
    -- Sales positions
    (v_company_id, 'Sales Representative', 'Sales executive', NOW()),
    (v_company_id, 'Sales Manager', 'Sales management', NOW()),
    (v_company_id, 'Business Development Manager', 'Business development', NOW()),
    
    -- Marketing positions
    (v_company_id, 'Marketing Executive', 'Marketing operations', NOW()),
    (v_company_id, 'Marketing Manager', 'Marketing management', NOW()),
    (v_company_id, 'Digital Marketing Specialist', 'Digital marketing', NOW())
    ON CONFLICT DO NOTHING;
    
    RAISE NOTICE 'Healthcare positions added successfully!';
END $$;

COMMIT;

-- ========================================================
-- STEP 6: VERIFY NEW DEPARTMENTS
-- ========================================================

-- Should show 6 healthcare departments
SELECT name, description 
FROM departments 
ORDER BY name;

/*
Expected:
- Billing
- Doctor
- Marketing
- Nurse
- Reception
- Sales
*/

-- ========================================================
-- STEP 7: VERIFY NEW POSITIONS
-- ========================================================

-- Should show 20 healthcare positions
SELECT title, description 
FROM job_positions 
ORDER BY title;

/*
Expected positions:
- Billing Clerk
- Billing Manager
- Billing Specialist
- Business Development Manager
- Chief Medical Officer
- Digital Marketing Specialist
- General Physician
- Head Nurse
- Marketing Executive
- Marketing Manager
- Nursing Supervisor
- Reception Manager
- Receptionist
- Sales Manager
- Sales Representative
- Senior Doctor
- Senior Nurse
- Senior Receptionist
- Specialist Doctor
- Staff Nurse
*/

-- ========================================================
-- COUNT THEM
-- ========================================================

SELECT 
    (SELECT COUNT(*) FROM departments) as total_departments,
    (SELECT COUNT(*) FROM job_positions) as total_positions;

-- Expected: 6 departments, 20 positions

-- ========================================================
-- DONE! Now refresh your browser and the dropdowns will show healthcare departments
-- ========================================================
