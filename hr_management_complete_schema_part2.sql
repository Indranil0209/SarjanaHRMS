-- HR Management System - Complete Database Schema (Part 2)
-- This file contains companies, users, departments, and job positions demo data

-- ========================================================
-- DEMO COMPANIES
-- ========================================================

-- Insert a default company for demo purposes
INSERT INTO companies (id, company_name, company_name_lower, industry, size, address, status, settings) VALUES
('c550e8400-e29b-41d4-a716-446655440000', 'Default Company', 'default company', 'Technology', '51-200', '123 Business Street, Tech City, TC 12345', 'active', '{"currency": "INR", "timezone": "Asia/Kolkata", "payrollFrequency": "Monthly"}');

-- ========================================================
-- DEMO USERS (Authentication users with bcrypt hashed passwords)
-- ========================================================

-- Note: All passwords are hashed using bcrypt with the value "password123"
-- Hash generated with: bcrypt.hashSync('password123', 10)
INSERT INTO users (id, email, password_hash, role, first_name, last_name, company_id, is_active, email_verified, created_at) VALUES
-- Super Admin
('550e8400-e29b-41d4-a716-446655440000', 'admin@company.com', '$2a$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi', 'super_admin', 'Super', 'Admin', 'c550e8400-e29b-41d4-a716-446655440000', true, true, '2024-01-15 08:00:00+00'),

-- Admin
('550e8400-e29b-41d4-a716-446655440001', 'john.admin@company.com', '$2a$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi', 'admin', 'John', 'Admin', 'c550e8400-e29b-41d4-a716-446655440000', true, true, '2024-01-15 08:00:00+00'),

-- HR Managers
('550e8400-e29b-41d4-a716-446655440002', 'sarah.hr@company.com', '$2a$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi', 'hr_manager', 'Sarah', 'Johnson', 'c550e8400-e29b-41d4-a716-446655440000', true, true, '2024-01-15 08:00:00+00'),
('550e8400-e29b-41d4-a716-446655440003', 'emma.hr@company.com', '$2a$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi', 'hr_manager', 'Emma', 'Wilson', 'c550e8400-e29b-41d4-a716-446655440000', true, true, '2024-01-20 08:00:00+00'),

-- Employees
('550e8400-e29b-41d4-a716-446655440004', 'mike.johnson@company.com', '$2a$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi', 'employee', 'Mike', 'Johnson', 'c550e8400-e29b-41d4-a716-446655440000', true, true, '2024-02-01 08:00:00+00'),
('550e8400-e29b-41d4-a716-446655440005', 'jane.smith@company.com', '$2a$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi', 'employee', 'Jane', 'Smith', 'c550e8400-e29b-41d4-a716-446655440000', true, true, '2024-02-01 08:00:00+00'),
('550e8400-e29b-41d4-a716-446655440006', 'alex.chen@company.com', '$2a$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi', 'employee', 'Alex', 'Chen', 'c550e8400-e29b-41d4-a716-446655440000', true, true, '2024-02-15 08:00:00+00'),
('550e8400-e29b-41d4-a716-446655440007', 'lisa.wang@company.com', '$2a$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi', 'employee', 'Lisa', 'Wang', 'c550e8400-e29b-41d4-a716-446655440000', true, true, '2024-02-15 08:00:00+00'),
('550e8400-e29b-41d4-a716-446655440008', 'david.brown@company.com', '$2a$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi', 'employee', 'David', 'Brown', 'c550e8400-e29b-41d4-a716-446655440000', true, true, '2024-03-01 08:00:00+00'),
('550e8400-e29b-41d4-a716-446655440009', 'emily.davis@company.com', '$2a$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi', 'employee', 'Emily', 'Davis', 'c550e8400-e29b-41d4-a716-446655440000', true, true, '2024-03-01 08:00:00+00'),
('550e8400-e29b-41d4-a716-446655440010', 'robert.wilson@company.com', '$2a$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi', 'employee', 'Robert', 'Wilson', 'c550e8400-e29b-41d4-a716-446655440000', true, true, '2024-03-15 08:00:00+00'),
('550e8400-e29b-41d4-a716-446655440011', 'maria.garcia@company.com', '$2a$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi', 'employee', 'Maria', 'Garcia', 'c550e8400-e29b-41d4-a716-446655440000', true, true, '2024-03-15 08:00:00+00'),
('550e8400-e29b-41d4-a716-446655440012', 'james.lee@company.com', '$2a$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi', 'employee', 'James', 'Lee', 'c550e8400-e29b-41d4-a716-446655440000', true, true, '2024-04-01 08:00:00+00'),
('550e8400-e29b-41d4-a716-446655440013', 'anna.taylor@company.com', '$2a$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi', 'employee', 'Anna', 'Taylor', 'c550e8400-e29b-41d4-a716-446655440000', true, true, '2024-04-01 08:00:00+00'),
('550e8400-e29b-41d4-a716-446655440014', 'kevin.martinez@company.com', '$2a$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi', 'employee', 'Kevin', 'Martinez', 'c550e8400-e29b-41d4-a716-446655440000', true, true, '2024-04-15 08:00:00+00'),
('550e8400-e29b-41d4-a716-446655440015', 'rachel.white@company.com', '$2a$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi', 'employee', 'Rachel', 'White', 'c550e8400-e29b-41d4-a716-446655440000', true, true, '2024-04-15 08:00:00+00');

-- ========================================================
-- DEMO DEPARTMENTS
-- ========================================================

INSERT INTO departments (id, company_id, name, description, budget, created_at) VALUES
('d550e8400-e29b-41d4-a716-446655440000', 'c550e8400-e29b-41d4-a716-446655440000', 'Engineering', 'Software development and technical operations', 2500000.00, '2024-01-10 08:00:00+00'),
('d550e8400-e29b-41d4-a716-446655440001', 'c550e8400-e29b-41d4-a716-446655440000', 'Human Resources', 'People management and organizational development', 800000.00, '2024-01-10 08:00:00+00'),
('d550e8400-e29b-41d4-a716-446655440002', 'c550e8400-e29b-41d4-a716-446655440000', 'Sales', 'Customer acquisition and revenue generation', 1800000.00, '2024-01-10 08:00:00+00'),
('d550e8400-e29b-41d4-a716-446655440003', 'c550e8400-e29b-41d4-a716-446655440000', 'Marketing', 'Brand promotion and customer engagement', 1200000.00, '2024-01-10 08:00:00+00'),
('d550e8400-e29b-41d4-a716-446655440004', 'c550e8400-e29b-41d4-a716-446655440000', 'Finance', 'Financial planning and accounting', 900000.00, '2024-01-10 08:00:00+00'),
('d550e8400-e29b-41d4-a716-446655440005', 'c550e8400-e29b-41d4-a716-446655440000', 'Operations', 'Business operations and support', 700000.00, '2024-01-10 08:00:00+00');