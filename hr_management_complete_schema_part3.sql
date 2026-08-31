-- HR Management System - Complete Database Schema (Part 3)
-- This file contains job positions, employees, leave balances, attendance, and leave requests demo data

-- ========================================================
-- DEMO JOB POSITIONS
-- ========================================================

INSERT INTO job_positions (id, company_id, title, description, department_id, salary_range_min, salary_range_max, requirements, created_at) VALUES
-- Engineering positions
('j550e8400-e29b-41d4-a716-446655440000', 'c550e8400-e29b-41d4-a716-446655440000', 'Senior Software Engineer', 'Lead development of complex software systems', 'd550e8400-e29b-41d4-a716-446655440000', 80000.00, 150000.00, ARRAY['5+ years experience', 'React/Node.js', 'System design'], '2024-01-10 08:00:00+00'),
('j550e8400-e29b-41d4-a716-446655440001', 'c550e8400-e29b-41d4-a716-446655440000', 'Software Engineer', 'Develop and maintain software applications', 'd550e8400-e29b-41d4-a716-446655440000', 60000.00, 100000.00, ARRAY['2+ years experience', 'JavaScript/Python', 'Database knowledge'], '2024-01-10 08:00:00+00'),
('j550e8400-e29b-41d4-a716-446655440002', 'c550e8400-e29b-41d4-a716-446655440000', 'DevOps Engineer', 'Manage infrastructure and deployment pipelines', 'd550e8400-e29b-41d4-a716-446655440000', 70000.00, 130000.00, ARRAY['AWS/Docker', 'CI/CD', 'Monitoring tools'], '2024-01-10 08:00:00+00'),

-- HR positions
('j550e8400-e29b-41d4-a716-446655440003', 'c550e8400-e29b-41d4-a716-446655440000', 'HR Manager', 'Oversee human resources operations', 'd550e8400-e29b-41d4-a716-446655440001', 65000.00, 95000.00, ARRAY['HR degree', '3+ years management', 'SHRM certification'], '2024-01-10 08:00:00+00'),
('j550e8400-e29b-41d4-a716-446655440004', 'c550e8400-e29b-41d4-a716-446655440000', 'HR Specialist', 'Handle recruitment and employee relations', 'd550e8400-e29b-41d4-a716-446655440001', 45000.00, 65000.00, ARRAY['HR degree', 'Recruitment experience'], '2024-01-10 08:00:00+00'),

-- Sales positions
('j550e8400-e29b-41d4-a716-446655440005', 'c550e8400-e29b-41d4-a716-446655440000', 'Sales Manager', 'Lead sales team and strategy', 'd550e8400-e29b-41d4-a716-446655440002', 70000.00, 120000.00, ARRAY['5+ years sales', 'Team management', 'B2B experience'], '2024-01-10 08:00:00+00'),
('j550e8400-e29b-41d4-a716-446655440006', 'c550e8400-e29b-41d4-a716-446655440000', 'Sales Representative', 'Generate leads and close deals', 'd550e8400-e29b-41d4-a716-446655440002', 40000.00, 80000.00, ARRAY['Sales experience', 'Communication skills'], '2024-01-10 08:00:00+00'),

-- Marketing positions
('j550e8400-e29b-41d4-a716-446655440007', 'c550e8400-e29b-41d4-a716-446655440000', 'Marketing Manager', 'Develop and execute marketing strategies', 'd550e8400-e29b-41d4-a716-446655440003', 60000.00, 100000.00, ARRAY['Marketing degree', 'Digital marketing', 'Analytics'], '2024-01-10 08:00:00+00'),
('j550e8400-e29b-41d4-a716-446655440008', 'c550e8400-e29b-41d4-a716-446655440000', 'Content Creator', 'Create engaging content for various channels', 'd550e8400-e29b-41d4-a716-446655440003', 35000.00, 60000.00, ARRAY['Creative skills', 'Social media', 'Content strategy'], '2024-01-10 08:00:00+00'),

