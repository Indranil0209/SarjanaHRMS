# Multi-Phase Registration System - Architecture & Data Flow

## System Architecture Overview

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                         SARJANA HR TECH PLATFORM                            │
├─────────────────────────────────────────────────────────────────────────────┤
│                                                                              │
│  ┌──────────────────────┐  ┌──────────────────────┐  ┌──────────────────┐  │
│  │   Frontend (React)   │  │  Email Service       │  │   Supabase       │  │
│  │                      │  │  (Resend/Nodemailer) │  │   Backend        │  │
│  │  ├─ Phase 1 Form     │  │                      │  │                  │  │
│  │  ├─ Phase 3 Form     │  │  ├─ Company Confirm  │  │  ├─ PostgreSQL   │  │
│  │  └─ Admin Dashboard  │  │  ├─ Admin Notice    │  │  ├─ Auth         │  │
│  │                      │  │  ├─ Approval Email  │  │  ├─ Storage      │  │
│  │                      │  │  └─ HR Confirm      │  │  └─ RLS Policies │  │
│  │                      │  │                      │  │                  │  │
│  └──────────┬───────────┘  └────────┬────────────┘  └────────┬─────────┘  │
│             │                        │                         │             │
│             └────────────┬───────────┴─────────────┬───────────┘             │
│                          │                         │                         │
│                    HTTP/HTTPS                 HTTP/HTTPS                     │
│                          │                         │                         │
│  ┌──────────────────────────────────────────────────────────────┐           │
│  │              Supabase Managed Services                        │           │
│  │                                                                │           │
│  │  ┌────────────────────────────────────────────────────────┐  │           │
│  │  │  PostgreSQL Database                                   │  │           │
│  │  │  ├─ companies_phase (Phase 1-2 status)                │  │           │
│  │  │  ├─ company_access_codes (Phase 2-3 codes)           │  │           │
│  │  │  ├─ registration_notifications (Audit log)           │  │           │
│  │  │  └─ users (Auth profiles linked to companies)        │  │           │
│  │  └────────────────────────────────────────────────────────┘  │           │
│  │                                                                │           │
│  │  ┌────────────────────────────────────────────────────────┐  │           │
│  │  │  Row-Level Security (RLS) Policies                    │  │           │
│  │  │  ├─ Admin can see all registrations                   │  │           │
│  │  │  ├─ Company SPOC can see their own                    │  │           │
│  │  │  ├─ HR Managers can see their company data            │  │           │
│  │  │  └─ Employees can only see their records              │  │           │
│  │  └────────────────────────────────────────────────────────┘  │           │
│  │                                                                │           │
│  │  ┌────────────────────────────────────────────────────────┐  │           │
│  │  │  Storage Buckets                                       │  │           │
│  │  │  └─ company_documents/{companyId}/{docType}.pdf       │  │           │
│  │  └────────────────────────────────────────────────────────┘  │           │
│  └──────────────────────────────────────────────────────────────┘           │
│                                                                              │
└─────────────────────────────────────────────────────────────────────────────┘
```

---

## Phase-by-Phase Data Flow

### Phase 1: Company Registration & Admin Notification

```
┌─────────────────┐
│  User Visits    │
│  /signup/company│
└────────┬────────┘
         │
         ▼
┌─────────────────────────────────────┐
│  Phase1CompanyRegistration Component │
│                                       │
│  1. Display registration form        │
│  2. Accept company & SPOC details    │
│  3. Accept document uploads          │
│  4. Validate all inputs              │
└────────┬────────────────────────────┘
         │
         ▼
┌─────────────────────────────────────┐
│  Document Upload to Storage         │
│                                       │
│  1. User selects PDF files          │
│  2. Validate: PDF only, max 5MB     │
│  3. Upload to /company_documents    │
│  4. Get public URLs                 │
└────────┬────────────────────────────┘
         │
         ▼
┌─────────────────────────────────────┐
│  Insert into companies_phase Table   │
│                                       │
│  {                                   │
│    id: UUID,                         │
│    phase_status: 'phase_1_pending',  │
│    company_name: string,             │
│    company_email: string,            │
│    spoc_primary_*: {...},            │
│    doc_urls: {...},                  │
│    submitted_at: timestamp           │
│  }                                   │
└────────┬────────────────────────────┘
         │
         ▼ (parallel)
    ┌────┴────┐
    ▼         ▼
