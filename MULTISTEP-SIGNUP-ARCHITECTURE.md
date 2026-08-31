# 🎯 Sarjana HR Tech: Comprehensive Multi-Tenant Multi-Step Sign-Up Architecture

## Executive Summary

This document outlines a complete end-to-end multi-tenant, role-based sign-up workflow for Sarjana HR Tech, supporting:
- **Dual Sector Isolation**: IT vs. Non-IT sectors with separate data scopes
- **Three Registration Paths**: Company Admin, HR Manager, Employee
- **Stateful Onboarding**: Progressive disclosure of forms based on role selection
- **Security-First Design**: Company code generation, validation, and isolation

---

## Part 1: Database Schema Modifications

### Current State
- Companies table (exists, has company_code)
- Users table with role-based RBAC
- Employees table for employee records
- Multi-tenant isolation via company_id foreign keys

### Required Enhancements

#### 1. Extended Companies Table Schema
```sql
-- Add sector tracking and registration metadata
ALTER TABLE companies ADD COLUMN IF NOT EXISTS (
    sector ENUM('it', 'non-it') DEFAULT 'it',  -- Sector isolation
    company_code VARCHAR(20) UNIQUE NOT NULL,   -- Already exists
    code_status ENUM('active', 'used', 'expired') DEFAULT 'active',
    code_generated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    code_expires_at TIMESTAMP DEFAULT (DATE_ADD(CURRENT_TIMESTAMP, INTERVAL 30 DAY)),
    admin_user_id VARCHAR(36) UNIQUE,            -- Link to company admin
    registration_status ENUM('pending', 'verified', 'active', 'rejected') DEFAULT 'active',
    spoc_name VARCHAR(255),                      -- Single Point of Contact
    spoc_email VARCHAR(255),                     -- SPOC Email
    spoc_phone VARCHAR(20),                      -- SPOC Phone
    max_employees INT DEFAULT 100,               -- Soft limit for employees
    subscription_tier ENUM('starter', 'pro', 'enterprise') DEFAULT 'starter'
);

-- Add indexes for faster lookups
CREATE INDEX idx_companies_sector ON companies(sector);
CREATE INDEX idx_companies_code_status ON companies(code_status);
CREATE INDEX idx_companies_registration_status ON companies(registration_status);
```

#### 2. Users Table Enhancements
```sql
-- Track user registration source and sector affinity
ALTER TABLE users ADD COLUMN IF NOT EXISTS (
    sector ENUM('it', 'non-it'),              -- Sector this user belongs to
    registration_step VARCHAR(50),             -- Last completed step (pending, completed)
    registration_code VARCHAR(20),             -- Temp code during signup
    code_verified_at TIMESTAMP NULL,           -- When code was verified
    onboarding_completed_at TIMESTAMP NULL,    -- When onboarding completed
    must_change_password BOOLEAN DEFAULT false -- First-login password change
);

-- Add indexes for faster lookups
CREATE INDEX idx_users_sector ON users(sector);
CREATE INDEX idx_users_registration_step ON users(registration_step);
```

#### 3. Registration Codes Table (NEW)
```sql
-- Tracks company code lifecycle and validation
CREATE TABLE IF NOT EXISTS company_registration_codes (
    id VARCHAR(36) PRIMARY KEY,
    company_id VARCHAR(36) NOT NULL,
    code VARCHAR(20) UNIQUE NOT NULL,
    code_status ENUM('active', 'used', 'expired', 'revoked') DEFAULT 'active',
    generated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    expires_at TIMESTAMP DEFAULT (DATE_ADD(CURRENT_TIMESTAMP, INTERVAL 30 DAY)),
    used_at TIMESTAMP NULL,
    used_by_user_id VARCHAR(36) NULL,
    usage_count INT DEFAULT 0,
    max_uses INT DEFAULT -1,  -- -1 = unlimited
    created_by VARCHAR(36),
    notes TEXT,
    
    FOREIGN KEY (company_id) REFERENCES companies(id) ON DELETE CASCADE,
    FOREIGN KEY (used_by_user_id) REFERENCES users(id),
    FOREIGN KEY (created_by) REFERENCES users(id),
    
    INDEX idx_code (code),
    INDEX idx_company_id (company_id),
    INDEX idx_code_status (code_status),
    INDEX idx_expires_at (expires_at)
);

-- Audit trail for code usage
CREATE TABLE IF NOT EXISTS code_usage_audit (
    id VARCHAR(36) PRIMARY KEY,
    code_id VARCHAR(36) NOT NULL,
    user_id VARCHAR(36),
    action VARCHAR(50),  -- 'generated', 'verified', 'used', 'expired', 'revoked'
    ip_address VARCHAR(45),
    user_agent TEXT,
    metadata JSON,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    
    FOREIGN KEY (code_id) REFERENCES company_registration_codes(id),
    FOREIGN KEY (user_id) REFERENCES users(id),
    
    INDEX idx_code_id (code_id),
    INDEX idx_created_at (created_at)
);
```

