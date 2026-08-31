-- ========================================================
-- ADD DEPARTMENTS AND JOB POSITIONS TO DATABASE
-- ========================================================
-- Run this if your Department dropdown is empty
-- ========================================================

-- Step 1: Get your company_id
-- Run this first to see your company ID
SELECT id, name, company_code FROM companies;

-- ========================================================
-- Step 2: Add Departments
-- Replace 'YOUR_COMPANY_ID_HERE' with your actual company ID
-- ========================================================

INSERT INTO departments (company_id, name, description) VALUES
('YOUR_COMPANY_ID_HERE', 'Engineering', 'Software Development and IT'),
('YOUR_COMPANY_ID_HERE', 'Human Resources', 'HR Department'),
('YOUR_COMPANY_ID_HERE', 'Sales', 'Sales Department'),
('YOUR_COMPANY_ID_HERE', 'Marketing', 'Marketing Department'),
('YOUR_COMPANY_ID_HERE', 'Finance', 'Finance and Accounting'),
('YOUR_COMPANY_ID_HERE', 'Operations', 'Operations Department')
ON CONFLICT DO NOTHING;

-- ========================================================
-- Step 3: Add Job Positions
-- Replace 'YOUR_COMPANY_ID_HERE' with your actual company ID
-- ========================================================

INSERT INTO job_positions (company_id, title, description) VALUES
('YOUR_COMPANY_ID_HERE', 'Software Engineer', 'Develops software applications'),
('YOUR_COMPANY_ID_HERE', 'Senior Software Engineer', 'Senior level software development'),
('YOUR_COMPANY_ID_HERE', 'HR Manager', 'Manages HR operations'),
('YOUR_COMPANY_ID_HERE', 'HR Specialist', 'HR support and administration'),
('YOUR_COMPANY_ID_HERE', 'Sales Manager', 'Manages sales team'),
('YOUR_COMPANY_ID_HERE', 'Sales Representative', 'Sales and customer relations'),
('YOUR_COMPANY_ID_HERE', 'Marketing Manager', 'Manages marketing campaigns'),
('YOUR_COMPANY_ID_HERE', 'Marketing Specialist', 'Marketing support'),
('YOUR_COMPANY_ID_HERE', 'Finance Manager', 'Manages financial operations'),
('YOUR_COMPANY_ID_HERE', 'Accountant', 'Accounting and bookkeeping'),
('YOUR_COMPANY_ID_HERE', 'Operations Manager', 'Manages daily operations'),
('YOUR_COMPANY_ID_HERE', 'Operations Specialist', 'Operations support')
ON CONFLICT DO NOTHING;

-- ========================================================
-- Step 4: Verify they were added
-- ========================================================

-- Check departments
SELECT id, name, description FROM departments ORDER BY name;

-- Check positions
SELECT id, title, description FROM job_positions ORDER BY title;

-- ========================================================
-- ALTERNATIVE: If you already have departments/positions
-- ========================================================

-- Check if departments exist
SELECT COUNT(*) as department_count FROM departments;

-- Check if positions exist
SELECT COUNT(*) as position_count FROM job_positions;

-- If counts are 0, run the INSERT statements above!

-- ========================================================
-- QUICK FIX SCRIPT (ALL-IN-ONE)
-- ========================================================
-- Copy this entire block and run it (replace YOUR_COMPANY_ID)

DO $$
DECLARE
    v_company_id UUID;
BEGIN
    -- Get first company ID
    SELECT id INTO v_company_id FROM companies LIMIT 1;
    
    IF v_company_id IS NULL THEN
        RAISE EXCEPTION 'No company found in database';
    END IF;
    
    -- Insert departments
    INSERT INTO departments (company_id, name, description) VALUES
    (v_company_id, 'Engineering', 'Software Development and IT'),
    (v_company_id, 'Human Resources', 'HR Department'),
    (v_company_id, 'Sales', 'Sales Department'),
    (v_company_id, 'Marketing', 'Marketing Department'),
    (v_company_id, 'Finance', 'Finance and Accounting'),
    (v_company_id, 'Operations', 'Operations Department')
    ON CONFLICT DO NOTHING;
    
    -- Insert positions
    INSERT INTO job_positions (company_id, title, description) VALUES
    (v_company_id, 'Software Engineer', 'Develops software applications'),
    (v_company_id, 'Senior Software Engineer', 'Senior level software development'),
    (v_company_id, 'HR Manager', 'Manages HR operations'),
    (v_company_id, 'HR Specialist', 'HR support and administration'),
    (v_company_id, 'Sales Manager', 'Manages sales team'),
    (v_company_id, 'Sales Representative', 'Sales and customer relations'),
    (v_company_id, 'Marketing Manager', 'Manages marketing campaigns'),
    (v_company_id, 'Marketing Specialist', 'Marketing support'),
    (v_company_id, 'Finance Manager', 'Manages financial operations'),
    (v_company_id, 'Accountant', 'Accounting and bookkeeping'),
    (v_company_id, 'Operations Manager', 'Manages daily operations'),
    (v_company_id, 'Operations Specialist', 'Operations support')
    ON CONFLICT DO NOTHING;
    
    RAISE NOTICE 'Departments and positions added successfully!';
END $$;

-- Verify
SELECT 
    (SELECT COUNT(*) FROM departments) as departments_count,
    (SELECT COUNT(*) FROM job_positions) as positions_count;