┌─────────┐ ┌──────────────────────┐
│  Email  │ │  Email to SPOC       │
│ Service │ │  "Thank You!"        │
│         │ │  Status: Pending     │
└────┬────┘ └──────────────────────┘
     │
     ▼ (parallel)
┌──────────────────────────────────────┐
│  Email to Admin                       │
│  "New Company Registration Review"    │
│  + Company details                    │
│  + Document links                     │
│  + Review link to admin panel         │
└──────────────────────────────────────┘
```

**Outcome:**
- Data in `companies_phase` table with status `phase_1_pending`
- Document URLs stored with registration
- Emails sent to company and admin
- Notification recorded in `registration_notifications`

---

### Phase 2: Admin Approval & Access Code Generation

```
┌──────────────────────┐
│  Admin Visits        │
│  /admin/approvals    │
└──────────┬───────────┘
           │
           ▼
┌──────────────────────────────────────┐
│  Phase2AdminApproval Component        │
│                                        │
│  1. Load pending registrations        │
│  2. Display with documents            │
│  3. Show review/approve buttons       │
└──────────┬───────────────────────────┘
           │
           ▼
┌──────────────────────────────────────┐
│  Admin Review & Decision              │
│                                        │
│  Option A: APPROVE                    │
│  └─→ Click "Approve"                  │
│                                        │
│  Option B: REJECT                     │
│  └─→ Click "Reject" + provide reason  │
└──────────┬───────────────────────────┘
           │
     ┌─────┴─────┐
     │           │
     ▼ APPROVE   ▼ REJECT
     │           │
     │        ┌─────────────────┐
     │        │ Update Status   │
     │        │ to phase_1_-    │
     │        │ pending (keep)  │
     │        │ + rejection_    │
     │        │   reason        │
     │        │ + rejected_at   │
     │        └────────┬────────┘
     │                 │
     ▼                 ▼
┌──────────────────────┐ ┌─────────────────────┐
│ APPROVAL PATH        │ │ REJECTION PATH      │
│                      │ │                     │
│ 1. Generate Code     │ │ 1. Send Rejection   │
│    COMP-XXXX-XXXX    │ │    Email            │
│                      │ │                     │
│ 2. Insert to         │ │ 2. Record in        │
│    company_access_   │ │    notifications    │
│    codes table       │ │                     │
│    - access_code     │ │ 3. End workflow     │
│    - code_status:    │ │    (can resubmit)   │
│      'active'        │ │                     │
│    - expires_at:     │ │                     │
│      +90 days        │ │                     │
│    - max_uses: null  │ │                     │
│                      │ │                     │
│ 3. Update company    │ │                     │
│    status to         │ │                     │
│    phase_2_approved  │ │                     │
│    + approved_by     │ │                     │
│    + approved_at     │ │                     │
│                      │ │                     │
│ 4. Send Approval     │ │                     │
│    Email with Code   │ │                     │
│    to SPOC           │ │                     │
│                      │ │                     │
│ 5. Record in         │ │                     │
│    notifications     │ │                     │
│                      │ │                     │
│ 6. Show code to      │ │                     │
│    admin (copy)      │ │                     │
└──────────────────────┘ └─────────────────────┘
           │
           ▼
    [Awaiting HR Manager]
```

**Database Changes:**
```sql
-- Before (Phase 1)
companies_phase {
  phase_status: 'phase_1_pending'
}

-- After Approval (Phase 2)
companies_phase {
  phase_status: 'phase_2_approved',
  approved_by: admin_user_id,
  approved_at: timestamp
}

company_access_codes (NEW RECORD)
{
  company_id: companies_phase.id,
  access_code: 'COMP-XXXX-XXXX',
  code_status: 'active',
  expires_at: +90 days,
  max_uses: null
}
```

---

### Phase 3: HR Manager Registration via Access Code

```
┌─────────────────────────┐
│  HR Manager Visits      │
│  /signup/hr-manager     │
└────────┬────────────────┘
         │
         ▼