#### 4. Signup Progress Tracking Table (NEW)
```sql
-- Tracks incomplete signup sessions for recovery
CREATE TABLE IF NOT EXISTS signup_sessions (
    id VARCHAR(36) PRIMARY KEY,
    email VARCHAR(255) UNIQUE NOT NULL,
    sector ENUM('it', 'non-it') NOT NULL,
    role VARCHAR(50) NOT NULL,  -- 'company_admin', 'hr_manager', 'employee'
    company_id VARCHAR(36),
    company_code VARCHAR(20),
    employee_id VARCHAR(20),
    
    -- Submission progress
    step_current VARCHAR(50),
    step_completed JSON,  -- Array of completed steps
    form_data JSON,       -- Encrypted form data
    
    -- Lifecycle
    started_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    last_activity_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    expires_at TIMESTAMP DEFAULT (DATE_ADD(CURRENT_TIMESTAMP, INTERVAL 7 DAY)),
    status ENUM('active', 'completed', 'abandoned', 'expired') DEFAULT 'active',
    
    -- Reference
    created_user_id VARCHAR(36),  -- Null until signup complete
    
    FOREIGN KEY (company_id) REFERENCES companies(id),
    FOREIGN KEY (created_user_id) REFERENCES users(id),
    
    INDEX idx_email (email),
    INDEX idx_status (status),
    INDEX idx_expires_at (expires_at)
);
```

#### 5. Company Quotas & Limits (NEW)
```sql
-- Track usage against company subscription tier
CREATE TABLE IF NOT EXISTS company_quotas (
    id VARCHAR(36) PRIMARY KEY,
    company_id VARCHAR(36) UNIQUE NOT NULL,
    
    -- Employee limits
    max_employees INT DEFAULT 100,
    current_employees INT DEFAULT 0,
    
    -- Feature limits
    max_hr_managers INT DEFAULT 5,
    current_hr_managers INT DEFAULT 0,
    
    max_admins INT DEFAULT 2,
    current_admins INT DEFAULT 1,  -- At least 1 (company admin)
    
    -- Soft limits (warn at 80%)
    storage_gb INT DEFAULT 10,
    api_calls_monthly INT DEFAULT 10000,
    
    last_updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    
    FOREIGN KEY (company_id) REFERENCES companies(id) ON DELETE CASCADE,
    INDEX idx_company_id (company_id)
);
```

---

## Part 2: Backend Validation Workflows

### A. Company Admin Registration Flow

#### Step 1: Sector Selection
**Endpoint**: `POST /api/signup/initialize`
```javascript
Request Body:
{
  sector: 'it' | 'non-it',
  role: 'company_admin' | 'hr_manager' | 'employee'
}

Response:
{
  success: true,
  sessionId: 'uuid',
  flow: {
    sector: 'it',
    role: 'company_admin',
    steps: ['company_details', 'admin_credentials', 'verification'],
    currentStep: 'company_details'
  }
}
```

