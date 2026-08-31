# Three-Step Signup Architecture

## System Flow Diagram

```
┌─────────────────────────────────────────────────────────────────┐
│                    Landing Page (/signup)                       │
│                    SignupNew Component                          │
└─────────────────────────────────────────────────────────────────┘
                           │
                ┌──────────┼──────────┐
                ▼          ▼          ▼
        ┌─────────────┐ ┌──────────┐ ┌────────────┐
        │  Company    │ │    HR    │ │  Employee  │
        │   Login     │ │ Manager  │ │            │
        └─────────────┘ └──────────┘ └────────────┘
                │          │             │
                ▼          ▼             ▼
        ┌──────────────────────────────────────┐
        │   CompanyRegistration Component      │
        │   (Section 1-4)                      │
        │                                      │
        │   + PDF Document Upload              │
        │   + Email Notifications              │
        │   + Success "Connect w/ you soon"    │
        └──────────────────────────────────────┘
                        │
        ┌───────────────┼───────────────┐
        ▼               ▼               ▼
    ┌─────────┐   ┌─────────┐   ┌─────────────┐
    │ PDF to  │   │ Create  │   │Send Emails  │
    │ Storage │   │Database │   │(SPOC+Admin) │
    │ Bucket  │   │ Record  │   │             │
    └─────────┘   └─────────┘   └─────────────┘
        │             │               │
        └─────────────┴───────────────┘
                │
                ▼
        ┌──────────────────────┐
        │ Success Page         │
        │ "Connect with you    │
        │ soon"                │
        └──────────────────────┘
```

---

## Component Architecture

```
┌─────────────────────────────────────────────────────────────┐
│                      App.tsx                                │
│              Main Application Component                     │
└─────────────────────────────────────────────────────────────┘
                        │
                        ▼
        ┌──────────────────────────────┐
        │      SignupNew.jsx           │
        │  (Entry Point Component)     │
        │                              │
        │  - Step 0: Type Selection    │
        │  - Step 1: Company Reg.      │
        │  - Step 2: Role Selection    │
        │  - Step 3: User Form         │
        └──────────────────────────────┘
                 │         │
        ┌────────┘         └────────┐
        ▼                          ▼
┌──────────────────────┐   ┌──────────────────────┐
│CompanyRegistration   │   │ Registration Form    │
│      Component       │   │  (Embedded in Step 3)│
│                      │   │                      │
│ Section 1:           │   │ - First Name         │
│ - Company Login      │   │ - Last Name          │
│ - Company Name       │   │ - Email              │
│ - Location           │   │ - Password           │
│ - Employee Size      │   │ - Company Select     │
│                      │   │                      │
│ Section 2:           │   └──────────────────────┘
│ - Inc. Certificate   │
│ - PAN Document       │
│ - TAN Document       │
│ - GST Document       │
│                      │
│ Section 3:           │
│ - SPOC Primary       │
│ - SPOC Secondary     │
│                      │
│ Section 4:           │
│ - Declaration        │
│ - Submit Button      │
└──────────────────────┘
```

---

## Data Flow: Company Registration

```
User Input
    │
    ├─ Company Details (Text Fields)
    ├─ PDF Files (4 Documents)
    └─ SPOC Information
            │
            ▼
    ┌──────────────────────────────┐
    │  Form Validation (Client)    │
    │  - Required fields           │
    │  - Email format              │
    │  - PDF format & size         │
    └──────────────────────────────┘
            │
            ├─ Valid ──────────┐
            │                  ▼
            │         ┌─────────────────────┐
            │         │ Upload PDFs to      │
            │         │ Supabase Storage    │
            │         │ /company_documents/ │
            │         │ {registrationId}/   │
            │         └─────────────────────┘
            │                  │
            ▼                  ▼
        Invalid          ┌──────────────────┐
        Error            │ Create DB Record │
        Message          │ in                │
                         │ company_registr.. │
                         │ tions table       │
                         └──────────────────┘
                                  │
                                  ▼
                         ┌──────────────────┐
                         │ Send Emails:     │
                         │ 1. SPOC Email    │
                         │ 2. Admin Email   │
                         └──────────────────┘
                                  │
                                  ▼
                         ┌──────────────────┐
                         │ Show Success     │
                         │ Page with:       │
                         │ "Connect with    │
                         │ you soon"        │
                         └──────────────────┘
```

---

## Database Schema Relationships