-- Finance positions
('j550e8400-e29b-41d4-a716-446655440009', 'c550e8400-e29b-41d4-a716-446655440000', 'Finance Manager', 'Oversee financial operations and reporting', 'd550e8400-e29b-41d4-a716-446655440004', 70000.00, 110000.00, ARRAY['CPA preferred', 'Financial analysis', '5+ years experience'], '2024-01-10 08:00:00+00'),
('j550e8400-e29b-41d4-a716-446655440010', 'c550e8400-e29b-41d4-a716-446655440000', 'Accountant', 'Manage bookkeeping and financial records', 'd550e8400-e29b-41d4-a716-446655440004', 40000.00, 65000.00, ARRAY['Accounting degree', 'QuickBooks', 'Detail oriented'], '2024-01-10 08:00:00+00');

-- ========================================================
-- DEMO EMPLOYEES
-- ========================================================

INSERT INTO employees (id, user_id, company_id, employee_id, first_name, last_name, date_of_birth, gender, phone, address, emergency_contact_name, emergency_contact_phone, department_id, job_position_id, hire_date, salary, employment_status, work_location, created_at) VALUES
-- Super Admin
('e550e8400-e29b-41d4-a716-446655440000', '550e8400-e29b-41d4-a716-446655440000', 'c550e8400-e29b-41d4-a716-446655440000', 'EMP001', 'Super', 'Admin', '1985-05-15', 'Male', '+1234567890', '123 Admin St, Tech City, TC 12345', 'Jane Admin', '+1234567891', 'd550e8400-e29b-41d4-a716-446655440000', 'j550e8400-e29b-41d4-a716-446655440000', '2024-01-15', 200000.00, 'active', 'Headquarters', '2024-01-15 08:00:00+00'),

-- Admin
('e550e8400-e29b-41d4-a716-446655440001', '550e8400-e29b-41d4-a716-446655440001', 'c550e8400-e29b-41d4-a716-446655440000', 'EMP002', 'John', 'Admin', '1988-03-20', 'Male', '+1234567892', '456 Tech Ave, Innovation City, IC 54321', 'Mary Admin', '+1234567893', 'd550e8400-e29b-41d4-a716-446655440000', 'j550e8400-e29b-41d4-a716-446655440000', '2024-01-15', 180000.00, 'active', 'Headquarters', '2024-01-15 08:00:00+00'),

-- HR Managers
('e550e8400-e29b-41d4-a716-446655440002', '550e8400-e29b-41d4-a716-446655440002', 'c550e8400-e29b-41d4-a716-446655440000', 'EMP003', 'Sarah', 'Johnson', '1990-07-10', 'Female', '+1234567894', '789 HR Plaza, People City, PC 67890', 'Mike Johnson', '+1234567895', 'd550e8400-e29b-41d4-a716-446655440001', 'j550e8400-e29b-41d4-a716-446655440003', '2024-01-15', 85000.00, 'active', 'Headquarters', '2024-01-15 08:00:00+00'),

('e550e8400-e29b-41d4-a716-446655440003', '550e8400-e29b-41d4-a716-446655440003', 'c550e8400-e29b-41d4-a716-446655440000', 'EMP004', 'Emma', 'Wilson', '1987-11-25', 'Female', '+1234567896', '321 Resource Rd, Talent Town, TT 98765', 'Tom Wilson', '+1234567897', 'd550e8400-e29b-41d4-a716-446655440001', 'j550e8400-e29b-41d4-a716-446655440004', '2024-01-20', 65000.00, 'active', 'Headquarters', '2024-01-20 08:00:00+00'),

-- Engineering Employees
('e550e8400-e29b-41d4-a716-446655440004', '550e8400-e29b-41d4-a716-446655440004', 'c550e8400-e29b-41d4-a716-446655440000', 'EMP005', 'Mike', 'Johnson', '1992-04-18', 'Male', '+1234567898', '654 Code St, Dev Valley, DV 13579', 'Lisa Johnson', '+1234567899', 'd550e8400-e29b-41d4-a716-446655440000', 'j550e8400-e29b-41d4-a716-446655440001', '2024-02-01', 95000.00, 'active', 'Remote', '2024-02-01 08:00:00+00'),

('e550e8400-e29b-41d4-a716-446655440005', '550e8400-e29b-41d4-a716-446655440005', 'c550e8400-e29b-41d4-a716-446655440000', 'EMP006', 'Jane', 'Smith', '1989-09-12', 'Female', '+1234567900', '987 Software Blvd, Algorithm City, AC 24680', 'John Smith', '+1234567901', 'd550e8400-e29b-41d4-a716-446655440000', 'j550e8400-e29b-41d4-a716-446655440000', '2024-02-01', 120000.00, 'active', 'Headquarters', '2024-02-01 08:00:00+00'),