#### Step 2: Company Details Submission
**Endpoint**: `POST /api/signup/company-details`
```javascript
Request Body:
{
  sessionId: 'uuid',
  company_name: 'Acme Corp',
  company_email: 'hr@acme.com',
  industry: 'Technology',
  employee_count: '50-100',
  domain: 'acme.com',
  phone: '+1-555-0123',
  address: '123 Main St'
}

Backend Validation:
1. Validate sessionId exists and is active
2. Check company_name is unique (case-insensitive)
3. Check company_email format
4. Validate employee_count is reasonable (1-10000)
5. Check domain is not already registered
6. Store in signup_sessions table
7. Move to step: 'admin_credentials'

Response:
{
  success: true,
  companyCode: 'ACME-X7K9M2P8Q4',
  message: 'Company details validated. Generated company code.'
}
```

#### Step 3: Admin Credentials
**Endpoint**: `POST /api/signup/admin-credentials`
```javascript
Request Body:
{
  sessionId: 'uuid',
  email: 'admin@acme.com',
  full_name: 'John Doe',
  password: 'SecurePass123!',
  phone: '+1-555-9876'
}

Backend Validation:
1. Validate sessionId step is 'admin_credentials'
2. Check email uniqueness (users table)
3. Validate password strength (8+ chars, mixed case, numbers, special)
4. Check email domain matches company domain (soft check)
5. Hash password with bcrypt
6. Store in signup_sessions

Response:
{
  success: true,
  nextStep: 'verification',
  message: 'Admin credentials stored. Verification email sent.'
}

Backend Action:
- Send verification email to admin@acme.com
- Create company record with status='pending'
- Create user record with status='pending_verification'
```

#### Step 4: Verification & Account Activation
**Endpoint**: `GET /api/signup/verify?token=verification_token`
```javascript
Backend Validation:
1. Decode verification token (JWT with 24hr TTL)
2. Check sessionId and email match
3. Verify token signature
4. Create company record (if not exists)
5. Create user record as 'admin' role
6. Generate and store company_code
7. Set registration_status='active'
8. Update company_quotas
9. Send welcome email with company code

Response (Redirect to):
{
  success: true,
  companyCode: 'ACME-X7K9M2P8Q4',
  message: 'Email verified! Company activated. Share the code with your team.'
}
```

---

### B. HR Manager Registration Flow

#### Step 1: Company Code Lookup
**Endpoint**: `POST /api/signup/validate-company-code`
```javascript
Request Body:
{
  company_code: 'ACME-X7K9M2P8Q4'
}

Backend Validation:
1. Check code exists in company_registration_codes table
2. Verify code_status is 'active'
3. Check code is not expired (expires_at > NOW())
4. Check usage_count < max_uses (if limited)
5. Retrieve associated company_id
6. Check company registration_status is 'active'
7. Validate company has available HR manager slots (quotas)
8. Log code validation attempt in code_usage_audit

Response:
{
  success: true,
  company: {
    id: 'company-uuid',
    name: 'Acme Corp',
    sector: 'it',
    industry: 'Technology',
    logo: 'url'
  },
  companyVerified: true
}

Error Responses:
{
  success: false,
  error: 'INVALID_CODE',
  message: 'Company code not found or inactive'
}

{
  success: false,
  error: 'CODE_EXPIRED',
  message: 'This company code expired on 2026-08-18'
}

{
  success: false,
  error: 'CODE_LIMIT_REACHED',
  message: 'Maximum uses of this code reached'
}

{
  success: false,
  error: 'QUOTA_EXCEEDED',
  message: 'This company has reached maximum HR managers'
}
```

#### Step 2: HR Manager Profile
**Endpoint**: `POST /api/signup/hr-profile`
```javascript
Request Body:
{
  company_code: 'ACME-X7K9M2P8Q4',
  email: 'hr@acme.com',
  full_name: 'Jane Smith',
  phone: '+1-555-1111',
  department: 'Human Resources',
  password: 'SecurePass456!'
}

Backend Validation:
1. Re-validate company code (security)
2. Check email uniqueness
3. Validate password strength
4. Check HR manager count against quota
5. Hash password with bcrypt
6. Create user record as 'hr_manager'
7. Set company_id from validated code
8. Link to company via company_id
9. Mark code usage (increment usage_count)
10. Create signup_sessions record

Response:
{
  success: true,
  user: {
    id: 'user-uuid',
    email: 'hr@acme.com',
    role: 'hr_manager',
    company: 'Acme Corp'
  },
  message: 'HR Manager account created successfully!'
}

Backend Actions:
- Create user in Supabase Auth
- Create user profile in users table
- Send welcome email
- Log in code_usage_audit as 'used'
- Update company_quotas (increment current_hr_managers)
```

