-- HR Management System - Complete Database Schema (Part 1)
-- This file contains the database schema definitions, custom types, table structures, indexes, triggers and Row Level Security policies

-- ========================================================
-- DATABASE SETUP AND EXTENSIONS
-- ========================================================

-- Enable necessary extensions
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";
CREATE EXTENSION IF NOT EXISTS "pgcrypto";

-- ========================================================
-- CUSTOM TYPES
-- ========================================================

-- User roles in the system
CREATE TYPE user_role AS ENUM ('super_admin', 'admin', 'hr_manager', 'employee');

-- Employment status for employees
CREATE TYPE employment_status AS ENUM ('active', 'inactive', 'terminated', 'on_leave');

-- Leave request status
CREATE TYPE leave_status AS ENUM ('pending', 'approved', 'rejected', 'cancelled');

-- Types of leave
CREATE TYPE leave_type AS ENUM ('annual', 'sick', 'maternity', 'paternity', 'emergency', 'unpaid');

-- Attendance status
CREATE TYPE attendance_status AS ENUM ('present', 'absent', 'late', 'half_day', 'work_from_home');

-- Payroll status
CREATE TYPE payroll_status AS ENUM ('draft', 'processed', 'paid');

-- Company status
CREATE TYPE company_status AS ENUM ('active', 'suspended', 'inactive');

-- ========================================================
-- CORE TABLES
-- ========================================================

-- Companies table (multi-tenant support)
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
    password_hash TEXT, -- Will store bcrypt hashed passwords
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