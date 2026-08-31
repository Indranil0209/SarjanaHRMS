-- Non-IT Demo Credentials
-- This file contains demo users for the Non-IT login portal
-- All passwords are "password123" (bcrypt hashed)

-- ========================================================
-- CREATE NON-IT COMPANY
-- ========================================================

INSERT INTO companies (id, company_name, company_name_lower, industry, size, address, status, settings) VALUES
('c550e8400-e29b-41d4-a716-446655440001', 'Non-IT Services Company', 'non-it services company', 'Retail & Services', '51-200', '456 Service Street, Commerce City, CC 54321', 'active', '{"currency": "INR", "timezone": "Asia/Kolkata", "payrollFrequency": "Monthly", "trackingEnabled": true, "locationTrackingRequired": true}'::jsonb);

-- ========================================================
-- NON-IT DEMO USERS
-- ========================================================

-- Note: All passwords are hashed using bcrypt with the value "password123"
-- Hash: $2a$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi

-- Non-IT Super Admin
INSERT INTO users (id, email, password_hash, role, first_name, last_name, company_id, is_active, email_verified, created_at) VALUES
('550e8400-e29b-41d4-a716-446655440020', 'nonitadmin@company.com', '$2a$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi', 'super_admin', 'Non-IT', 'Admin', 'c550e8400-e29b-41d4-a716-446655440001', true, true, '2024-01-15 08:00:00+00');

-- Non-IT HR Manager
INSERT INTO users (id, email, password_hash, role, first_name, last_name, company_id, is_active, email_verified, created_at) VALUES
('550e8400-e29b-41d4-a716-446655440021', 'nonithr@company.com', '$2a$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi', 'hr_manager', 'Non-IT', 'HR Manager', 'c550e8400-e29b-41d4-a716-446655440001', true, true, '2024-01-15 08:00:00+00');

-- Non-IT Employees
INSERT INTO users (id, email, password_hash, role, first_name, last_name, company_id, is_active, email_verified, created_at) VALUES
('550e8400-e29b-41d4-a716-446655440022', 'nonitemployee1@company.com', '$2a$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi', 'employee', 'Priya', 'Sharma', 'c550e8400-e29b-41d4-a716-446655440001', true, true, '2024-02-01 08:00:00+00'),
('550e8400-e29b-41d4-a716-446655440023', 'nonitemployee2@company.com', '$2a$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi', 'employee', 'Rajesh', 'Patel', 'c550e8400-e29b-41d4-a716-446655440001', true, true, '2024-02-01 08:00:00+00'),
('550e8400-e29b-41d4-a716-446655440024', 'nonitemployee3@company.com', '$2a$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi', 'employee', 'Anjali', 'Verma', 'c550e8400-e29b-41d4-a716-446655440001', true, true, '2024-02-15 08:00:00+00');

-- ========================================================
-- CREATE NON-IT DEPARTMENTS
-- ========================================================

INSERT INTO departments (id, company_id, name, description, budget, created_at) VALUES
('d550e8400-e29b-41d4-a716-446655440010', 'c550e8400-e29b-41d4-a716-446655440001', 'Retail Operations', 'Store operations and customer service', 1500000.00, '2024-01-10 08:00:00+00'),
('d550e8400-e29b-41d4-a716-446655440011', 'c550e8400-e29b-41d4-a716-446655440001', 'Human Resources', 'People management and HR services', 600000.00, '2024-01-10 08:00:00+00'),
('d550e8400-e29b-41d4-a716-446655440012', 'c550e8400-e29b-41d4-a716-446655440001', 'Sales & Marketing', 'Sales and marketing initiatives', 1000000.00, '2024-01-10 08:00:00+00'),
('d550e8400-e29b-41d4-a716-446655440013', 'c550e8400-e29b-41d4-a716-446655440001', 'Finance', 'Financial operations', 700000.00, '2024-01-10 08:00:00+00');

-- ========================================================
-- CREATE JOB POSITIONS FOR NON-IT COMPANY
-- ========================================================

INSERT INTO job_positions (id, company_id, position_name, department_id, salary_grade, description, requirements) VALUES
('j550e8400-e29b-41d4-a716-446655440010', 'c550e8400-e29b-41d4-a716-446655440001', 'Store Manager', 'd550e8400-e29b-41d4-a716-446655440010', 'Grade A', 'Manage daily retail operations', '5+ years retail management experience'),
('j550e8400-e29b-41d4-a716-446655440011', 'c550e8400-e29b-41d4-a716-446655440001', 'Sales Associate', 'd550e8400-e29b-41d4-a716-446655440010', 'Grade C', 'Customer service and sales', '2+ years sales experience'),
('j550e8400-e29b-41d4-a716-446655440012', 'c550e8400-e29b-41d4-a716-446655440001', 'HR Coordinator', 'd550e8400-e29b-41d4-a716-446655440011', 'Grade B', 'HR support and administration', '3+ years HR experience'),
('j550e8400-e29b-41d4-a716-446655440013', 'c550e8400-e29b-41d4-a716-446655440001', 'Delivery Driver', 'd550e8400-e29b-41d4-a716-446655440012', 'Grade C', 'Product delivery and logistics', 'Valid driver license, 2+ years experience');