---

### C. Employee Registration Flow

#### Step 1: Dual Validation (Code + Employee ID)
**Endpoint**: `POST /api/signup/validate-employee`
```javascript
Request Body:
{
  company_code: 'ACME-X7K9M2P8Q4',
  employee_id: 'EMP-0001'
}

Backend Validation:
1. Validate company_code (as above)
2. Query employees table with filters:
   - employee_id = input (exact match)
   - company_id = from validated code
   - user_id IS NULL (not yet linked)
3. Check if employee record exists and is active
4. Verify employee is not already registered
5. Log validation in code_usage_audit
6. Store in signup_sessions for recovery

Response Success:
{
  success: true,
  employee: {
    id: 'employee-record-uuid',
    employee_id: 'EMP-0001',
    name: 'John Employee',
    department: 'Engineering',
    designation: 'Software Engineer'
  },
  company: 'Acme Corp'
}

Response Error (Code):
{
  success: false,
  error: 'INVALID_CODE',
  message: 'Company code not found'
}

Response Error (Employee):
{
  success: false,
  error: 'EMPLOYEE_NOT_FOUND',
  message: 'No employee record found for ID: EMP-0001'
}

{
  success: false,
  error: 'EMPLOYEE_ALREADY_REGISTERED',
  message: 'This employee ID is already linked to an account'
}
```

#### Step 2: Employee Account Creation
**Endpoint**: `POST /api/signup/create-employee`
```javascript
Request Body:
{
  company_code: 'ACME-X7K9M2P8Q4',
  employee_id: 'EMP-0001',
  email: 'john@acme.com',
  phone: '+1-555-2222',
  password: 'EmployeePass123!'
}

Backend Validation:
1. Re-validate both code and employee_id (security)
2. Check email uniqueness
3. Validate password strength
4. Verify employee record hasn't been linked (race condition check)
5. Hash password with bcrypt
6. Create user record as 'employee' role
7. Link employee record to user:
   - UPDATE employees SET user_id = new_user_id WHERE id = employee_record_id
8. Set company_id from company_code lookup
9. Log in code_usage_audit as 'used'

Response:
{
  success: true,
  user: {
    id: 'user-uuid',
    email: 'john@acme.com',
    role: 'employee',
    company: 'Acme Corp',
    employee_id: 'EMP-0001'
  },
  message: 'Employee account created. Welcome to Acme Corp!'
}

Backend Actions:
- Create user in Supabase Auth
- Create user profile in users table
- Update employees.user_id (link)
- Send welcome email with dashboard link
- Log in code_usage_audit
- Send notification to HR manager
- Auto-set must_change_password = true (first login)
```

---

## Part 3: Frontend Multi-Step State Machine

### Architecture Overview

```
SignupFlow Component (Parent)
├── SectorSelector (Step 0)
│   ├── IT Sector Button → state.sector = 'it'
│   └── Non-IT Sector Button → state.sector = 'non-it'
│
├── RoleSelector (Step 1)
│   ├── Company Admin Button → state.role = 'company_admin'
│   ├── HR Manager Button → state.role = 'hr_manager'
│   └── Employee Button → state.role = 'employee'
│
├── COMPANY ADMIN PATH
│   ├── CompanyDetailsForm (Step 2.1)
│   │   └── API: /api/signup/company-details → companyCode
│   ├── AdminCredentialsForm (Step 2.2)
│   │   └── API: /api/signup/admin-credentials
│   └── VerificationWaiting (Step 2.3)
│       └── Email confirmation flow
│
├── HR MANAGER PATH
│   ├── CompanyCodeInput (Step 2.1)
│   │   └── API: /api/signup/validate-company-code
│   └── HRProfileForm (Step 2.2)
│       └── API: /api/signup/hr-profile
│
└── EMPLOYEE PATH
    ├── EmployeeValidation (Step 2.1)
    │   ├── Company Code Input
    │   ├── Employee ID Input
    │   └── API: /api/signup/validate-employee
    └── EmployeeAccountForm (Step 2.2)
        └── API: /api/signup/create-employee
```

