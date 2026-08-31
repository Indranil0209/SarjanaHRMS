-- Complete HR Management System Database Schema
-- This file contains the full schema with multi-tenant support, companies, demo data, and login information

-- Enable necessary extensions
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";
CREATE EXTENSION IF NOT EXISTS "pgcrypto";

-- Create custom types
CREATE TYPE user_role AS ENUM ('super_admin', 'admin', 'hr_manager', 'employee');
CREATE TYPE employment_status AS ENUM ('active', 'inactive', 'terminated', 'on_leave');
CREATE TYPE leave_status AS ENUM ('pending', 'approved', 'rejected', 'cancelled');
CREATE TYPE leave_type AS ENUM ('annual', 'sick', 'maternity', 'paternity', 'emergency', 'unpaid');
CREATE TYPE attendance_status AS ENUM ('present', 'absent', 'late', 'half_day', 'work_from_home');
CREATE TYPE payroll_status AS ENUM ('draft', 'processed', 'paid');
CREATE TYPE company_status AS ENUM ('active', 'suspended', 'inactive');

-- Companies table
CREATE TABLE companies (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    company_name VARCHAR(255) UNIQUE NOT NULL,
    company_name_lower VARCHAR(255) UNIQUE NOT NULL,
    domain VARCHAR(255),
    industry VARCHAR(100),
    size VARCHAR(50),
    address TEXT,
    logo TEXT,
    status company_status DEFAULT 'active',
    settings JSONB DEFAULT '{}',
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Users table (for authentication and user management)
CREATE TABLE users (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    email VARCHAR(255) UNIQUE NOT NULL,
    password_hash TEXT, -- Added for authentication
    full_name VARCHAR(255),
    first_name VARCHAR(100),
    last_name VARCHAR(100),
    role user_role DEFAULT 'employee',
    company_id UUID REFERENCES companies(id),
    phone_number VARCHAR(20),
    avatar_url TEXT,
    is_active BOOLEAN DEFAULT true,
    email_verified BOOLEAN DEFAULT false,
    last_login TIMESTAMP WITH TIME ZONE,
    status VARCHAR(20) DEFAULT 'available', -- New field for user availability status
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Departments table
CREATE TABLE departments (
    company_id UUID REFERENCES companies(id) NOT NULL,
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    name VARCHAR(100) NOT NULL,
    description TEXT,
    manager_id UUID REFERENCES users(id),
    budget DECIMAL(12,2),
    is_active BOOLEAN DEFAULT true,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Job positions table
CREATE TABLE job_positions (
    company_id UUID REFERENCES companies(id) NOT NULL,
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    title VARCHAR(100) NOT NULL,
    description TEXT,
    department_id UUID REFERENCES departments(id),
    salary_range_min DECIMAL(10,2),
    salary_range_max DECIMAL(10,2),
    requirements TEXT[],
    is_active BOOLEAN DEFAULT true,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Employees table (extends users with employee-specific data)
CREATE TABLE employees (
    company_id UUID REFERENCES companies(id) NOT NULL,
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID UNIQUE REFERENCES users(id) ON DELETE CASCADE,
    employee_id VARCHAR(20) UNIQUE NOT NULL,
    first_name VARCHAR(50) NOT NULL,
    last_name VARCHAR(50) NOT NULL,
    middle_name VARCHAR(50),
    date_of_birth DATE,
    gender VARCHAR(10),
    phone VARCHAR(20),
    address TEXT,
    emergency_contact_name VARCHAR(100),
    emergency_contact_phone VARCHAR(20),
    department_id UUID REFERENCES departments(id),
    job_position_id UUID REFERENCES job_positions(id),
    manager_id UUID REFERENCES employees(id),
    hire_date DATE NOT NULL,
    salary DECIMAL(10,2),
    employment_status employment_status DEFAULT 'active',
    work_location VARCHAR(100),
    profile_picture_url TEXT,
    national_id VARCHAR(50),
    tax_id VARCHAR(50),
    bank_account_number VARCHAR(50),
    bank_name VARCHAR(100),
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Attendance table
CREATE TABLE attendance (
    company_id UUID REFERENCES companies(id) NOT NULL,
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    employee_id UUID REFERENCES employees(id) ON DELETE CASCADE,
    date DATE NOT NULL,
    check_in_time TIME,
    check_out_time TIME,
    break_start_time TIME,
    break_end_time TIME,
    total_hours DECIMAL(4,2),
    status attendance_status DEFAULT 'present',
    notes TEXT,
    location VARCHAR(100),
    ip_address INET,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    UNIQUE(employee_id, date)
);

-- Leave requests table
CREATE TABLE leave_requests (
    company_id UUID REFERENCES companies(id) NOT NULL,
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    employee_id UUID REFERENCES employees(id) ON DELETE CASCADE,
    leave_type leave_type NOT NULL,
    start_date DATE NOT NULL,
    end_date DATE NOT NULL,
    total_days INTEGER NOT NULL,
    reason TEXT NOT NULL,
    status leave_status DEFAULT 'pending',
    approved_by UUID REFERENCES employees(id),
    approved_at TIMESTAMP WITH TIME ZONE,
    rejection_reason TEXT,
    documents TEXT[], -- URLs to supporting documents
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Leave balances table
CREATE TABLE leave_balances (
    company_id UUID REFERENCES companies(id) NOT NULL,
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    employee_id UUID REFERENCES employees(id) ON DELETE CASCADE,
    year INTEGER NOT NULL,
    leave_type leave_type NOT NULL,
    allocated_days INTEGER DEFAULT 0,
    used_days INTEGER DEFAULT 0,
    remaining_days INTEGER DEFAULT 0,
    carried_forward_days INTEGER DEFAULT 0,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    UNIQUE(employee_id, year, leave_type)
);

-- Payroll table
CREATE TABLE payroll (
    company_id UUID REFERENCES companies(id) NOT NULL,
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    employee_id UUID REFERENCES employees(id) ON DELETE CASCADE,
    pay_period_start DATE NOT NULL,
    pay_period_end DATE NOT NULL,
    basic_salary DECIMAL(10,2) NOT NULL,
    overtime_hours DECIMAL(4,2) DEFAULT 0,
    overtime_rate DECIMAL(6,2) DEFAULT 0,
    bonus DECIMAL(10,2) DEFAULT 0,
    allowances DECIMAL(10,2) DEFAULT 0,
    gross_salary DECIMAL(10,2) NOT NULL,
    tax_deduction DECIMAL(10,2) DEFAULT 0,
    insurance_deduction DECIMAL(10,2) DEFAULT 0,
    other_deductions DECIMAL(10,2) DEFAULT 0,
    total_deductions DECIMAL(10,2) DEFAULT 0,
    net_salary DECIMAL(10,2) NOT NULL,
    status payroll_status DEFAULT 'draft',
    processed_by UUID REFERENCES employees(id),
    processed_at TIMESTAMP WITH TIME ZONE,
    notes TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Performance reviews table
CREATE TABLE performance_reviews (
    company_id UUID REFERENCES companies(id) NOT NULL,
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    employee_id UUID REFERENCES employees(id) ON DELETE CASCADE,
    reviewer_id UUID REFERENCES employees(id),
    review_period_start DATE NOT NULL,
    review_period_end DATE NOT NULL,
    goals TEXT[],
    achievements TEXT[],
    areas_for_improvement TEXT[],
    overall_rating INTEGER CHECK (overall_rating >= 1 AND overall_rating <= 5),
    comments TEXT,
    employee_comments TEXT,
    status VARCHAR(20) DEFAULT 'draft',
    submitted_at TIMESTAMP WITH TIME ZONE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Training records table
CREATE TABLE training_records (
    company_id UUID REFERENCES companies(id) NOT NULL,
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    employee_id UUID REFERENCES employees(id) ON DELETE CASCADE,
    training_name VARCHAR(200) NOT NULL,
    training_provider VARCHAR(100),
    start_date DATE,
    end_date DATE,
    completion_status VARCHAR(20) DEFAULT 'enrolled',
    certificate_url TEXT,
    cost DECIMAL(8,2),
    notes TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Company announcements table
CREATE TABLE announcements (
    company_id UUID REFERENCES companies(id) NOT NULL,
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    title VARCHAR(200) NOT NULL,
    content TEXT NOT NULL,
    author_id UUID REFERENCES employees(id),
    priority VARCHAR(20) DEFAULT 'normal',
    is_active BOOLEAN DEFAULT true,
    target_departments UUID[],
    target_employees UUID[],
    expiry_date TIMESTAMP WITH TIME ZONE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Audit log table
CREATE TABLE audit_logs (
    company_id UUID REFERENCES companies(id),
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID REFERENCES users(id),
    action VARCHAR(100) NOT NULL,
    table_name VARCHAR(50) NOT NULL,
    record_id UUID,
    old_values JSONB,
    new_values JSONB,
    ip_address INET,
    user_agent TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Salary table
CREATE TABLE salaries (
    company_id UUID REFERENCES companies(id) NOT NULL,
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    employee_id UUID REFERENCES employees(id) ON DELETE CASCADE,
    base_salary DECIMAL(10,2) NOT NULL,
    currency VARCHAR(3) DEFAULT 'INR',
    bonus DECIMAL(10,2) DEFAULT 0,
    deductions JSONB DEFAULT '{}',
    effective_date DATE NOT NULL,
    payment_frequency VARCHAR(20) DEFAULT 'Monthly',
    tax_rate DECIMAL(5,2) DEFAULT 0.00,
    notes TEXT,
    is_active BOOLEAN DEFAULT true,
    created_by UUID REFERENCES employees(id),
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Create indexes for better performance
CREATE INDEX idx_users_email ON users(email);
CREATE INDEX idx_users_role ON users(role);
CREATE INDEX idx_users_company_id ON users(company_id);
CREATE INDEX idx_users_status ON users(status); -- New index for status column
CREATE INDEX idx_companies_name ON companies(company_name);
CREATE INDEX idx_companies_name_lower ON companies(company_name_lower);
CREATE INDEX idx_employees_company_id ON employees(company_id);
CREATE INDEX idx_departments_company_id ON departments(company_id);
CREATE INDEX idx_job_positions_company_id ON job_positions(company_id);
CREATE INDEX idx_attendance_company_id ON attendance(company_id);
CREATE INDEX idx_leave_requests_company_id ON leave_requests(company_id);
CREATE INDEX idx_leave_balances_company_id ON leave_balances(company_id);
CREATE INDEX idx_payroll_company_id ON payroll(company_id);
CREATE INDEX idx_performance_reviews_company_id ON performance_reviews(company_id);
CREATE INDEX idx_training_records_company_id ON training_records(company_id);
CREATE INDEX idx_announcements_company_id ON announcements(company_id);
CREATE INDEX idx_audit_logs_company_id ON audit_logs(company_id);
CREATE INDEX idx_salaries_company_id ON salaries(company_id);
CREATE INDEX idx_employees_user_id ON employees(user_id);
CREATE INDEX idx_employees_department_id ON employees(department_id);
CREATE INDEX idx_employees_manager_id ON employees(manager_id);
CREATE INDEX idx_attendance_employee_date ON attendance(employee_id, date);
CREATE INDEX idx_leave_requests_employee_id ON leave_requests(employee_id);
CREATE INDEX idx_payroll_employee_id ON payroll(employee_id);
CREATE INDEX idx_audit_logs_user_id ON audit_logs(user_id);
CREATE INDEX idx_audit_logs_created_at ON audit_logs(created_at);
CREATE INDEX idx_salaries_employee_id ON salaries(employee_id);
CREATE INDEX idx_salaries_effective_date ON salaries(effective_date);
CREATE INDEX idx_salaries_is_active ON salaries(is_active);

-- Create updated_at trigger function
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ language 'plpgsql';

-- Apply updated_at triggers to all tables
CREATE TRIGGER update_users_updated_at BEFORE UPDATE ON users FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
CREATE TRIGGER update_companies_updated_at BEFORE UPDATE ON companies FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
CREATE TRIGGER update_departments_updated_at BEFORE UPDATE ON departments FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
CREATE TRIGGER update_job_positions_updated_at BEFORE UPDATE ON job_positions FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
CREATE TRIGGER update_employees_updated_at BEFORE UPDATE ON employees FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
CREATE TRIGGER update_attendance_updated_at BEFORE UPDATE ON attendance FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
CREATE TRIGGER update_leave_requests_updated_at BEFORE UPDATE ON leave_requests FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
CREATE TRIGGER update_leave_balances_updated_at BEFORE UPDATE ON leave_balances FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
CREATE TRIGGER update_payroll_updated_at BEFORE UPDATE ON payroll FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
CREATE TRIGGER update_performance_reviews_updated_at BEFORE UPDATE ON performance_reviews FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
CREATE TRIGGER update_training_records_updated_at BEFORE UPDATE ON training_records FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
CREATE TRIGGER update_announcements_updated_at BEFORE UPDATE ON announcements FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
CREATE TRIGGER update_audit_logs_updated_at BEFORE UPDATE ON audit_logs FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
CREATE TRIGGER update_salaries_updated_at BEFORE UPDATE ON salaries FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

-- Row Level Security (RLS) Policies
-- Note: For development/testing, you may want to temporarily disable RLS
-- To disable: ALTER TABLE table_name DISABLE ROW LEVEL SECURITY;
-- To enable: ALTER TABLE table_name ENABLE ROW LEVEL SECURITY;

-- Enable RLS on users table
ALTER TABLE users ENABLE ROW LEVEL SECURITY;

-- Users can only access their own data within their company
CREATE POLICY "Users can only access their company data" ON users
  FOR ALL USING (company_id IN (SELECT company_id FROM users WHERE id = auth.uid()));

-- For other tables, restrict access by company
ALTER TABLE companies ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Companies are publicly readable" ON companies FOR SELECT USING (true);
CREATE POLICY "Companies are insertable by admins" ON companies FOR INSERT WITH CHECK (true);

ALTER TABLE employees ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Employees can only access their company data" ON employees
  FOR ALL USING (company_id IN (SELECT company_id FROM users WHERE id = auth.uid()));

ALTER TABLE departments ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Departments can only be accessed by company users" ON departments
  FOR ALL USING (company_id IN (SELECT company_id FROM users WHERE id = auth.uid()));

ALTER TABLE job_positions ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Job positions can only be accessed by company users" ON job_positions
  FOR ALL USING (company_id IN (SELECT company_id FROM users WHERE id = auth.uid()));

ALTER TABLE attendance ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Attendance can only be accessed by company users" ON attendance
  FOR ALL USING (company_id IN (SELECT company_id FROM users WHERE id = auth.uid()));

ALTER TABLE leave_requests ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Leave requests can only be accessed by company users" ON leave_requests
  FOR ALL USING (company_id IN (SELECT company_id FROM users WHERE id = auth.uid()));

ALTER TABLE leave_balances ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Leave balances can only be accessed by company users" ON leave_balances
  FOR ALL USING (company_id IN (SELECT company_id FROM users WHERE id = auth.uid()));

ALTER TABLE payroll ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Payroll can only be accessed by company users" ON payroll
  FOR ALL USING (company_id IN (SELECT company_id FROM users WHERE id = auth.uid()));

ALTER TABLE performance_reviews ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Performance reviews can only be accessed by company users" ON performance_reviews
  FOR ALL USING (company_id IN (SELECT company_id FROM users WHERE id = auth.uid()));

ALTER TABLE training_records ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Training records can only be accessed by company users" ON training_records
  FOR ALL USING (company_id IN (SELECT company_id FROM users WHERE id = auth.uid()));

ALTER TABLE announcements ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Announcements can only be accessed by company users" ON announcements
  FOR ALL USING (company_id IN (SELECT company_id FROM users WHERE id = auth.uid()));

ALTER TABLE audit_logs ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Audit logs can only be accessed by company users" ON audit_logs
  FOR ALL USING (company_id IN (SELECT company_id FROM users WHERE id = auth.uid()));

ALTER TABLE salaries ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Salaries can only be accessed by company users" ON salaries
  FOR ALL USING (company_id IN (SELECT company_id FROM users WHERE id = auth.uid()));

-- Insert Demo Companies
INSERT INTO companies (id, company_name, company_name_lower, industry, size, address, status, settings) VALUES
('c550e8400-e29b-41d4-a716-446655440000', 'Default Company', 'default company', 'Technology', '51-200', '123 Business Avenue, Tech City, TC 12345', 'active', '{"currency": "INR", "timezone": "Asia/Kolkata", "payrollFrequency": "Monthly"}'),
('c550e8400-e29b-41d4-a716-446655440001', 'Global Solutions Ltd', 'global solutions ltd', 'Consulting', '201-500', '456 Corporate Blvd, Enterprise City, EC 67890', 'active', '{"currency": "USD", "timezone": "America/New_York", "payrollFrequency": "Bi-Weekly"}'),
('c550e8400-e29b-41d4-a716-446655440002', 'InnovateTech Inc', 'innovatetech inc', 'Software', '1001+', '789 Innovation Drive, Silicon Valley, CA 94000', 'active', '{"currency": "USD", "timezone": "America/Los_Angeles", "payrollFrequency": "Semi-Monthly"}');

-- Insert Demo Users (Authentication users)
-- Password hash for "password123" using bcrypt
INSERT INTO users (id, email, password_hash, role, company_id, is_active, email_verified, created_at) VALUES
-- Super Admin
('550e8400-e29b-41d4-a716-446655440000', 'admin@company.com', '$2a$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi', 'super_admin', 'c550e8400-e29b-41d4-a716-446655440000', true, true, '2024-01-15 08:00:00+00'),

-- Admin
('550e8400-e29b-41d4-a716-446655440001', 'john.admin@company.com', '$2a$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi', 'admin', 'c550e8400-e29b-41d4-a716-446655440000', true, true, '2024-01-15 08:00:00+00'),

-- HR Managers
('550e8400-e29b-41d4-a716-446655440002', 'sarah.hr@company.com', '$2a$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi', 'hr_manager', 'c550e8400-e29b-41d4-a716-446655440000', true, true, '2024-01-15 08:00:00+00'),
('550e8400-e29b-41d4-a716-446655440003', 'emma.hr@company.com', '$2a$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi', 'hr_manager', 'c550e8400-e29b-41d4-a716-446655440000', true, true, '2024-01-20 08:00:00+00'),

-- Employees
('550e8400-e29b-41d4-a716-446655440004', 'mike.johnson@company.com', '$2a$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi', 'employee', 'c550e8400-e29b-41d4-a716-446655440000', true, true, '2024-02-01 08:00:00+00'),
('550e8400-e29b-41d4-a716-446655440005', 'jane.smith@company.com', '$2a$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi', 'employee', 'c550e8400-e29b-41d4-a716-446655440000', true, true, '2024-02-01 08:00:00+00'),
('550e8400-e29b-41d4-a716-446655440006', 'alex.chen@company.com', '$2a$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi', 'employee', 'c550e8400-e29b-41d4-a716-446655440000', true, true, '2024-02-15 08:00:00+00'),
('550e8400-e29b-41d4-a716-446655440007', 'lisa.wang@company.com', '$2a$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi', 'employee', 'c550e8400-e29b-41d4-a716-446655440000', true, true, '2024-02-15 08:00:00+00'),
('550e8400-e29b-41d4-a716-446655440008', 'david.brown@company.com', '$2a$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi', 'employee', 'c550e8400-e29b-41d4-a716-446655440000', true, true, '2024-03-01 08:00:00+00'),
('550e8400-e29b-41d4-a716-446655440009', 'emily.davis@company.com', '$2a$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi', 'employee', 'c550e8400-e29b-41d4-a716-446655440000', true, true, '2024-03-01 08:00:00+00'),
('550e8400-e29b-41d4-a716-446655440010', 'robert.wilson@company.com', '$2a$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi', 'employee', 'c550e8400-e29b-41d4-a716-446655440000', true, true, '2024-03-15 08:00:00+00'),
('550e8400-e29b-41d4-a716-446655440011', 'maria.garcia@company.com', '$2a$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi', 'employee', 'c550e8400-e29b-41d4-a716-446655440000', true, true, '2024-03-15 08:00:00+00'),
('550e8400-e29b-41d4-a716-446655440012', 'james.lee@company.com', '$2a$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi', 'employee', 'c550e8400-e29b-41d4-a716-446655440000', true, true, '2024-04-01 08:00:00+00'),
('550e8400-e29b-41d4-a716-446655440013', 'anna.taylor@company.com', '$2a$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi', 'employee', 'c550e8400-e29b-41d4-a716-446655440000', true, true, '2024-04-01 08:00:00+00'),
('550e8400-e29b-41d4-a716-446655440014', 'kevin.martinez@company.com', '$2a$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi', 'employee', 'c550e8400-e29b-41d4-a716-446655440000', true, true, '2024-04-15 08:00:00+00'),
('550e8400-e29b-41d4-a716-446655440015', 'rachel.white@company.com', '$2a$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi', 'employee', 'c550e8400-e29b-41d4-a716-446655440000', true, true, '2024-04-15 08:00:00+00');

-- Insert Departments
INSERT INTO departments (id, company_id, name, description, budget, created_at) VALUES
('d550e8400-e29b-41d4-a716-446655440000', 'c550e8400-e29b-41d4-a716-446655440000', 'Engineering', 'Software development and technical operations', 2500000.00, '2024-01-10 08:00:00+00'),
('d550e8400-e29b-41d4-a716-446655440001', 'c550e8400-e29b-41d4-a716-446655440000', 'Human Resources', 'People management and organizational development', 800000.00, '2024-01-10 08:00:00+00'),
('d550e8400-e29b-41d4-a716-446655440002', 'c550e8400-e29b-41d4-a716-446655440000', 'Sales', 'Customer acquisition and revenue generation', 1800000.00, '2024-01-10 08:00:00+00'),
('d550e8400-e29b-41d4-a716-446655440003', 'c550e8400-e29b-41d4-a716-446655440000', 'Marketing', 'Brand promotion and customer engagement', 1200000.00, '2024-01-10 08:00:00+00'),
('d550e8400-e29b-41d4-a716-446655440004', 'c550e8400-e29b-41d4-a716-446655440000', 'Finance', 'Financial planning and accounting', 900000.00, '2024-01-10 08:00:00+00'),
('d550e8400-e29b-41d4-a716-446655440005', 'c550e8400-e29b-41d4-a716-446655440000', 'Operations', 'Business operations and support', 700000.00, '2024-01-10 08:00:00+00');

-- Insert Job Positions
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

-- Insert Employees
INSERT INTO employees (id, company_id, user_id, employee_id, first_name, last_name, date_of_birth, gender, phone, address, emergency_contact_name, emergency_contact_phone, department_id, job_position_id, hire_date, salary, employment_status, work_location, created_at) VALUES
-- Super Admin
('e550e8400-e29b-41d4-a716-446655440000', 'c550e8400-e29b-41d4-a716-446655440000', '550e8400-e29b-41d4-a716-446655440000', 'EMP001', 'Super', 'Admin', '1985-05-15', 'Male', '+1234567890', '123 Admin St, Tech City, TC 12345', 'Jane Admin', '+1234567891', 'd550e8400-e29b-41d4-a716-446655440000', 'j550e8400-e29b-41d4-a716-446655440000', '2024-01-15', 200000.00, 'active', 'Headquarters', '2024-01-15 08:00:00+00'),

-- Admin
('e550e8400-e29b-41d4-a716-446655440001', 'c550e8400-e29b-41d4-a716-446655440000', '550e8400-e29b-41d4-a716-446655440001', 'EMP002', 'John', 'Admin', '1988-03-20', 'Male', '+1234567892', '456 Tech Ave, Innovation City, IC 54321', 'Mary Admin', '+1234567893', 'd550e8400-e29b-41d4-a716-446655440000', 'j550e8400-e29b-41d4-a716-446655440000', '2024-01-15', 180000.00, 'active', 'Headquarters', '2024-01-15 08:00:00+00'),

-- HR Managers
('e550e8400-e29b-41d4-a716-446655440002', 'c550e8400-e29b-41d4-a716-446655440000', '550e8400-e29b-41d4-a716-446655440002', 'EMP003', 'Sarah', 'Johnson', '1990-07-10', 'Female', '+1234567894', '789 HR Plaza, People City, PC 67890', 'Mike Johnson', '+1234567895', 'd550e8400-e29b-41d4-a716-446655440001', 'j550e8400-e29b-41d4-a716-446655440003', '2024-01-15', 85000.00, 'active', 'Headquarters', '2024-01-15 08:00:00+00'),

('e550e8400-e29b-41d4-a716-446655440003', 'c550e8400-e29b-41d4-a716-446655440000', '550e8400-e29b-41d4-a716-446655440003', 'EMP004', 'Emma', 'Wilson', '1987-11-25', 'Female', '+1234567896', '321 Resource Rd, Talent Town, TT 98765', 'Tom Wilson', '+1234567897', 'd550e8400-e29b-41d4-a716-446655440001', 'j550e8400-e29b-41d4-a716-446655440004', '2024-01-20', 65000.00, 'active', 'Headquarters', '2024-01-20 08:00:00+00'),

-- Engineering Employees
('e550e8400-e29b-41d4-a716-446655440004', 'c550e8400-e29b-41d4-a716-446655440000', '550e8400-e29b-41d4-a716-446655440004', 'EMP005', 'Mike', 'Johnson', '1992-04-18', 'Male', '+1234567898', '654 Code St, Dev Valley, DV 13579', 'Lisa Johnson', '+1234567899', 'd550e8400-e29b-41d4-a716-446655440000', 'j550e8400-e29b-41d4-a716-446655440001', '2024-02-01', 95000.00, 'active', 'Remote', '2024-02-01 08:00:00+00'),

('e550e8400-e29b-41d4-a716-446655440005', 'c550e8400-e29b-41d4-a716-446655440000', '550e8400-e29b-41d4-a716-446655440005', 'EMP006', 'Jane', 'Smith', '1989-09-12', 'Female', '+1234567900', '987 Software Blvd, Algorithm City, AC 24680', 'John Smith', '+1234567901', 'd550e8400-e29b-41d4-a716-446655440000', 'j550e8400-e29b-41d4-a716-446655440000', '2024-02-01', 120000.00, 'active', 'Headquarters', '2024-02-01 08:00:00+00'),

('e550e8400-e29b-41d4-a716-446655440006', 'c550e8400-e29b-41d4-a716-446655440000', '550e8400-e29b-41d4-a716-446655440006', 'EMP007', 'Alex', 'Chen', '1993-12-03', 'Male', '+1234567902', '147 DevOps Lane, Cloud City, CC 36912', 'Lucy Chen', '+1234567903', 'd550e8400-e29b-41d4-a716-446655440000', 'j550e8400-e29b-41d4-a716-446655440002', '2024-02-15', 110000.00, 'active', 'Remote', '2024-02-15 08:00:00+00'),

-- Sales Employees
('e550e8400-e29b-41d4-a716-446655440007', 'c550e8400-e29b-41d4-a716-446655440000', '550e8400-e29b-41d4-a716-446655440007', 'EMP008', 'Lisa', 'Wang', '1991-06-28', 'Female', '+1234567904', '258 Sales St, Revenue City, RC 47025', 'Kevin Wang', '+1234567905', 'd550e8400-e29b-41d4-a716-446655440002', 'j550e8400-e29b-41d4-a716-446655440005', '2024-02-15', 100000.00, 'active', 'Headquarters', '2024-02-15 08:00:00+00'),

('e550e8400-e29b-41d4-a716-446655440008', 'c550e8400-e29b-41d4-a716-446655440000', '550e8400-e29b-41d4-a716-446655440008', 'EMP009', 'David', 'Brown', '1994-01-14', 'Male', '+1234567906', '369 Deal Ave, Client City, CC 58136', 'Sarah Brown', '+1234567907', 'd550e8400-e29b-41d4-a716-446655440002', 'j550e8400-e29b-41d4-a716-446655440006', '2024-03-01', 65000.00, 'active', 'Field', '2024-03-01 08:00:00+00'),

-- Marketing Employees
('e550e8400-e29b-41d4-a716-446655440009', 'c550e8400-e29b-41d4-a716-446655440000', '550e8400-e29b-41d4-a716-446655440009', 'EMP010', 'Emily', 'Davis', '1990-08-07', 'Female', '+1234567908', '741 Brand Blvd, Creative City, CC 69247', 'Michael Davis', '+1234567909', 'd550e8400-e29b-41d4-a716-446655440003', 'j550e8400-e29b-41d4-a716-446655440007', '2024-03-01', 85000.00, 'active', 'Headquarters', '2024-03-01 08:00:00+00'),

('e550e8400-e29b-41d4-a716-446655440010', 'c550e8400-e29b-41d4-a716-446655440000', '550e8400-e29b-41d4-a716-446655440010', 'EMP011', 'Robert', 'Wilson', '1995-02-22', 'Male', '+1234567910', '852 Content St, Media Town, MT 70358', 'Jennifer Wilson', '+1234567911', 'd550e8400-e29b-41d4-a716-446655440003', 'j550e8400-e29b-41d4-a716-446655440008', '2024-03-15', 55000.00, 'active', 'Remote', '2024-03-15 08:00:00+00'),

-- Finance Employees
('e550e8400-e29b-41d4-a716-446655440011', 'c550e8400-e29b-41d4-a716-446655440000', '550e8400-e29b-41d4-a716-446655440011', 'EMP012', 'Maria', 'Garcia', '1988-10-31', 'Female', '+1234567912', '963 Finance Rd, Money City, MC 81469', 'Carlos Garcia', '+1234567913', 'd550e8400-e29b-41d4-a716-446655440004', 'j550e8400-e29b-41d4-a716-446655440009', '2024-03-15', 95000.00, 'active', 'Headquarters', '2024-03-15 08:00:00+00'),

('e550e8400-e29b-41d4-a716-446655440012', 'c550e8400-e29b-41d4-a716-446655440000', '550e8400-e29b-41d4-a716-446655440012', 'EMP013', 'James', 'Lee', '1993-05-16', 'Male', '+1234567914', '074 Ledger Lane, Accounting Ave, AA 92570', 'Amy Lee', '+1234567915', 'd550e8400-e29b-41d4-a716-446655440004', 'j550e8400-e29b-41d4-a716-446655440010', '2024-04-01', 55000.00, 'active', 'Headquarters', '2024-04-01 08:00:00+00'),

-- Operations Employees
('e550e8400-e29b-41d4-a716-446655440013', 'c550e8400-e29b-41d4-a716-446655440000', '550e8400-e29b-41d4-a716-446655440013', 'EMP014', 'Anna', 'Taylor', '1991-12-09', 'Female', '+1234567916', '185 Operations Blvd, Process City, PC 03681', 'Mark Taylor', '+1234567917', 'd550e8400-e29b-41d4-a716-446655440005', 'j550e8400-e29b-41d4-a716-446655440006', '2024-04-01', 70000.00, 'active', 'Headquarters', '2024-04-01 08:00:00+00'),

('e550e8400-e29b-41d4-a716-446655440014', 'c550e8400-e29b-41d4-a716-446655440000', '550e8400-e29b-41d4-a716-446655440014', 'EMP015', 'Kevin', 'Martinez', '1989-07-24', 'Male', '+1234567918', '296 Support St, Service City, SC 14792', 'Rosa Martinez', '+1234567919', 'd550e8400-e29b-41d4-a716-446655440005', 'j550e8400-e29b-41d4-a716-446655440006', '2024-04-15', 68000.00, 'active', 'Headquarters', '2024-04-15 08:00:00+00'),

('e550e8400-e29b-41d4-a716-446655440015', 'c550e8400-e29b-41d4-a716-446655440000', '550e8400-e29b-41d4-a716-446655440015', 'EMP016', 'Rachel', 'White', '1994-03-11', 'Female', '+1234567920', '407 Quality Rd, Excellence City, EC 25803', 'Daniel White', '+1234567921', 'd550e8400-e29b-41d4-a716-446655440005', 'j550e8400-e29b-41d4-a716-446655440006', '2024-04-15', 66000.00, 'active', 'Headquarters', '2024-04-15 08:00:00+00');

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

-- Insert Leave Balances for all employees (2024)
INSERT INTO leave_balances (company_id, employee_id, year, leave_type, allocated_days, used_days, remaining_days) 
SELECT 
  e.company_id,
  e.id,
  2024,
  'annual',
  25,
  FLOOR(RANDOM() * 10)::INTEGER,
  25 - FLOOR(RANDOM() * 10)::INTEGER
FROM employees e;

INSERT INTO leave_balances (company_id, employee_id, year, leave_type, allocated_days, used_days, remaining_days) 
SELECT 
  e.company_id,
  e.id,
  2024,
  'sick',
  12,
  FLOOR(RANDOM() * 5)::INTEGER,
  12 - FLOOR(RANDOM() * 5)::INTEGER
FROM employees e;

-- Insert Sample Attendance Records (Last 30 days)
INSERT INTO attendance (company_id, employee_id, date, check_in_time, check_out_time, total_hours, status)
SELECT 
  e.company_id,
  e.id,
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

-- Insert Leave Requests
INSERT INTO leave_requests (company_id, employee_id, leave_type, start_date, end_date, total_days, reason, status, approved_by, approved_at)
VALUES
-- Approved leaves
('c550e8400-e29b-41d4-a716-446655440000', 'e550e8400-e29b-41d4-a716-446655440004', 'annual', '2024-10-25', '2024-10-27', 3, 'Family vacation', 'approved', 'e550e8400-e29b-41d4-a716-446655440002', '2024-10-15 10:30:00+00'),
('c550e8400-e29b-41d4-a716-446655440000', 'e550e8400-e29b-41d4-a716-44665