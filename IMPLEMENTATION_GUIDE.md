# Three-Step Signup Flow Implementation Guide

## Overview
This implementation adds a new three-step signup flow with:
1. **Signup Type Selection** - Choose between Company Login, HR Manager, or Employee
2. **Company Registration (if Company Login selected)** - Complete company details and document uploads
3. **Role Selection (if HR/Employee selected)** - Choose specific role
4. **Registration Form** - Complete user account setup

## New Components Created

### 1. CompanyRegistration Component
**File:** `src/components/auth/CompanyRegistration.jsx`

This is a comprehensive company registration form with:
- **Section 1: Primary Account Details**
  - Company Login (Mandatory)
  - Company Name (Mandatory)
  - Location/Details (Mandatory)
  - Employee Size (Optional)

- **Section 2: Legal & Compliance Documents**
  - Incorporation Certificate (PDF + ID Number)
  - Company PAN (Text + PDF)
  - Company TAN (Text + PDF)
  - Company GST (Text + PDF)

- **Section 3: SPOC Details**
  - Primary SPOC (All fields mandatory)
    - Name, Phone, Email, Address
  - Secondary SPOC (All fields optional)
    - Name, Phone, Email, Address

- **Section 4: Declaration**
  - Mandatory checkbox for terms acceptance
  - Submit button

### Features:
- PDF file upload validation (max 5MB, PDF only)
- Field-level validation
- Success page showing "Connect with you soon"
- Automatic thank you email to SPOC
- Admin notification email

### 2. SignupNew Component
**File:** `src/components/auth/SignupNew.jsx`

Three-step signup flow:
- Step 0: Signup type selection (Company Login, HR Manager, Employee)
- Step 1: Company Registration form (if Company Login selected)
- Step 2: Role selection (if HR/Employee selected)
- Step 3: User account registration form

## Database Changes

### New Table: company_registrations
**File:** `database/migrations/create_company_registrations.sql`

```sql
CREATE TABLE company_registrations (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    
    -- Primary Account Details
    company_login VARCHAR(255) UNIQUE NOT NULL,
    company_name VARCHAR(255) NOT NULL,
    company_location TEXT NOT NULL,
    employee_size INTEGER,
    
    -- Legal Documents
    incorporation_certificate_id VARCHAR(100),
    incorporation_certificate_file TEXT,
    pan_number VARCHAR(20),
    pan_file TEXT,
    tan_number VARCHAR(20),
    tan_file TEXT,
    gst_number VARCHAR(20),
    gst_file TEXT,
    
    -- SPOC Primary (Mandatory)
    spoc_primary_name VARCHAR(100) NOT NULL,
    spoc_primary_phone VARCHAR(20) NOT NULL,
    spoc_primary_email VARCHAR(255) NOT NULL,
    spoc_primary_address TEXT NOT NULL,
    
    -- SPOC Secondary (Optional)
    spoc_secondary_name VARCHAR(100),
    spoc_secondary_phone VARCHAR(20),
    spoc_secondary_email VARCHAR(255),
    spoc_secondary_address TEXT,
    
    -- Status
    status VARCHAR(50) DEFAULT 'pending_verification',
    rejection_reason TEXT,
    verified_at TIMESTAMP WITH TIME ZONE,
    verified_by UUID REFERENCES users(id),
    
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);
```

### Required Supabase Storage Bucket
Create a new storage bucket named `company_documents` for PDF uploads.

## API Endpoints

### New File: src/api/company-registration.js

#### 1. sendThankYouEmail(spocEmail, companyName, spocName)
Sends a thank you email to the SPOC with status message "Connect with you soon."

#### 2. sendAdminNotificationEmail(companyData)
Sends notification to admin email with company details.

#### 3. createCompanyRegistration(registrationData)
Inserts registration into database and triggers emails.

#### 4. getPendingRegistrations()
Gets all pending company registrations (for admin verification).