### State Machine Definition

```javascript
// Global signup state shape
const signupState = {
  // Current position
  currentStep: 'sector_selection', // sector → role → role_specific
  sector: null,                      // 'it' | 'non-it'
  role: null,                        // 'company_admin' | 'hr_manager' | 'employee'
  
  // Session
  sessionId: null,
  companyCode: null,                 // Generated or entered by user
  
  // Form data (persisted during flow)
  formData: {
    // Company Admin
    company_name: '',
    company_email: '',
    industry: '',
    employee_count: '',
    domain: '',
    admin_email: '',
    admin_password: '',
    
    // HR Manager
    company_code_input: '',
    hr_email: '',
    hr_password: '',
    
    // Employee
    employee_id: '',
    employee_email: '',
    employee_password: ''
  },
  
  // Validation results
  validation: {
    companyCodeValid: null,
    employeeIdValid: null,
    emailAvailable: null,
    passwordStrength: null
  },
  
  // UI state
  loading: false,
  error: null,
  successMessage: null,
  completedSteps: []
};
```

### React Component Implementation

See Part 3 code files below for complete implementation:
- `SignupFlow.tsx` - Parent orchestrator
- `SectorSelector.tsx` - Sector branching
- `RoleSelector.tsx` - Role branching
- `CompanyDetailsForm.tsx` - Company admin form
- `AdminCredentialsForm.tsx` - Admin account form
- `CompanyCodeInput.tsx` - HR/Employee code validation
- `HRProfileForm.tsx` - HR manager form
- `EmployeeValidationForm.tsx` - Employee dual validation
- `EmployeeAccountForm.tsx` - Employee account creation
- `SignupProgressBar.tsx` - Visual progress indicator

Key Features:
- **Auto-save to signup_sessions** every 30 seconds
- **Resume capability** if user closes browser
- **Live validation** with debounced API calls
- **Password strength meter** integrated
- **Accessibility compliant** (WCAG 2.1 AA)
- **Mobile responsive** with adaptive layouts
- **Real-time error feedback** with recovery suggestions

---

## Part 4: Sector Isolation & Data Scoping

### Multi-Sector Data Model

```javascript
// Sector context determines accessible data
const sectorIsolationModel = {
  IT_SECTOR: {
    companies: [],
    users: [],
    dashboards: ['employee_dashboard', 'hr_dashboard', 'admin_dashboard'],
    features: ['attendance', 'payroll', 'recruitment', 'performance']
  },
  
  NON_IT_SECTOR: {
    companies: [],  // Separate company namespace
    users: [],      // Separate user namespace
    dashboards: ['employee_portal', 'hr_portal', 'admin_portal'],
    features: ['applicant_tracking', 'vendor_management', 'procurement']
  }
};

// Query filtering by sector
const queryWithSectorFilter = (baseQuery, sector, companyId) => {
  return baseQuery
    .eq('sector', sector)
    .eq('company_id', companyId);
};
```

### Security Boundaries

1. **Authentication Boundary**: User can only login to their sector
2. **Data Boundary**: Sector column on companies/users tables
3. **API Boundary**: All APIs check sector match before returning data
4. **UI Boundary**: Routes check sector before allowing access

---

## Part 5: Security Considerations

### Password Security
- Minimum 8 characters
- Mix of uppercase, lowercase, numbers, special chars
- Checked against common password list
- Salted + bcrypt hash (12 rounds)
- Never transmitted in plaintext
- HTTPS enforced

### Company Code Security
- Auto-generated: prefix (4 chars) + random (10 chars)
- UNIQUE constraint in database
- Expiration tracking (30 days by default)
- Usage audit trail (code_usage_audit table)
- Rate limiting on validation attempts
- Soft code deactivation after suspicious activity

### Email Verification
- Verification link sent to company admin email
- Link expires after 24 hours
- Token includes email + timestamp
- JWT signature verification
- One-time use (mark as used in database)
- Resend capability with cooldown

