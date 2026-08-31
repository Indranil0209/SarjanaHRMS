-- HR Management System - Complete Database Schema (Part 4)
-- This file contains payroll, performance reviews, training records, announcements, and audit logs demo data

-- ========================================================
-- DEMO PAYROLL RECORDS
-- ========================================================

INSERT INTO payroll (employee_id, company_id, pay_period_start, pay_period_end, basic_salary, overtime_hours, overtime_rate, bonus, gross_salary, tax_deduction, insurance_deduction, other_deductions, total_deductions, net_salary, status, processed_by, processed_at)
SELECT 
  e.id,
  'c550e8400-e29b-41d4-a716-446655440000',
  '2024-09-01'::date,
  '2024-09-30'::date,
  e.salary / 12,
  FLOOR(RANDOM() * 20)::DECIMAL,
  (e.salary / 12 / 160) * 1.5, -- 1.5x hourly rate for overtime
  CASE WHEN RANDOM() > 0.7 THEN FLOOR(RANDOM() * 5000) ELSE 0 END,
  (e.salary / 12) + (FLOOR(RANDOM() * 20) * (e.salary / 12 / 160) * 1.5) + CASE WHEN RANDOM() > 0.7 THEN FLOOR(RANDOM() * 5000) ELSE 0 END,
  ((e.salary / 12) * 0.22),  -- 22% tax
  ((e.salary / 12) * 0.05),  -- 5% insurance
  ((e.salary / 12) * 0.02),  -- 2% other deductions
  ((e.salary / 12) * 0.29),  -- Total 29% deductions
  ((e.salary / 12) * 0.71),  -- Net after deductions
  'paid',
  'e550e8400-e29b-41d4-a716-446655440002',
  '2024-10-05 16:30:00+00'
FROM employees e;

-- ========================================================
-- DEMO PERFORMANCE REVIEWS
-- ========================================================

INSERT INTO performance_reviews (employee_id, company_id, reviewer_id, review_period_start, review_period_end, goals, achievements, areas_for_improvement, overall_rating, comments, status, submitted_at)
VALUES
('e550e8400-e29b-41d4-a716-446655440004', 'c550e8400-e29b-41d4-a716-446655440000', 'e550e8400-e29b-41d4-a716-446655440005', '2024-01-01', '2024-06-30', 
 ARRAY['Complete 3 major projects', 'Improve code quality', 'Mentor junior developers'], 
 ARRAY['Successfully delivered 4 projects', 'Reduced bugs by 30%', 'Mentored 2 junior developers'], 
 ARRAY['Time management', 'Documentation'], 
 4, 'Excellent performance, exceeded expectations', 'completed', '2024-07-15 14:30:00+00'),

('e550e8400-e29b-41d4-a716-446655440006', 'c550e8400-e29b-41d4-a716-446655440000', 'e550e8400-e29b-41d4-a716-446655440005', '2024-01-01', '2024-06-30',
 ARRAY['Lead architectural decisions', 'Improve team productivity', 'Deliver on-time releases'],
 ARRAY['Designed scalable architecture', 'Increased team velocity by 25%', '100% on-time delivery'],
 ARRAY['Cross-team collaboration'],
 5, 'Outstanding technical leadership and delivery', 'completed', '2024-07-15 15:00:00+00'),

('e550e8400-e29b-41d4-a716-446655440008', 'c550e8400-e29b-41d4-a716-446655440000', 'e550e8400-e29b-41d4-a716-446655440007', '2024-01-01', '2024-06-30',
 ARRAY['Achieve sales targets', 'Expand client base', 'Improve customer satisfaction'],
 ARRAY['Exceeded targets by 15%', 'Added 12 new clients', '95% customer satisfaction'],
 ARRAY['CRM usage', 'Follow-up consistency'],
 4, 'Strong sales performance with great customer relationships', 'completed', '2024-07-20 10:15:00+00');

-- ========================================================
-- DEMO TRAINING RECORDS
-- ========================================================

INSERT INTO training_records (employee_id, company_id, training_name, training_provider, start_date, end_date, completion_status, cost)
VALUES
('e550e8400-e29b-41d4-a716-446655440004', 'c550e8400-e29b-41d4-a716-446655440000', 'Advanced React Development', 'TechEducation Inc', '2024-03-01', '2024-03-15', 'completed', 1200.00),
('e550e8400-e29b-41d4-a716-446655440005', 'c550e8400-e29b-41d4-a716-446655440000', 'Leadership in Tech', 'Management Academy', '2024-04-01', '2024-04-30', 'completed', 2500.00),
('e550e8400-e29b-41d4-a716-446655440006', 'c550e8400-e29b-41d4-a716-446655440000', 'AWS Solutions Architect', 'Amazon Web Services', '2024-05-01', '2024-06-01', 'completed', 3000.00),
('e550e8400-e29b-41d4-a716-446655440008', 'c550e8400-e29b-41d4-a716-446655440000', 'Advanced Sales Techniques', 'SalesForce Academy', '2024-02-15', '2024-03-01', 'completed', 800.00),
('e550e8400-e29b-41d4-a716-446655440009', 'c550e8400-e29b-41d4-a716-446655440000', 'Digital Marketing Strategy', 'Marketing Institute', '2024-06-01', '2024-06-30', 'enrolled', 1500.00),
('e550e8400-e29b-41d4-a716-446655440010', 'c550e8400-e29b-41d4-a716-446655440000', 'Content Creation Mastery', 'Creative Learning Hub', '2024-07-01', '2024-08-01', 'in_progress', 900.00);