```
┌──────────────────────────────────────┐
│         users (Existing)             │
│  ─────────────────────────────────   │
│  ✓ id (UUID Primary)                 │
│  ✓ email                             │
│  ✓ role (employee|hr_manager|admin)  │
│  ✓ company_id (FK to companies)      │
└──────────────────────────────────────┘
              │
              │ References
              │
              ▼
┌──────────────────────────────────────┐
│      companies (Existing)            │
│  ─────────────────────────────────   │
│  ✓ id (UUID Primary)                 │
│  ✓ company_name                      │
│  ✓ status                            │
│  ✓ settings (JSONB)                  │
└──────────────────────────────────────┘
              ▲
              │ References
              │
              │
┌──────────────────────────────────────────────┐
│  company_registrations (NEW TABLE)           │
│  ──────────────────────────────────────────  │
│  ✓ id (UUID Primary)                        │
│  ✓ company_login (UNIQUE)                   │
│  ✓ company_name                             │
│  ✓ company_location                         │
│  ✓ employee_size (nullable)                 │
│  ✓ status (pending|verified|rejected)       │
│  ✓ verified_by (FK to users) nullable       │
│  ✓ pan_number, tan_number, gst_number       │
│  ✓ pan_file, tan_file, gst_file (URLs)      │
│  ✓ incorporation_certificate_id, _file      │
│  ✓ spoc_primary_* (4 fields, mandatory)     │
│  ✓ spoc_secondary_* (4 fields, optional)    │
│  ✓ created_at, updated_at                   │
└──────────────────────────────────────────────┘
```

---

## File Upload Flow

```
User Selects PDF
      │
      ▼
┌─────────────────────┐
│ Validate on Client: │
│ - Is PDF?           │
│ - Size < 5MB?       │
└─────────────────────┘
      │
      ├─ Invalid ──────► Error Message
      │
      ▼ Valid
┌─────────────────────────────────────┐
│ Upload to Supabase Storage:         │
│ Bucket: company_documents           │
│ Path:                               │
│  company_documents/                 │
│    {registrationId}/                │
│      incorporation_certificate.pdf  │
│      company_pan.pdf                │
│      company_tan.pdf                │
│      company_gst.pdf                │
└─────────────────────────────────────┘
      │
      ▼
┌─────────────────────────────────────┐
│ Get File URL from Supabase:         │
│ https://storage.../company_documents│
│ /.../{registrationId}/...pdf       │
└─────────────────────────────────────┘
      │
      ▼
┌─────────────────────────────────────┐
│ Store URL in company_registrations  │
│ Database Table                      │
└─────────────────────────────────────┘
```

---

## Email Notification Flow

```
Company Registration Submitted
          │
          ▼
    ┌──────────────┐
    │ Create DB    │
    │ Record       │
    └──────────────┘
          │
    ┌─────┴──────────┐
    │                │
    ▼                ▼
┌──────────────────┐  ┌──────────────────┐
│  Email to SPOC   │  │ Email to Admin   │
│                  │  │                  │
│ To: spoc_email   │  │ To: ADMIN_EMAIL  │
│ Subject:         │  │ Subject:         │
│ Welcome to       │  │ New Company      │
│ Sarjana HR       │  │ Registration     │
│                  │  │                  │
│ Content:         │  │ Content:         │
│ - Thank you msg  │  │ - Company info   │
│ - "Connect with  │  │ - SPOC details   │
│   you soon"      │  │ - Verify link    │
│                  │  │                  │
│ ✓ Sent via       │  │ ✓ Sent via       │
│   Nodemailer     │  │   Nodemailer     │
└──────────────────┘  └──────────────────┘
```

---

## State Management in SignupNew

```
SignupNew Component State:

signupStep: number (0-3)
├─ 0: Signup type selection
├─ 1: Company registration
├─ 2: Role selection
└─ 3: User account form

selectedRole: string
├─ '' (empty)
├─ 'company_login'
├─ 'hr_manager'
└─ 'employee'

registrationId: string (for tracking)

formData: object
├─ email
├─ password
├─ firstName
├─ lastName
├─ companyId
├─ companyName
├─ phoneNumber
├─ role
└─ [other fields]

errors: object
├─ email: error message
├─ password: error message
├─ [other field errors]
└─ submit: form-level error

loading: boolean
├─ true: While submitting
└─ false: Ready for input
```

---

## API Functions Flow

```
CompanyRegistration Component
         │
         ▼
┌──────────────────────────────────┐
│ company-registration.js          │
│                                  │
│ Function Stack:                  │
│                                  │
│ 1. uploadFile()                  │
│    ├─ To: Storage Bucket         │
│    └─ Returns: File URL          │
│                                  │
│ 2. createCompanyRegistration()   │
│    ├─ Calls uploadFile() x 4     │
│    ├─ Insert to DB               │
│    └─ Call sendThankYouEmail()   │
│                                  │
│ 3. sendThankYouEmail()           │
│    ├─ Via: Nodemailer            │
│    └─ To: SPOC Email             │
│                                  │
│ 4. sendAdminNotificationEmail()  │
│    ├─ Via: Nodemailer            │
│    └─ To: Admin Email            │
│                                  │
│ 5. verifyCompanyRegistration()   │
│    ├─ Update status to 'verified'│
│    └─ Create company record      │
│                                  │
│ 6. rejectCompanyRegistration()   │
│    ├─ Update status to 'rejected'│
│    └─ Send rejection email       │
│                                  │
│ 7. checkCompanyLoginAvailability │
│    └─ Check if login taken       │
└──────────────────────────────────┘
```