┌──────────────────────────────────────┐
│  Phase3HRManagerRegistration (Step 1)│
│  Code Validation                      │
│                                        │
│  1. User enters access code           │
│     "COMP-XXXX-XXXX"                  │
│                                        │
│  2. Normalize & validate format       │
└────────┬─────────────────────────────┘
         │
         ▼
┌──────────────────────────────────────┐
│  Query company_access_codes           │
│                                        │
│  SELECT * WHERE access_code = 'CODE'  │
└────────┬─────────────────────────────┘
         │
         ▼
┌──────────────────────────────────────┐
│  Validate Code Status                 │
│                                        │
│  Check:                               │
│  ├─ code_status = 'active' ✓         │
│  ├─ expires_at > NOW() ✓             │
│  ├─ current_uses < max_uses ✓        │
│  └─ company.phase_status =            │
│     'phase_2_approved' ✓              │
└────────┬─────────────────────────────┘
         │
    ┌────┴────┐
    │         │
    ▼ VALID   ▼ INVALID
    │         │
    │      ┌──────────────┐
    │      │ Show Error   │
    │      │ Message      │
    │      │ + Code field │
    │      └──────────────┘
    │
    ▼
┌──────────────────────────────────────┐
│ Show Company Details                  │
│ "Registering for: [Company Name]"     │
│ + Advance to registration form        │
└────────┬─────────────────────────────┘
         │
         ▼
┌──────────────────────────────────────┐
│  Phase3HRManagerRegistration (Step 2)│
│  Registration Form                    │
│                                        │
│  Collect:                             │
│  ├─ Full Name                         │
│  ├─ Email                             │
│  ├─ Phone                             │
│  ├─ Designation                       │
│  ├─ Password (min 8 chars)            │
│  └─ Terms agreement                   │
└────────┬─────────────────────────────┘
         │
         ▼
┌──────────────────────────────────────┐
│  Form Validation                      │
│                                        │
│  ├─ Email valid & unique              │
│  ├─ Password requirements met         │
│  ├─ Passwords match                   │
│  └─ Terms accepted                    │
└────────┬─────────────────────────────┘
         │
         ▼
┌──────────────────────────────────────┐
│  Create Supabase Auth User            │
│                                        │
│  supabase.auth.signUp({               │
│    email,                             │
│    password,                          │
│    metadata: {                        │
│      role: 'hr_manager',              │
│      company_id                       │
│    }                                  │
│  })                                   │
└────────┬─────────────────────────────┘
         │
         ▼ (parallel)
    ┌────┴────────────┐
    │                 │
    ▼                 ▼
┌───────────┐    ┌──────────────────┐
│  Create   │    │  Update Access   │
│  User     │    │  Code            │
│  Profile  │    │                  │
│  in users │    │  code_status:    │
│  table    │    │  'used'          │
│           │    │  used_at: NOW    │
│  Columns: │    │  used_by: user_  │
│  - id     │    │  id              │
│  - email  │    │  current_uses++  │
│  - full_  │    │                  │
│    name   │    └──────────────────┘
│  - phone  │
│  - role:  │
│    'hr_   │
│    manager│    ┌──────────────────┐
│  - company│    │  Send Email      │
│    _id    │    │                  │
│  - is_    │    │  To: HR Manager  │
│    active │    │  Subject:        │
│           │    │  "Welcome to     │
│           │    │   Sarjana!"      │
│           │    │                  │
│           │    │  Content:        │
│           │    │  - Account ready │
│           │    │  - Login link    │
│           │    │  - Next steps    │
│           │    │  - Support info  │
│           │    └────────┬─────────┘
│           │             │
└────────┬──┘             ▼
         │        ┌──────────────────┐
         │        │ Record in        │
         │        │ notifications    │
         │        │ table            │
         │        └────────┬─────────┘
         │                 │
         └─────────┬───────┘
                   │
                   ▼
        ┌─────────────────────┐
        │  Success!           │
        │                     │
        │  Account created    │
        │  Redirect to login  │
        │  Show welcome msg   │
        └─────────────────────┘
