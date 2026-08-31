-- ========================================================
-- QUICK FIX: ADD DEPARTMENTS AND POSITIONS
-- ========================================================
-- This script adds departments and job positions to your database
-- so the dropdowns in "Add Employee" form will work
-- ========================================================

-- STEP 1: Check if you already have departments
SELECT COUNT(*) as department_count FROM departments;
SELECT COUNT(*) as position_count FROM job_positions;

-- If counts are 0, run the script below!

-- ========================================================
-- AUTOMATIC SCRIPT (WORKS FOR ANY COMPANY)
-- ========================================================

DO $$
DECLARE
    v_company_id UUID;
BEGIN
    -- Get the first company ID automatically
    SELECT id INTO v_company_id FROM companies ORDER BY created_at LIMIT 1;
    
    IF v_company_id IS NULL THEN
        RAISE EXCEPTION 'No company found. Please create a company first.';
    END IF;
    
    RAISE NOTICE 'Using company ID: %', v_company_id;
    
    -- ==========================================
    -- INSERT DEPARTMENTS
    -- ==========================================
    INSERT INTO departments (company_id, name, description, created_at) VALUES
    (v_company_id, 'Engineering', 'Software Development and IT', NOW()),
    (v_company_id, 'Human Resources', 'HR and People Operations', NOW()),
    (v_company_id, 'Sales', 'Sales and Business Development', NOW()),
    (v_company_id, 'Marketing', 'Marketing and Communications', NOW()),
    (v_company_id, 'Finance', 'Finance and Accounting', NOW()),
    (v_company_id, 'Operations', 'Operations and Support', NOW()),
    (v_company_id, 'Customer Service', 'Customer Support', NOW()),
    (v_company_id, 'Product', 'Product Management', NOW())
    ON CONFLICT DO NOTHING;
    
    -- ==========================================
    -- INSERT JOB POSITIONS
    -- ==========================================
    INSERT INTO job_positions (company_id, title, description, created_at) VALUES
    -- Engineering positions
    (v_company_id, 'Software Engineer', 'Software development', NOW()),
    (v_company_id, 'Senior Software Engineer', 'Senior software development', NOW()),
    (v_company_id, 'Tech Lead', 'Technical leadership', NOW()),
    (v_company_id, 'DevOps Engineer', 'Infrastructure and deployment', NOW()),
    (v_company_id, 'QA Engineer', 'Quality assurance', NOW()),
    
    -- HR positions
    (v_company_id, 'HR Manager', 'HR management', NOW()),
    (v_company_id, 'HR Specialist', 'HR operations', NOW()),
    (v_company_id, 'Recruiter', 'Talent acquisition', NOW()),
    
    -- Sales positions
    (v_company_id, 'Sales Manager', 'Sales management', NOW()),
    (v_company_id, 'Sales Representative', 'Sales execution', NOW()),
    (v_company_id, 'Account Executive', 'Account management', NOW()),
    
    -- Marketing positions
    (v_company_id, 'Marketing Manager', 'Marketing management', NOW()),
    (v_company_id, 'Marketing Specialist', 'Marketing operations', NOW()),
    (v_company_id, 'Content Writer', 'Content creation', NOW()),
    (v_company_id, 'Social Media Manager', 'Social media management', NOW()),
    
    -- Finance positions
    (v_company_id, 'Finance Manager', 'Financial management', NOW()),
    (v_company_id, 'Accountant', 'Accounting operations', NOW()),
    (v_company_id, 'Financial Analyst', 'Financial analysis', NOW()),
    
    -- Operations positions
    (v_company_id, 'Operations Manager', 'Operations management', NOW()),
    (v_company_id, 'Operations Specialist', 'Operations support', NOW()),
    
    -- Customer Service positions
    (v_company_id, 'Customer Service Manager', 'CS management', NOW()),
    (v_company_id, 'Customer Support Representative', 'Customer support', NOW()),
    
    -- Product positions
    (v_company_id, 'Product Manager', 'Product management', NOW()),
    (v_company_id, 'Product Designer', 'Product design', NOW())
    ON CONFLICT DO NOTHING;
    
    RAISE NOTICE 'Departments and positions added successfully!';
    
END $$;

-- ========================================================
-- STEP 2: VERIFY IT WORKED
-- ========================================================

-- Check departments (should show 8 departments)
SELECT id, name, description 
FROM departments 
ORDER BY name;

-- Check positions (should show 24+ positions)
SELECT id, title, description 
FROM job_positions 
ORDER BY title;

-- Count them
SELECT 
    (SELECT COUNT(*) FROM departments) as total_departments,
    (SELECT COUNT(*) FROM job_positions) as total_positions;

-- ========================================================
-- EXPECTED OUTPUT
-- ========================================================

/*
DEPARTMENTS (8):
- Customer Service
- Engineering
- Finance
- Human Resources
- Marketing
- Operations
- Product
- Sales

POSITIONS (24):
- Accountant
- Account Executive
- Content Writer
- Customer Service Manager
- Customer Support Representative
- DevOps Engineer
- Finance Manager
- Financial Analyst
- HR Manager
- HR Specialist
- Marketing Manager
- Marketing Specialist
- Operations Manager
- Operations Specialist
- Product Designer
- Product Manager
- QA Engineer
- Recruiter
- Sales Manager
- Sales Representative
- Senior Software Engineer
- Social Media Manager
- Software Engineer
- Tech Lead
*/