-- ========================================================
-- CREATE EMPLOYEES FOR NON-IT COMPANY
-- ========================================================

INSERT INTO employees (id, user_id, company_id, department_id, job_position_id, manager_id, first_name, last_name, email, phone, salary, hire_date, status) VALUES
-- Non-IT Admin
('e550e8400-e29b-41d4-a716-446655440020', '550e8400-e29b-41d4-a716-446655440020', 'c550e8400-e29b-41d4-a716-446655440001', 'd550e8400-e29b-41d4-a716-446655440011', 'j550e8400-e29b-41d4-a716-446655440012', NULL, 'Non-IT', 'Admin', 'nonitadmin@company.com', '+91-9876543210', 600000.00, '2024-01-01', 'active'),

-- Non-IT HR Manager
('e550e8400-e29b-41d4-a716-446655440021', '550e8400-e29b-41d4-a716-446655440021', 'c550e8400-e29b-41d4-a716-446655440001', 'd550e8400-e29b-41d4-a716-446655440011', 'j550e8400-e29b-41d4-a716-446655440012', 'e550e8400-e29b-41d4-a716-446655440020', 'Non-IT', 'HR Manager', 'nonithr@company.com', '+91-9876543211', 450000.00, '2024-01-15', 'active'),

-- Non-IT Employees
('e550e8400-e29b-41d4-a716-446655440022', '550e8400-e29b-41d4-a716-446655440022', 'c550e8400-e29b-41d4-a716-446655440001', 'd550e8400-e29b-41d4-a716-446655440010', 'j550e8400-e29b-41d4-a716-446655440010', 'e550e8400-e29b-41d4-a716-446655440021', 'Priya', 'Sharma', 'nonitemployee1@company.com', '+91-9876543212', 300000.00, '2024-02-01', 'active'),
('e550e8400-e29b-41d4-a716-446655440023', '550e8400-e29b-41d4-a716-446655440023', 'c550e8400-e29b-41d4-a716-446655440001', 'd550e8400-e29b-41d4-a716-446655440010', 'j550e8400-e29b-41d4-a716-446655440011', 'e550e8400-e29b-41d4-a716-446655440022', 'Rajesh', 'Patel', 'nonitemployee2@company.com', '+91-9876543213', 250000.00, '2024-02-01', 'active'),
('e550e8400-e29b-41d4-a716-446655440024', '550e8400-e29b-41d4-a716-446655440024', 'c550e8400-e29b-41d4-a716-446655440001', 'd550e8400-e29b-41d4-a716-446655440010', 'j550e8400-e29b-41d4-a716-446655440011', 'e550e8400-e29b-41d4-a716-446655440022', 'Anjali', 'Verma', 'nonitemployee3@company.com', '+91-9876543214', 250000.00, '2024-02-15', 'active');

-- ========================================================
-- UPDATE LEAVE BALANCES FOR NON-IT EMPLOYEES
-- ========================================================

INSERT INTO leave_balances (id, employee_id, company_id, leave_type, balance, used, pending, year) VALUES
('lb550e8400-e29b-41d4-a716-446655440020', 'e550e8400-e29b-41d4-a716-446655440020', 'c550e8400-e29b-41d4-a716-446655440001', 'annual', 20, 5, 0, 2024),
('lb550e8400-e29b-41d4-a716-446655440021', 'e550e8400-e29b-41d4-a716-446655440021', 'c550e8400-e29b-41d4-a716-446655440001', 'annual', 20, 3, 1, 2024),
('lb550e8400-e29b-41d4-a716-446655440022', 'e550e8400-e29b-41d4-a716-446655440022', 'c550e8400-e29b-41d4-a716-446655440001', 'annual', 20, 2, 0, 2024),
('lb550e8400-e29b-41d4-a716-446655440023', 'e550e8400-e29b-41d4-a716-446655440023', 'c550e8400-e29b-41d4-a716-446655440001', 'annual', 20, 0, 0, 2024),
('lb550e8400-e29b-41d4-a716-446655440024', 'e550e8400-e29b-41d4-a716-446655440024', 'c550e8400-e29b-41d4-a716-446655440001', 'annual', 20, 1, 0, 2024);

-- ========================================================
-- DEMO NOTE
-- ========================================================
-- Use these credentials to log in to the Non-IT Portal:
--
-- Super Admin:
--   Email: nonitadmin@company.com
--   Password: password123
--
-- HR Manager:
--   Email: nonithr@company.com
--   Password: password123
--
-- Employee 1 (Store Manager):
--   Email: nonitemployee1@company.com
--   Password: password123
--
-- Employee 2 (Sales Associate):
--   Email: nonitemployee2@company.com
--   Password: password123
--
-- Employee 3 (Sales Associate):
--   Email: nonitemployee3@company.com
--   Password: password123
-- ========================================================