```

**Database Changes:**
```sql
-- In users table (NEW RECORD)
{
  id: auth_user_id,
  email: 'hrmanager@company.com',
  full_name: 'Jane HR',
  phone_number: '+1-555-1111',
  role: 'hr_manager',
  company_id: companies_phase.id,  -- LINKED!
  is_active: true,
  email_verified: false,
  created_at: timestamp
}

-- In company_access_codes (UPDATE)
{
  code_status: 'used',  -- Changed from 'active'
  used_by: user_id,
  used_at: timestamp,
  current_uses: 1  -- Incremented
}
```

---

## Email Flow Diagram

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                          EMAIL NOTIFICATION FLOW                            │
├─────────────────────────────────────────────────────────────────────────────┤
│                                                                              │
│  PHASE 1: Company Registration                                              │
│  ┌─────────────────────────────────────────────────────────────────────┐   │
│  │ ① COMPANY CONFIRMATION EMAIL                                       │   │
│  │    To: SPOC Primary Email                                           │   │
│  │    Subject: "Welcome [Company Name] - Application Under Review"    │   │
│  │    Content:                                                         │   │
│  │    ├─ Thank you message                                             │   │
│  │    ├─ Registration details submitted                               │   │
│  │    ├─ Status: Pending Review                                       │   │
│  │    └─ Timeline: 24-48 hours                                         │   │
│  └──────────────────┬──────────────────────────────────────────────────┘   │
│                     │                                                        │
│  ┌────────────────────────────────────────────────────────────────────┐    │
│  │ ② ADMIN NOTIFICATION EMAIL                                        │    │
│  │    To: ADMIN_EMAIL                                                 │    │
│  │    Subject: "New Company Registration - [Company Name]"            │    │
│  │    Content:                                                        │    │
│  │    ├─ Company details                                              │    │
│  │    ├─ SPOC information                                             │    │
│  │    ├─ Submission date & time                                       │    │
│  │    ├─ Document upload links                                        │    │
│  │    └─ Review & Action buttons                                      │    │
│  └───────────────────┬────────────────────────────────────────────────┘    │
│                      │                                                      │
│  PHASE 2: Admin Approval                                                    │
│  ┌────────────────────────────────────────────────────────────────────┐    │
│  │ ③ COMPANY APPROVAL EMAIL                                          │    │
│  │    To: SPOC Primary Email                                          │    │
│  │    Subject: "✅ [Company Name] is Approved!"                       │    │
│  │    Content:                                                        │    │
│  │    ├─ Congratulations message                                      │    │
│  │    ├─ Status: APPROVED                                             │    │
│  │    ├─ UNIQUE ACCESS CODE (HIGHLIGHTED)                             │    │
│  │    ├─ Code validity: 90 days                                       │    │
│  │    ├─ Next steps (HR Manager signup)                               │    │
│  │    ├─ HR Manager signup link                                       │    │
│  │    └─ Support contact info                                         │    │
│  └────────────────────────────────────────────────────────────────────┘    │
│                      │                                                      │
│  ┌────────────────────────────────────────────────────────────────────┐    │
│  │ ④ COMPANY REJECTION EMAIL (if rejected)                           │    │
│  │    To: SPOC Primary Email                                          │    │
│  │    Subject: "[Company Name] - Registration Review Complete"       │    │
│  │    Content:                                                        │    │
│  │    ├─ Status: REJECTED                                             │    │
│  │    ├─ Reason for rejection                                         │    │
│  │    ├─ How to fix issues                                            │    │
│  │    ├─ Option to resubmit                                           │    │
│  │    └─ Support contact info                                         │    │
│  └────────────────────────────────────────────────────────────────────┘    │
│                      │                                                      │
│  PHASE 3: HR Manager Registration                                           │
│  ┌────────────────────────────────────────────────────────────────────┐    │
│  │ ⑤ HR MANAGER REGISTRATION CONFIRMATION EMAIL                      │    │
│  │    To: HR Manager Email                                            │    │
│  │    Subject: "Welcome [Name] - Your Account is Ready!"              │    │
│  │    Content:                                                        │    │
│  │    ├─ Welcome message                                              │    │
│  │    ├─ Account created notification                                 │    │
│  │    ├─ Company: [Company Name]                                      │    │
│  │    ├─ Login credentials info                                       │    │
│  │    ├─ Login link                                                   │    │
│  │    ├─ Dashboard features overview                                  │    │
│  │    └─ Support contact info                                         │    │
│  └────────────────────────────────────────────────────────────────────┘    │
│                                                                              │
└─────────────────────────────────────────────────────────────────────────────┘
```

