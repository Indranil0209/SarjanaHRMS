# Multi-Tenant System Implementation

This document summarizes the implementation of the multi-tenant system with company isolation for the SARJANA HR-TECH application.

## Overview

The multi-tenant system ensures that each company's data is completely isolated from other companies, providing privacy and security. Users can only access data from their own company.

## Key Features Implemented

### 1. Company Registration & Isolation

#### Admin Signup Flow
- Super Admins must provide company details during signup:
  - Company Name (required, unique, case-insensitive)
  - Industry (optional)
  - Company Size (optional)
  - Address (optional)
  - Domain (optional)
  - Logo URL (optional)
- System validates company name uniqueness before creation
- Upon successful signup, a new company is created and the admin is associated with it

#### HR & Employee Signup Flow
- HR and Employees must select their company from a dropdown during signup
- Dropdown is populated with all active companies
- Users are associated with their selected company upon signup

### 2. Data Isolation Rules

#### Role-Based Access Control
- **Company A Admin**: Can only access Company A's HR, Employees, Payroll, Attendance
- **Company A HR**: Can only access Company A's Employees, Payroll, Leave requests
- **Company A Employee**: Can only access their own data within Company A
- **Company B Admin**: Can only access Company B's data

#### Database Query Enforcement
- All database queries include `company_id` filter
- Middleware enforces company isolation on all API requests
- Helper functions ensure company filtering is applied consistently

### 3. Database Schema Updates

#### Companies Table
```javascript
{
  id: UUID (Primary Key),
  company_name: String (Unique, Indexed),
  company_name_lower: String (Lowercase version for case-insensitive checks),
  domain: String (Optional company email domain),
  industry: String,
  size: String,
  address: String,
  logo: String (URL to company logo),
  status: String ('Active', 'Suspended', 'Inactive'),
  created_at: Date,
  settings: {
    currency: String ('INR', 'USD'),
    timezone: String,
    payrollFrequency: String
  }
}
```

#### Users Table
```javascript
{
  id: UUID (Primary Key),
  name: String,
  email: String,
  password: String,
  role: String ('Super Admin', 'HR', 'Employee'),
  company_id: UUID (References Company.id, Required),
  department: String,
  // ... other fields
}
```

### 4. API Middleware for Company Isolation

#### Enforce Company Isolation Middleware
- Attaches user's company ID to all requests
- Validates that users have a company association
- Prevents access to other companies' data

#### Helper Functions
- `withCompanyFilter(query, companyId)`: Adds company ID filter to database queries
- `withCompanyData(data, companyId)`: Adds company ID to insert data
- `verifyCompanyAccess(userId, companyId)`: Verifies user has access to a specific company

### 5. Frontend Changes

#### Admin Signup Form
- Added company name field with real-time availability checking
- Added optional company details fields (industry, size, address, domain, logo)

#### HR/Employee Signup Form
- Added company selection dropdown populated with active companies
- Validation to ensure company is selected

### 6. Backend API Endpoints

#### Company Management
- `/api/company/check-name`: Check if company name exists (case-insensitive)
- `/api/company/list`: Get list of active companies for signup dropdown
- `/api/company/create`: Create new company (Super Admin only)
- `/api/company/:id`: Get company by ID

### 7. Dashboard Routing Logic

- After login, users are redirected to their role-specific dashboard
- Dashboard components fetch data filtered by user's company
- All data displayed is isolated to the user's company

### 8. Security Checklist

✅ Every database query includes companyId filter
✅ Company name uniqueness enforced (case-insensitive)
✅ API middleware validates user's companyId on every request
✅ Frontend never exposes other companies' data
✅ Admin can only manage their own company
✅ HR can only manage employees in their company
✅ Employees can only see their own data within their company
✅ No cross-company data leakage in any API endpoint
✅ Dashboard routing respects company isolation
✅ Payroll, attendance, salary all filtered by company

## Testing

The system has been tested to ensure:
- Company name uniqueness is enforced
- Users cannot access other companies' data
- All database queries include company filtering
- Dashboard routing works correctly based on role and company
- Data isolation is maintained across all features

## Migration

A migration script is provided to update existing data for multi-tenant support:
- Creates a default company for existing users
- Assigns all existing users to the default company
- Updates all related tables with company IDs

## Conclusion

The multi-tenant system provides robust data isolation while maintaining a seamless user experience. Each company's data is completely isolated, ensuring privacy and security for all users.