---

## Validation Strategy

```
Validation Layers:

┌────────────────────────────────────────┐
│ Layer 1: Client-Side (React)           │
│ ────────────────────────────────────   │
│ ✓ Required fields check                │
│ ✓ Email format validation              │
│ ✓ Password strength check              │
│ ✓ PDF file type & size validation      │
│ ✓ Real-time error feedback             │
└────────────────────────────────────────┘
            │
            ▼ (If passes)
┌────────────────────────────────────────┐
│ Layer 2: API Validation (Node/Backend) │
│ ────────────────────────────────────   │
│ ✓ Verify all required fields present   │
│ ✓ Validate email uniqueness            │
│ ✓ Check company login availability     │
│ ✓ Verify file uploads completed       │
│ ✓ Database constraints check           │
└────────────────────────────────────────┘
            │
            ▼ (If passes)
┌────────────────────────────────────────┐
│ Layer 3: Database Level (PostgreSQL)   │
│ ────────────────────────────────────   │
│ ✓ NOT NULL constraints                 │
│ ✓ UNIQUE constraints (company_login)   │
│ ✓ Foreign key constraints              │
│ ✓ Type checking                        │
│ ✓ Trigger execution (updated_at)       │
└────────────────────────────────────────┘
```

---

## Error Handling Flow

```
Error Occurs
      │
      ├─ Client Validation Error
      │  └─ Display field-level error message
      │
      ├─ File Upload Error
      │  ├─ Size > 5MB? → "File too large"
      │  ├─ Not PDF? → "Only PDFs accepted"
      │  └─ Upload fail? → "Upload failed"
      │
      ├─ API Error
      │  ├─ Email exists? → "Email already registered"
      │  ├─ DB fail? → "Registration failed"
      │  └─ Email fail? → "Email not sent (non-blocking)"
      │
      └─ Network Error
         └─ Retry or show error message

All errors logged to:
├─ Browser console (development)
└─ Server logs (production)
```

---

## Security Architecture

```
┌─────────────────────────────────────────────┐
│           Security Layers                   │
├─────────────────────────────────────────────┤
│                                             │
│ 1. HTTPS/SSL                                │
│    └─ All communication encrypted           │
│                                             │
│ 2. Input Validation                         │
│    ├─ Client-side (UI feedback)             │
│    └─ Server-side (data integrity)          │
│                                             │
│ 3. File Validation                          │
│    ├─ Type check (PDF only)                 │
│    ├─ Size limit (5MB max)                  │
│    └─ Virus scan (optional)                 │
│                                             │
│ 4. Authentication                           │
│    └─ Email verification required           │
│                                             │
│ 5. Authorization                            │
│    ├─ RLS policies on database              │
│    └─ Role-based access control             │
│                                             │
│ 6. Data Protection                          │
│    ├─ Email encrypted in transit            │
│    └─ Password hashed in DB                 │
│                                             │
│ 7. Rate Limiting                            │
│    └─ Prevent spam registrations            │
│                                             │
└─────────────────────────────────────────────┘
```

---

## Deployment Architecture

```
┌──────────────────────────────────────────────┐
│         Production Environment               │
├──────────────────────────────────────────────┤
│                                              │
│  Frontend                                    │
│  ├─ SignupNew Component                      │
│  ├─ CompanyRegistration Component            │
│  └─ Built & Deployed (Vite)                  │
│                                              │
│  Backend (Node.js)                           │
│  ├─ company-registration.js                  │
│  ├─ API endpoints                            │
│  ├─ Email service (Nodemailer)               │
│  └─ Running on server                        │
│                                              │
│  Database (Supabase PostgreSQL)              │
│  ├─ company_registrations table              │
│  ├─ users table                              │
│  ├─ companies table                          │
│  └─ All data persisted                       │
│                                              │
│  Storage (Supabase)                          │
│  ├─ company_documents bucket                 │
│  ├─ PDF files stored                         │
│  └─ URLs provided to clients                 │
│                                              │
│  Email Service                               │
│  ├─ SMTP relay (Gmail/SendGrid)              │
│  ├─ Template system                          │
│  └─ Queue management                         │
│                                              │
└──────────────────────────────────────────────┘
```

---

## Summary

This architecture provides:
- ✅ Clear separation of concerns
- ✅ Modular components
- ✅ Multiple validation layers
- ✅ Secure file handling
- ✅ Robust error handling
- ✅ Professional email notifications
- ✅ Scalable database design