('e550e8400-e29b-41d4-a716-446655440006', '550e8400-e29b-41d4-a716-446655440006', 'c550e8400-e29b-41d4-a716-446655440000', 'EMP007', 'Alex', 'Chen', '1993-12-03', 'Male', '+1234567902', '147 DevOps Lane, Cloud City, CC 36912', 'Lucy Chen', '+1234567903', 'd550e8400-e29b-41d4-a716-446655440000', 'j550e8400-e29b-41d4-a716-446655440002', '2024-02-15', 110000.00, 'active', 'Remote', '2024-02-15 08:00:00+00'),

-- Sales Employees
('e550e8400-e29b-41d4-a716-446655440007', '550e8400-e29b-41d4-a716-446655440007', 'c550e8400-e29b-41d4-a716-446655440000', 'EMP008', 'Lisa', 'Wang', '1991-06-28', 'Female', '+1234567904', '258 Sales St, Revenue City, RC 47025', 'Kevin Wang', '+1234567905', 'd550e8400-e29b-41d4-a716-446655440002', 'j550e8400-e29b-41d4-a716-446655440005', '2024-02-15', 100000.00, 'active', 'Headquarters', '2024-02-15 08:00:00+00'),

('e550e8400-e29b-41d4-a716-446655440008', '550e8400-e29b-41d4-a716-446655440008', 'c550e8400-e29b-41d4-a716-446655440000', 'EMP009', 'David', 'Brown', '1994-01-14', 'Male', '+1234567906', '369 Deal Ave, Client City, CC 58136', 'Sarah Brown', '+1234567907', 'd550e8400-e29b-41d4-a716-446655440002', 'j550e8400-e29b-41d4-a716-446655440006', '2024-03-01', 65000.00, 'active', 'Field', '2024-03-01 08:00:00+00'),

-- Marketing Employees
('e550e8400-e29b-41d4-a716-446655440009', '550e8400-e29b-41d4-a716-446655440009', 'c550e8400-e29b-41d4-a716-446655440000', 'EMP010', 'Emily', 'Davis', '1990-08-07', 'Female', '+1234567908', '741 Brand Blvd, Creative City, CC 69247', 'Michael Davis', '+1234567909', 'd550e8400-e29b-41d4-a716-446655440003', 'j550e8400-e29b-41d4-a716-446655440007', '2024-03-01', 85000.00, 'active', 'Headquarters', '2024-03-01 08:00:00+00'),

('e550e8400-e29b-41d4-a716-446655440010', '550e8400-e29b-41d4-a716-446655440010', 'c550e8400-e29b-41d4-a716-446655440000', 'EMP011', 'Robert', 'Wilson', '1995-02-22', 'Male', '+1234567910', '852 Content St, Media Town, MT 70358', 'Jennifer Wilson', '+1234567911', 'd550e8400-e29b-41d4-a716-446655440003', 'j550e8400-e29b-41d4-a716-446655440008', '2024-03-15', 55000.00, 'active', 'Remote', '2024-03-15 08:00:00+00'),

-- Finance Employees
('e550e8400-e29b-41d4-a716-446655440011', '550e8400-e29b-41d4-a716-446655440011', 'c550e8400-e29b-41d4-a716-446655440000', 'EMP012', 'Maria', 'Garcia', '1988-10-31', 'Female', '+1234567912', '963 Finance Rd, Money City, MC 81469', 'Carlos Garcia', '+1234567913', 'd550e8400-e29b-41d4-a716-446655440004', 'j550e8400-e29b-41d4-a716-446655440009', '2024-03-15', 95000.00, 'active', 'Headquarters', '2024-03-15 08:00:00+00'),

('e550e8400-e29b-41d4-a716-446655440012', '550e8400-e29b-41d4-a716-446655440012', 'c550e8400-e29b-41d4-a716-446655440000', 'EMP013', 'James', 'Lee', '1993-05-16', 'Male', '+1234567914', '074 Ledger Lane, Accounting Ave, AA 92570', 'Amy Lee', '+1234567915', 'd550e8400-e29b-41d4-a716-446655440004', 'j550e8400-e29b-41d4-a716-446655440010', '2024-04-01', 55000.00, 'active', 'Headquarters', '2024-04-01 08:00:00+00'),