#### 5. verifyCompanyRegistration(registrationId, userId, status)
Marks registration as verified and creates company record.

#### 6. rejectCompanyRegistration(registrationId, rejectionReason)
Rejects registration and sends rejection email to SPOC.

#### 7. checkCompanyLoginAvailability(companyLogin)
Checks if company login is already taken.

## Installation Steps

### 1. Create Database Table
```bash
# Connect to Supabase and run the migration
psql "your-supabase-connection-string" < database/migrations/create_company_registrations.sql
```

### 2. Create Storage Bucket
```bash
# In Supabase Dashboard:
# Storage → New Bucket → Name: "company_documents" → Make Public
```

### 3. Create Email Environment Variables
Add to `.env`:
```
EMAIL_USER=your-email@gmail.com
EMAIL_PASSWORD=your-app-password
ADMIN_EMAIL=admin@yourcompany.com
ADMIN_PANEL_URL=https://yourdomain.com/admin
```

### 4. Update App Routes
Replace the existing signup route in `src/App.tsx` or `src/App.jsx` to use the new component:

```typescript
import SignupNew from './components/auth/SignupNew';

// In routes:
<Route path="/signup" element={<SignupNew />} />
```

### 5. Install Dependencies (if needed)
```bash
npm install nodemailer
```

## Usage Flow

### For Company Administrators:
1. Click "Sign Up" → "Company Login"
2. Fill in company details
3. Upload legal documents (PDFs)
4. Enter SPOC details
5. Accept declaration and submit
6. See success message "Connect with you soon"
7. Receive thank you email
8. Admin reviews and verifies registration
9. Once verified, can log in and set up company

### For HR Managers:
1. Click "Sign Up" → "HR Manager"
2. Select company
3. Enter credentials and submit
4. Account created

### For Employees:
1. Click "Sign Up" → "Employee"
2. Select company
3. Enter credentials and submit
4. Account created

## Email Templates

### Thank You Email
- Subject: "Welcome to Sarjana HR - {CompanyName}"
- Message: Includes "Connect with you soon"
- Sent to: SPOC Primary Email

### Admin Notification Email
- Subject: "New Company Registration: {CompanyName}"
- Includes: Company details, SPOC info, verification link
- Sent to: ADMIN_EMAIL

### Rejection Email
- Subject: "Company Registration Status - {CompanyName}"
- Includes: Rejection reason
- Sent to: SPOC Primary Email

## File Upload Details

### Supported Files:
- Type: PDF only
- Max Size: 5MB per file
- Stored in: Supabase Storage → `company_documents/{registrationId}/`

### File Naming Convention:
```
company_documents/{registrationId}/
├── incorporation_certificate.pdf
├── company_pan.pdf
├── company_tan.pdf
└── company_gst.pdf
```

## Validation Rules

### Company Login:
- Must be unique
- Only alphanumeric and underscores
- 3-50 characters

### Company Name:
- Required
- 2-255 characters

### SPOC Email:
- Valid email format
- Required for primary SPOC

### Phone Numbers:
- Required
- Stored as-is (10-20 digits)

### Documents:
- All PDFs required for company registration
- ID numbers (PAN, TAN, GST, etc.) required
- File validation on client and server side

## Success Criteria

✅ Three signup types available on first page
✅ Company registration with PDF uploads working
✅ Success message "Connect with you soon" shows
✅ Thank you emails sent to SPOC
✅ Admin notifications sent
✅ Company data stored in database
✅ Documents accessible via storage links
✅ Company verification workflow in place
✅ HR Manager and Employee signup working
✅ All form validations working

## Next Steps

1. **Admin Panel**: Create admin page to verify pending registrations
2. **Document Preview**: Add PDF preview functionality
3. **Email Queue**: Implement email queue for reliability
4. **SMS Notifications**: Add SMS notifications for SPOC
5. **Payment Integration**: Add payment collection after verification
6. **Bulk Import**: Add bulk employee import after company verification