-- ========================================================
-- DEMO COMPANY ANNOUNCEMENTS
-- ========================================================

INSERT INTO announcements (company_id, title, content, author_id, priority, target_departments, expiry_date)
VALUES
('c550e8400-e29b-41d4-a716-446655440000', 'Q3 All-Hands Meeting', 'Join us for the quarterly all-hands meeting on October 25th at 2:00 PM. We will discuss company performance, upcoming projects, and celebrate team achievements. Attendance is mandatory for all employees.', 'e550e8400-e29b-41d4-a716-446655440000', 'high', NULL, '2024-10-25 18:00:00+00'),

('c550e8400-e29b-41d4-a716-446655440000', 'New Health Insurance Plans', 'We are excited to announce new health insurance options starting January 1st, 2025. The new plans offer better coverage and lower deductibles. HR will be hosting information sessions next week.', 'e550e8400-e29b-41d4-a716-446655440002', 'normal', ARRAY['d550e8400-e29b-41d4-a716-446655440001'], '2024-12-31 23:59:59+00'),

('c550e8400-e29b-41d4-a716-446655440000', 'Office Renovation Update', 'The office renovation project will begin on November 1st. Engineering and Marketing teams will be working remotely for two weeks. Please coordinate with your managers for workspace arrangements.', 'e550e8400-e29b-41d4-a716-446655440001', 'high', ARRAY['d550e8400-e29b-41d4-a716-446655440000', 'd550e8400-e29b-41d4-a716-446655440003'], '2024-11-15 23:59:59+00'),

('c550e8400-e29b-41d4-a716-446655440000', 'Holiday Party Save the Date', 'Save the date! Our annual holiday party will be held on December 15th at 6:00 PM at the Grand Ballroom. More details to follow. Bring your families!', 'e550e8400-e29b-41d4-a716-446655440002', 'low', NULL, '2024-12-15 23:59:59+00');

-- ========================================================
-- DEMO AUDIT LOGS
-- ========================================================

INSERT INTO audit_logs (company_id, user_id, action, table_name, record_id, old_values, new_values, ip_address)
VALUES
('c550e8400-e29b-41d4-a716-446655440000', '550e8400-e29b-41d4-a716-446655440002', 'UPDATE', 'employees', 'e550e8400-e29b-41d4-a716-446655440004', 
 '{"salary": 90000}', '{"salary": 95000}', '192.168.1.100'),

('c550e8400-e29b-41d4-a716-446655440000', '550e8400-e29b-41d4-a716-446655440001', 'INSERT', 'announcements', '1', 
 NULL, '{"title": "Q3 All-Hands Meeting", "priority": "high"}', '192.168.1.101'),

('c550e8400-e29b-41d4-a716-446655440000', '550e8400-e29b-41d4-a716-446655440004', 'INSERT', 'leave_requests', '1', 
 NULL, '{"leave_type": "annual", "start_date": "2024-10-25", "status": "pending"}', '10.0.0.50'),

('c550e8400-e29b-41d4-a716-446655440000', '550e8400-e29b-41d4-a716-446655440002', 'UPDATE', 'leave_requests', '1', 
 '{"status": "pending"}', '{"status": "approved", "approved_by": "e550e8400-e29b-41d4-a716-446655440002"}', '192.168.1.100');

-- Update user login timestamps
UPDATE users SET last_login = NOW() - INTERVAL '1 hour' WHERE role IN ('super_admin', 'admin');
UPDATE users SET last_login = NOW() - INTERVAL '2 hours' WHERE role = 'hr_manager';
UPDATE users SET last_login = NOW() - INTERVAL '4 hours' WHERE role = 'employee' AND RANDOM() > 0.3;

-- ========================================================
-- CREATE INDEXES FOR BETTER PERFORMANCE
-- ========================================================

CREATE INDEX idx_users_email ON users(email);
CREATE INDEX idx_users_role ON users(role);
CREATE INDEX idx_users_company_id ON users(company_id);
CREATE INDEX idx_users_status ON users(status);
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
CREATE INDEX idx_employees_user_id ON employees(user_id);
CREATE INDEX idx_employees_department_id ON employees(department_id);
CREATE INDEX idx_employees_manager_id ON employees(manager_id);
CREATE INDEX idx_attendance_employee_date ON attendance(employee_id, date);
CREATE INDEX idx_leave_requests_employee_id ON leave_requests(employee_id);
CREATE INDEX idx_payroll_employee_id ON payroll(employee_id);
CREATE INDEX idx_audit_logs_user_id ON audit_logs(user_id);
CREATE INDEX idx_audit_logs_created_at ON audit_logs(created_at);

-- ========================================================
-- CREATE UPDATED_AT TRIGGER FUNCTION
-- ========================================================

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

-- ========================================================
-- ROW LEVEL SECURITY (RLS) POLICIES
-- ========================================================

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