-- Operations Employees
('e550e8400-e29b-41d4-a716-446655440013', '550e8400-e29b-41d4-a716-446655440013', 'c550e8400-e29b-41d4-a716-446655440000', 'EMP014', 'Anna', 'Taylor', '1991-12-09', 'Female', '+1234567916', '185 Operations Blvd, Process City, PC 03681', 'Mark Taylor', '+1234567917', 'd550e8400-e29b-41d4-a716-446655440005', 'j550e8400-e29b-41d4-a716-446655440006', '2024-04-01', 70000.00, 'active', 'Headquarters', '2024-04-01 08:00:00+00'),

('e550e8400-e29b-41d4-a716-446655440014', '550e8400-e29b-41d4-a716-446655440014', 'c550e8400-e29b-41d4-a716-446655440000', 'EMP015', 'Kevin', 'Martinez', '1989-07-24', 'Male', '+1234567918', '296 Support St, Service City, SC 14792', 'Rosa Martinez', '+1234567919', 'd550e8400-e29b-41d4-a716-446655440005', 'j550e8400-e29b-41d4-a716-446655440006', '2024-04-15', 68000.00, 'active', 'Headquarters', '2024-04-15 08:00:00+00'),

('e550e8400-e29b-41d4-a716-446655440015', '550e8400-e29b-41d4-a716-446655440015', 'c550e8400-e29b-41d4-a716-446655440000', 'EMP016', 'Rachel', 'White', '1994-03-11', 'Female', '+1234567920', '407 Quality Rd, Excellence City, EC 25803', 'Daniel White', '+1234567921', 'd550e8400-e29b-41d4-a716-446655440005', 'j550e8400-e29b-41d4-a716-446655440006', '2024-04-15', 66000.00, 'active', 'Headquarters', '2024-04-15 08:00:00+00');

-- Set managers for departments
UPDATE departments SET manager_id = '550e8400-e29b-41d4-a716-446655440002' WHERE name = 'Human Resources';
UPDATE departments SET manager_id = '550e8400-e29b-41d4-a716-446655440005' WHERE name = 'Engineering';
UPDATE departments SET manager_id = '550e8400-e29b-41d4-a716-446655440007' WHERE name = 'Sales';
UPDATE departments SET manager_id = '550e8400-e29b-41d4-a716-446655440009' WHERE name = 'Marketing';
UPDATE departments SET manager_id = '550e8400-e29b-41d4-a716-446655440011' WHERE name = 'Finance';
UPDATE departments SET manager_id = '550e8400-e29b-41d4-a716-446655440013' WHERE name = 'Operations';

-- Set manager relationships for employees
UPDATE employees SET manager_id = 'e550e8400-e29b-41d4-a716-446655440002' WHERE department_id = 'd550e8400-e29b-41d4-a716-446655440001' AND id != 'e550e8400-e29b-41d4-a716-446655440002';
UPDATE employees SET manager_id = 'e550e8400-e29b-41d4-a716-446655440005' WHERE department_id = 'd550e8400-e29b-41d4-a716-446655440000' AND id != 'e550e8400-e29b-41d4-a716-446655440005';
UPDATE employees SET manager_id = 'e550e8400-e29b-41d4-a716-446655440007' WHERE department_id = 'd550e8400-e29b-41d4-a716-446655440002' AND id != 'e550e8400-e29b-41d4-a716-446655440007';
UPDATE employees SET manager_id = 'e550e8400-e29b-41d4-a716-446655440009' WHERE department_id = 'd550e8400-e29b-41d4-a716-446655440003' AND id != 'e550e8400-e29b-41d4-a716-446655440009';
UPDATE employees SET manager_id = 'e550e8400-e29b-41d4-a716-446655440011' WHERE department_id = 'd550e8400-e29b-41d4-a716-446655440004' AND id != 'e550e8400-e29b-41d4-a716-446655440011';
UPDATE employees SET manager_id = 'e550e8400-e29b-41d4-a716-446655440013' WHERE department_id = 'd550e8400-e29b-41d4-a716-446655440005' AND id != 'e550e8400-e29b-41d4-a716-446655440013';