---

## Database Schema Relationships

```
┌─────────────────────────────────┐
│   companies_phase (Phase 1-2)    │
├─────────────────────────────────┤
│ id (PK) ────────────┐           │
│ company_name        │ 1         │
│ company_email       │           │
│ phase_status        │           │
│ spoc_primary_*      │           │
│ doc_urls            │           │
│ approved_by (FK) ───┼────→ users │
│ rejection_reason    │           │
│ created_at          │           │
└─────────────────────┼───────────┘
                      │
                      │ 1
                      │
                      N
                      │
┌─────────────────────┴───────────┐
│ company_access_codes            │
├─────────────────────────────────┤
│ id (PK)                         │
│ company_id (FK) ────────────┐   │
│ access_code (UNIQUE)        │   │
│ code_status                 │   │
│ expires_at                  │   │
│ used_by (FK) ───────────┐   │   │
│ used_at                 │   │   │
│ current_uses            │   │   │
│ max_uses                │   │   │
└─────────────────┬───────┴───┘   │
                  │                 │
                  │ references      │
                  │                 │
┌─────────────────┴────────────────┐
│  users                           │
├──────────────────────────────────┤
│ id (PK)                          │
│ email (UNIQUE)                   │
│ full_name                        │
│ phone_number                     │
│ role                             │
│ company_id (FK) ─────────────┐   │
│ is_active                    │   │
│ created_at                   │   │
└──────────────────────────────┼───┘
                               │
                    (referenced by
                  companies_phase and
                  company_access_codes)
```

---

## RLS Policy Matrix

```
┌────────────────────────────────────────────────────────────────────┐
│                    ROW LEVEL SECURITY POLICIES                     │
├────────────────────────────────────────────────────────────────────┤
│                                                                    │
│  TABLE: companies_phase                                            │
│  ┌──────────────────────────────────────────────────────────────┐ │
│  │ SELECT (View):                                               │ │
│  │  ├─ Admin/Super Admin → All rows ✓                           │ │
│  │  ├─ Company SPOC → Own registration ✓                        │ │
│  │  └─ Others → Denied ✗                                        │ │
│  │                                                                │ │
│  │ INSERT (Create):                                              │ │
│  │  ├─ Anonymous users → Allowed ✓ (company signup)             │ │
│  │  └─ Others → Allowed (form submission)                        │ │
│  │                                                                │ │
│  │ UPDATE (Modify):                                              │ │
│  │  ├─ Admin → All statuses ✓                                   │ │
│  │  ├─ Company SPOC → phase_1_pending only ✓                    │ │
│  │  └─ Others → Denied ✗                                        │ │
│  │                                                                │ │
│  │ DELETE (Remove):                                              │ │
│  │  └─ All users → Denied ✗ (immutable)                         │ │
│  └──────────────────────────────────────────────────────────────┘ │
│                                                                    │
│  TABLE: company_access_codes                                       │
│  ┌──────────────────────────────────────────────────────────────┐ │
│  │ SELECT (View):                                               │ │
│  │  ├─ Admin → All ✓                                            │ │
│  │  ├─ Public → Read for validation ✓ (code check)              │ │
│  │  └─ HR Managers → Only their company codes ✓                 │ │
│  │                                                                │ │
│  │ INSERT (Create):                                              │ │
│  │  ├─ Admin → Allowed ✓ (auto-generated on approval)           │ │
│  │  └─ Others → Denied ✗                                        │ │
│  │                                                                │ │
│  │ UPDATE (Modify):                                              │ │
│  │  ├─ Admin → Allowed ✓                                        │ │
│  │  ├─ System → Update used status ✓ (on HR signup)             │ │
│  │  └─ Others → Denied ✗                                        │ │
│  │                                                                │ │
│  │ DELETE (Remove):                                              │ │
│  │  └─ All users → Denied ✗ (immutable)                         │ │
│  └──────────────────────────────────────────────────────────────┘ │
│                                                                    │
│  TABLE: users                                                      │
│  ┌──────────────────────────────────────────────────────────────┐ │
│  │ SELECT (View):                                               │ │
│  │  ├─ Admin → All ✓                                            │ │
│  │  ├─ Users → Own record ✓                                     │ │
│  │  ├─ HR Managers → Company users only ✓                       │ │
│  │  └─ Employees → Limited to own record ✓                      │ │
│  │                                                                │ │
│  │ UPDATE (Modify):                                              │ │
│  │  ├─ Admin → All fields ✓                                     │ │
│  │  ├─ Users → Own profile only ✓                               │ │
│  │  └─ Others → Denied ✗                                        │ │
│  └──────────────────────────────────────────────────────────────┘ │
│                                                                    │
└────────────────────────────────────────────────────────────────────┘
```