### Employee ID Validation
- Exact match required (case-sensitive)
- Company-scoped lookup (company_id filter)
- Race condition protection (check user_id IS NULL at insertion)
- Audit trail in code_usage_audit
- Prevents duplicate registrations

---

## Part 6: Error Handling & Recovery

### Partial Signup Recovery
- Auto-save signup_sessions every 30 seconds
- 7-day session expiration
- Resume link sent via email
- Form state restored from database

### Common Error Scenarios

#### Company Code Errors
```
1. INVALID_CODE → Suggest check spelling, contact admin
2. CODE_EXPIRED → Offer admin re-generation or contact HR
3. CODE_LIMIT_REACHED → Inform new code needed from admin
4. QUOTA_EXCEEDED → Explain company limit, contact admin
```

#### Employee ID Errors
```
1. EMPLOYEE_NOT_FOUND → Suggest contact HR, verify spelling
2. ALREADY_REGISTERED → Suggest password reset or contact support
3. COMPANY_MISMATCH → Inform code doesn't match employee's company
```

#### Email Errors
```
1. EMAIL_EXISTS → Suggest sign in or password reset
2. INVALID_EMAIL → Show email format requirements
3. DOMAIN_MISMATCH → Warn company email domain differs
```

### Fallback Mechanisms
- Session auto-save every 30 seconds
- Offline-capable with service workers
- Retry logic with exponential backoff
- Circuit breaker on API failures
- Fallback static pages for critical errors

---

## Part 7: Monitoring & Analytics

### Key Metrics
- Signup completion rate by sector/role
- Drop-off rate at each step
- Company code validation success rate
- Email verification success rate
- Time to completion (by role)
- Error rate by type
- Device/browser breakdown

### Audit Logging
All signup events logged to `code_usage_audit`:
- Code generation
- Code validation attempts
- Code usage
- Registration attempts
- Email verification
- Account creation

---

## Implementation Roadmap

### Phase 1: Database & Backend (Week 1)
- [ ] Create/migrate database tables
- [ ] Implement company code validation endpoints
- [ ] Implement user creation endpoints
- [ ] Set up email service for verification

### Phase 2: Frontend State Machine (Week 2)
- [ ] Implement signup state machine
- [ ] Build sector/role selectors
- [ ] Build company form workflow
- [ ] Build HR form workflow

### Phase 3: Employee Workflow (Week 3)
- [ ] Build employee validation forms
- [ ] Implement employee account creation
- [ ] Add session auto-save
- [ ] Add resume capability

### Phase 4: Security & Polish (Week 4)
- [ ] Add password strength requirements
- [ ] Implement rate limiting
- [ ] Add email verification flow
- [ ] Add comprehensive error handling
- [ ] Performance optimization
- [ ] Accessibility audit

### Phase 5: Testing & Deployment (Week 5)
- [ ] Unit tests for validation logic
- [ ] Integration tests for workflows
- [ ] E2E tests for complete signup
- [ ] Security testing
- [ ] Load testing
- [ ] Deploy to production

---

## References & Dependencies

### Backend Libraries
- Supabase JS client
- bcryptjs for password hashing
- JSON Web Tokens (JWT) for email verification
- Node mailer for emails
- Express for routing
- Rate limiting middleware

### Frontend Libraries
- React 18+
- React Router v6+
- Zustand for state management
- React Hook Form for form handling
- Zod for schema validation
- Tailwind CSS for styling
- Axios for HTTP

### Infrastructure
- Supabase PostgreSQL database
- SendGrid for email
- CloudFlare for DDoS protection
- Datadog for monitoring
- Sentry for error tracking

---

## Conclusion

This comprehensive multi-tenant sign-up system provides:
1. ✅ Complete sector isolation (IT vs Non-IT)
2. ✅ Three distinct registration workflows
3. ✅ Security-first company code generation and validation
4. ✅ Stateful frontend with recovery capability
5. ✅ Comprehensive backend validation
6. ✅ Audit trail and monitoring
7. ✅ Enterprise-grade error handling