-- ========================================================
-- DEMO LEAVE BALANCES (2024)
-- ========================================================

INSERT INTO leave_balances (employee_id, company_id, year, leave_type, allocated_days, used_days, remaining_days) 
SELECT 
  id,
  'c550e8400-e29b-41d4-a716-446655440000',
  2024,
  'annual',
  25,
  FLOOR(RANDOM() * 10)::INTEGER,
  25 - FLOOR(RANDOM() * 10)::INTEGER
FROM employees;

INSERT INTO leave_balances (employee_id, company_id, year, leave_type, allocated_days, used_days, remaining_days) 
SELECT 
  id,
  'c550e8400-e29b-41d4-a716-446655440000',
  2024,
  'sick',
  12,
  FLOOR(RANDOM() * 5)::INTEGER,
  12 - FLOOR(RANDOM() * 5)::INTEGER
FROM employees;

-- ========================================================
-- DEMO ATTENDANCE RECORDS (Last 30 days)
-- ========================================================

INSERT INTO attendance (employee_id, company_id, date, check_in_time, check_out_time, total_hours, status)
SELECT 
  e.id,
  'c550e8400-e29b-41d4-a716-446655440000',
  d.date,
  '09:00:00'::time + (RANDOM() * INTERVAL '60 minutes'),
  '17:30:00'::time + (RANDOM() * INTERVAL '90 minutes'),
  8.0 + (RANDOM() * 2 - 1),
  CASE 
    WHEN RANDOM() > 0.95 THEN 'absent'
    WHEN RANDOM() > 0.90 THEN 'late'
    WHEN RANDOM() > 0.85 THEN 'half_day'
    ELSE 'present'
  END
FROM employees e
CROSS JOIN (
  SELECT generate_series(
    CURRENT_DATE - INTERVAL '30 days',
    CURRENT_DATE - INTERVAL '1 day',
    '1 day'::interval
  )::date as date
) d
WHERE EXTRACT(DOW FROM d.date) NOT IN (0, 6); -- Exclude weekends

-- ========================================================
-- DEMO LEAVE REQUESTS
-- ========================================================

INSERT INTO leave_requests (employee_id, company_id, leave_type, start_date, end_date, total_days, reason, status, approved_by, approved_at)
VALUES
-- Approved leaves
('e550e8400-e29b-41d4-a716-446655440004', 'c550e8400-e29b-41d4-a716-446655440000', 'annual', '2024-10-25', '2024-10-27', 3, 'Family vacation', 'approved', 'e550e8400-e29b-41d4-a716-446655440002', '2024-10-15 10:30:00+00'),
('e550e8400-e29b-41d4-a716-446655440006', 'c550e8400-e29b-41d4-a716-446655440000', 'sick', '2024-10-20', '2024-10-20', 1, 'Medical appointment', 'approved', 'e550e8400-e29b-41d4-a716-446655440002', '2024-10-18 14:20:00+00'),
('e550e8400-e29b-41d4-a716-446655440008', 'c550e8400-e29b-41d4-a716-446655440000', 'annual', '2024-11-01', '2024-11-05', 5, 'Personal time off', 'approved', 'e550e8400-e29b-41d4-a716-446655440002', '2024-10-16 09:15:00+00'),

-- Pending leaves
('e550e8400-e29b-41d4-a716-446655440010', 'c550e8400-e29b-41d4-a716-446655440000', 'annual', '2024-10-30', '2024-11-01', 3, 'Extended weekend', 'pending', NULL, NULL),
('e550e8400-e29b-41d4-a716-446655440012', 'c550e8400-e29b-41d4-a716-446655440000', 'sick', '2024-10-22', '2024-10-23', 2, 'flu symptoms', 'pending', NULL, NULL),
('e550e8400-e29b-41d4-a716-446655440014', 'c550e8400-e29b-41d4-a716-446655440000', 'annual', '2024-11-15', '2024-11-19', 5, 'Thanksgiving holiday extension', 'pending', NULL, NULL),

-- Rejected leave
('e550e8400-e29b-41d4-a716-446655440015', 'c550e8400-e29b-41d4-a716-446655440000', 'annual', '2024-10-28', '2024-11-08', 12, 'Long vacation during busy period', 'rejected', 'e550e8400-e29b-41d4-a716-446655440002', '2024-10-17 11:45:00+00');