---

## Security Considerations

### 1. Access Code Security

```
Generation:
├─ 32-character alphanumeric
├─ Excludes ambiguous characters (0/O, 1/I/L)
├─ Cryptographically random
└─ Unique per company

Storage:
├─ Stored in database (hashing optional for extra security)
├─ Never transmitted in plain URLs
├─ Transmitted via email (secure channel)
└─ Time-limited (90 days)

Validation:
├─ Format validation on client & server
├─ Database lookup to verify existence
├─ Status check (active/not expired)
├─ Single-use or limited-use tracking
└─ One-time consumption (optional)
```

### 2. Document Security

```
Storage:
├─ Private Supabase bucket
├─ Unique URLs with access tokens
├─ Public URLs expire after use
└─ Accessible only to admin/company

Access Control:
├─ Admin can view all documents
├─ Company SPOC can view own documents
├─ Others cannot access
└─ Audit log tracks access
```

### 3. Authentication Security

```
User Creation:
├─ Email verification required
├─ Strong password enforcement (8+ chars)
├─ No password stored in profiles
├─ Secure token-based sessions
└─ Auto-refresh tokens

Authorization:
├─ Role-based access control (RBAC)
├─ Company-level data isolation
├─ RLS policies enforce access
└─ Admin override capability
```

---

## Scalability Considerations

### Vertical Scaling

```
Database:
├─ Indexes on frequently queried fields
├─ Partitioning by phase_status
└─ Connection pooling

Storage:
├─ CDN for document delivery
├─ Lifecycle policies for old docs
└─ Multi-region backup
```

### Horizontal Scaling

```
Email Service:
├─ Async queue for bulk sends
├─ Rate limiting to prevent abuse
├─ Retry mechanism for failures
└─ Fallback email provider

API:
├─ Load balancing across instances
├─ Session affinity for user continuity
├─ Caching for frequent queries
└─ Background jobs for heavy lifting
```

---

## Monitoring & Logging

```
Audit Trail:
├─ registration_notifications table
├─ All email sends recorded
├─ Timestamps for all changes
└─ Admin actions tracked

Alerts:
├─ Email delivery failures
├─ Unusual access code usage
├─ Large batch uploads
└─ Failed login attempts

Metrics:
├─ Registration completion rate
├─ Code validation success rate
├─ Email delivery time
├─ Average review time (admin)
└─ HR Manager activation rate
```

---

## Disaster Recovery

```
Backup Strategy:
├─ Daily database backups
├─ Document storage versioning
├─ Email delivery logs retained
└─ Audit trail immutable

Recovery Procedures:
├─ Restore from latest backup
├─ Re-send failed notifications
├─ Regenerate codes if needed
└─ Audit user actions

Testing:
├─ Monthly backup restore tests
├─ Failover scenario drills
└─ Email provider failover tests
```

---

This architecture provides:

✅ **Security:** RLS policies, encrypted storage, secure code generation  
✅ **Scalability:** Async operations, indexed queries, multi-region support  
✅ **Reliability:** Email retry logic, audit trails, backup strategy  
✅ **Maintainability:** Clear data flow, documented policies, monitoring  
✅ **User Experience:** Email notifications, instant validation, clear feedback
