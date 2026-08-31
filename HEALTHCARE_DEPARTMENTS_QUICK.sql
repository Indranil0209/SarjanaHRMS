-- ========================================================
-- QUICK FIX: Replace with Healthcare Departments
-- ========================================================
-- Copy and paste this ENTIRE script into Supabase SQL Editor
-- ========================================================

DO $$
DECLARE
    v_company_id UUID;
BEGIN
    -- Get company ID
    SELECT id INTO v_company_id FROM companies ORDER BY created_at LIMIT 1;
    
    -- Delete old IT departments
    DELETE FROM departments WHERE company_id = v_company_id AND name IN (
        'Engineering', 'Software Development', 'IT', 'Product', 
        'Customer Service', 'DevOps', 'Operations', 'Human Resources', 'Finance'
    );
    
    -- Delete old IT positions
    DELETE FROM job_positions WHERE company_id = v_company_id AND title IN (
        'Software Engineer', 'Senior Software Engineer', 'Tech Lead',
        'DevOps Engineer', 'QA Engineer', 'Product Manager', 
        'Product Designer', 'Customer Support Rep', 'Operations Manager',
        'Operations Specialist', 'HR Manager', 'HR Specialist',
        'Accountant', 'Finance Manager', 'Financial Analyst', 'Recruiter'
    );
    
    -- Add healthcare departments
    INSERT INTO departments (company_id, name, description) VALUES
    (v_company_id, 'Reception', 'Front desk and patient reception'),
    (v_company_id, 'Doctor', 'Medical doctors and physicians'),
    (v_company_id, 'Nurse', 'Nursing staff'),
    (v_company_id, 'Billing', 'Billing and insurance'),
    (v_company_id, 'Sales', 'Sales and business development'),
    (v_company_id, 'Marketing', 'Marketing and communications')
    ON CONFLICT DO NOTHING;
    
    -- Add healthcare positions
    INSERT INTO job_positions (company_id, title, description) VALUES
    -- Reception
    (v_company_id, 'Receptionist', 'Front desk receptionist'),
    (v_company_id, 'Senior Receptionist', 'Senior receptionist'),
    (v_company_id, 'Reception Manager', 'Reception management'),
    
    -- Doctor
    (v_company_id, 'General Physician', 'General practice doctor'),
    (v_company_id, 'Specialist Doctor', 'Specialist physician'),
    (v_company_id, 'Senior Doctor', 'Senior physician'),
    (v_company_id, 'Chief Medical Officer', 'Head of medical staff'),
    
    -- Nurse
    (v_company_id, 'Staff Nurse', 'General nursing staff'),
    (v_company_id, 'Senior Nurse', 'Senior nursing staff'),
    (v_company_id, 'Nursing Supervisor', 'Nursing supervision'),
    (v_company_id, 'Head Nurse', 'Chief nursing officer'),
    
    -- Billing
    (v_company_id, 'Billing Clerk', 'Billing operations'),
    (v_company_id, 'Billing Specialist', 'Billing and insurance specialist'),
    (v_company_id, 'Billing Manager', 'Billing department head'),
    
    -- Sales
    (v_company_id, 'Sales Representative', 'Sales executive'),
    (v_company_id, 'Sales Manager', 'Sales management'),
    (v_company_id, 'Business Development Manager', 'Business development'),
    
    -- Marketing
    (v_company_id, 'Marketing Executive', 'Marketing operations'),
    (v_company_id, 'Marketing Manager', 'Marketing management'),
    (v_company_id, 'Digital Marketing Specialist', 'Digital marketing')
    ON CONFLICT DO NOTHING;
    
    RAISE NOTICE 'Healthcare departments and positions added!';
END $$;

-- Verify
SELECT 'Departments:' as type, name FROM departments
UNION ALL
SELECT '---', '---'
UNION ALL
SELECT 'Positions:', title FROM job_positions
ORDER BY type DESC, name;
