# Multi-Phase Registration System - Complete Implementation Guide

## Overview

This guide covers the complete implementation of a 3-phase company and HR Manager registration workflow for Sarjana HR Tech:

- **Phase 1:** Company Registration & Admin Notification
- **Phase 2:** Admin Approval & Access Code Generation
- **Phase 3:** HR Manager Registration with Code Validation

---

## Table of Contents

1. [Database Setup](#database-setup)
2. [Email Configuration](#email-configuration)
3. [Frontend Components](#frontend-components)
4. [Integration Steps](#integration-steps)
5. [Admin Workflow](#admin-workflow)
6. [Testing Guide](#testing-guide)
7. [Troubleshooting](#troubleshooting)

---

## Database Setup

### Step 1: Run SQL Migrations

Execute the SQL migration file to create all necessary tables and set up Row Level Security:

```bash
# File: database/migrations/01_create_multi_phase_tables.sql
# Run in Supabase SQL Editor or via CLI
```

**Tables Created:**

1. **`companies_phase`** - Main registration data with phase tracking
   - Stores company info, SPOC details, and phase status
   - Tracks approvals and rejections
   - References document URLs

2. **`company_access_codes`** - Unique codes for HR Manager signup
   - Generated upon company approval
   - Tracks usage and expiration
   - Links HR Managers to companies

3. **`registration_notifications`** - Audit log of all notifications sent
   - Tracks email delivery status
   - Records notification types and recipients

### Step 2: Verify RLS Policies

The migration automatically sets up Row Level Security:

```sql
-- Verify RLS is enabled
SELECT tablename, rowsecurity 
FROM pg_tables 
WHERE tablename IN ('companies_phase', 'company_access_codes', 'registration_notifications');

-- Should show: 't' (true) for rowsecurity column
```

### Step 3: Create Storage Bucket

Create a bucket for company documents:

```bash
# In Supabase Dashboard:
# 1. Go to Storage → New Bucket
# 2. Name: "company_documents"
# 3. Set to Private
# 4. Add RLS policies as needed
```

---

## Email Configuration

### Option 1: Using Resend (Recommended for Production)

**Setup:**

1. Create account at [resend.com](https://resend.com)
2. Get API key from dashboard
3. Verify sending domain

**Environment Variables:**

```env
VITE_USE_RESEND_EMAIL=true
VITE_RESEND_API_KEY=re_xxxxxxxxxxxxxxxxxxxxxxxx
VITE_FROM_EMAIL=noreply@yourcompany.com
VITE_ADMIN_EMAIL=admin@yourcompany.com
```

**Advantages:**
- Reliable delivery
- Built-in templates and tracking
- Better for production
- Less configuration

### Option 2: Using Nodemailer with Gmail (Development)

**Setup:**

1. Enable 2-Factor Authentication on Gmail account
2. Generate App Password: https://myaccount.google.com/apppasswords
3. Store credentials in environment

**Environment Variables:**

```env
VITE_USE_RESEND_EMAIL=false
VITE_EMAIL_USER=your-email@gmail.com
VITE_EMAIL_PASSWORD=your-app-password
VITE_FROM_EMAIL=your-email@gmail.com
VITE_ADMIN_EMAIL=admin@yourcompany.com
```

**Advantages:**
- Free
- Easy setup for development
- Works immediately

### Option 3: Using Backend API (Self-Hosted)

For backend implementation using Express + Nodemailer:

```bash
# In backend/.env
SMTP_HOST=smtp.gmail.com
SMTP_PORT=587
SMTP_USER=your-email@gmail.com
SMTP_PASS=your-app-password
ADMIN_EMAIL=admin@yourcompany.com
```

---

## Frontend Components

### Component Files Created

1. **`src/components/auth/Phase1CompanyRegistration.jsx`**
   - Company signup form with document uploads
   - Sends confirmation emails
   - Validates all inputs

2. **`src/components/auth/Phase3HRManagerRegistration.jsx`**
   - Two-step process: Code validation + Registration
   - Validates access code format and status
   - Creates HR Manager account linked to company

3. **`src/components/admin/Phase2AdminApproval.jsx`**
   - Admin dashboard to review registrations
   - Approve/Reject functionality
   - Automatic access code generation

4. **`src/services/emailService.js`**
   - Centralized email handling
   - Supports Resend and Nodemailer
   - Pre-built email templates

5. **`src/utils/accessCodeGenerator.js`**
   - Secure access code generation (COMP-XXXXXXXX-XXXX format)
   - Validation and status checking functions
   - Expiration and usage limit logic

---

## Integration Steps

### Step 1: Update Routes

Add routes to `src/App.tsx`:

```jsx
import Phase1CompanyRegistration from './components/auth/Phase1CompanyRegistration';
import Phase3HRManagerRegistration from './components/auth/Phase3HRManagerRegistration';
import Phase2AdminApproval from './components/admin/Phase2AdminApproval';

// In your router:
<Route path="/signup/company" element={<Phase1CompanyRegistration />} />
<Route path="/signup/hr-manager" element={<Phase3HRManagerRegistration />} />
<Route path="/admin/approvals" element={<Phase2AdminApproval />} />
```

### Step 2: Update SignupNew Component

Modify `src/components/auth/SignupNew.jsx` to navigate to phase-specific components:

```jsx
const handleRoleSelection = (role) => {
  if (role === 'company') {
    navigate('/signup/company');
  } else if (role === 'hr_manager') {
    navigate('/signup/hr-manager');
  } else if (role === 'employee') {
    navigate('/employee-registration');
  }
};
```

### Step 3: Update Environment File

Add to `.env.example`:

```env
# Email Configuration (choose one)
VITE_USE_RESEND_EMAIL=false
VITE_RESEND_API_KEY=your_resend_api_key
VITE_EMAIL_USER=your-email@gmail.com
VITE_EMAIL_PASSWORD=your-app-password
VITE_FROM_EMAIL=noreply@yourcompany.com
VITE_ADMIN_EMAIL=admin@yourcompany.com
VITE_APP_URL=http://localhost:8000
VITE_ADMIN_PANEL_URL=http://localhost:8000/admin
```

### Step 4: Install Dependencies

If using Resend and Nodemailer (both included), ensure environment is set:

```bash
npm install
```

---

## Admin Workflow

### Phase 2: Admin Approval Process

**Step-by-Step:**

1. **Admin accesses admin panel:** `/admin/approvals`

2. **Review registration:**
   - View company details
   - Check SPOC information
   - Review uploaded documents (click to view)
   - Read submission details

3. **Make decision:**
   - **Approve:** 
     - System generates unique access code
     - Sends code to company email
     - Updates status to `phase_2_approved`
   
   - **Reject:**
     - Provide rejection reason
     - Sends rejection email to company
     - Company can resubmit later

4. **System auto-actions:**
   - Generates 32-char alphanumeric code
   - Sets 90-day expiration
   - Records in `company_access_codes` table
   - Sends formatted email with code
   - Logs notification in audit table

### Access Code Format

```
Format: COMP-XXXXXXXX-XXXX
Example: COMP-A7F9D2B1-K3J2

Characteristics:
- 32 characters total
- Uppercase alphanumeric
- Excludes ambiguous characters (0/O, 1/I/L)
- Easy to type and remember
- Unique per company
- Expires after 90 days
- Can be used multiple times
```

---

## Testing Guide

### Phase 1: Company Registration Test

1. **Navigate to:** `http://localhost:8000/signup`
2. **Select:** "Company Login"
3. **Fill form with:**
   - Company name: "Test Corp Ltd."
   - Email: `test@testcorp.com`
   - SPOC Name: "John Doe"
   - SPOC Email: `john@testcorp.com`
   - Phone: "+1-555-0000"
   - Upload sample PDFs (or skip)
   - Accept terms

4. **Verify:**
   - ✓ Data saved to `companies_phase` table
   - ✓ Confirmation email sent to SPOC
   - ✓ Admin notification sent to admin email
   - ✓ Status is `phase_1_pending`

**Test Email Content:**
- Company receives thank you email
- Admin receives review request with link to company details
- Both emails contain accurate information

### Phase 2: Admin Approval Test

1. **Access admin panel:** `http://localhost:8000/admin/approvals`
2. **Find test company** in pending list
3. **Click "Review & Approve/Reject"**
4. **Review details** then click "Approve"
5. **Verify:**
   - ✓ New access code generated
   - ✓ Code displayed in admin panel
   - ✓ Code saved to `company_access_codes`
   - ✓ Approval email sent to company
   - ✓ Company status updated to `phase_2_approved`

**Check Email:**
- Email contains access code
- Code is in COMP-XXXXXXXX-XXXX format
- Email includes HR Manager signup link
- Company name is correctly referenced

### Phase 3: HR Manager Registration Test

1. **Navigate to:** `http://localhost:8000/signup/hr-manager`
2. **Enter access code** from Phase 2
3. **System should show:**
   - ✓ Code validation success
   - ✓ Company name displayed
   - ✓ Form automatically advances to registration

4. **Fill HR Manager form:**
   - Name: "Jane HR"
   - Email: `jane@testcorp.com`
   - Phone: "+1-555-1111"
   - Designation: "HR Director"
   - Password: (min 8 chars)
   - Accept terms

5. **Verify:**
   - ✓ Auth user created in Supabase
   - ✓ User profile created in `users` table
   - ✓ `company_id` linked correctly
   - ✓ Access code marked as `used`
   - ✓ Confirmation email sent
   - ✓ Can login with credentials

---

## Troubleshooting

### Email Not Sending

**Issue:** Emails not being delivered

**Solutions:**

1. **Check environment variables:**
   ```bash
   echo $VITE_USE_RESEND_EMAIL
   echo $VITE_RESEND_API_KEY  # Should not be empty
   ```

2. **Check email service:**
   - Resend: Verify API key in dashboard
   - Gmail: Ensure app password is correct (not regular password)
   - Check spam folder

3. **Check logs:**
   ```javascript
   // Add to emailService.js for debugging
   console.log('Sending email to:', to);
   console.log('Using service:', USE_RESEND ? 'Resend' : 'Nodemailer');
   ```

4. **Test email function directly:**
   ```javascript
   // In browser console
   const { sendCompanyRegistrationConfirmation } = await import('./services/emailService');
   await sendCompanyRegistrationConfirmation({ ... });
   ```

### Access Code Not Validating

**Issue:** "Access code not found" error

**Solutions:**

1. **Verify code format:**
   - Should be COMP-XXXXXXXX-XXXX
   - No spaces or special characters
   - Uppercase only

2. **Check database:**
   ```sql
   SELECT * FROM company_access_codes 
   WHERE access_code = 'COMP-A7F9D2B1-K3J2';
   ```

3. **Check code status:**
   ```sql
   SELECT access_code, code_status, expires_at 
   FROM company_access_codes;
   ```

4. **Check company phase status:**
   ```sql
   SELECT company_name, phase_status 
   FROM companies_phase;
   -- Should show phase_2_approved for valid codes
   ```

### User Profile Not Linking to Company

**Issue:** HR Manager created but company_id is null

**Solutions:**

1. **Check code validation:**
   - Ensure code validation succeeded before submission
   - Verify `validatedCompany` object contains company ID

2. **Check SQL constraints:**
   ```sql
   ALTER TABLE users 
   ADD CONSTRAINT fk_company_id FOREIGN KEY (company_id)
   REFERENCES companies_phase(id);
   ```

3. **Debug in component:**
   ```javascript
   console.log('Validated company:', validatedCompany);
   console.log('Company ID being used:', validatedCompany.id);
   ```

### RLS Policies Blocking Operations

**Issue:** "403 Forbidden" or "row-level security" errors

**Solutions:**

1. **Check RLS is actually enabled:**
   ```sql
   ALTER TABLE companies_phase ENABLE ROW LEVEL SECURITY;
   ALTER TABLE company_access_codes ENABLE ROW LEVEL SECURITY;
   ```

2. **Verify policies:**
   ```sql
   SELECT * FROM pg_policies 
   WHERE tablename = 'companies_phase';
   ```

3. **Test with service role key:**
   - Use `SUPABASE_SERVICE_ROLE_KEY` for backend operations
   - Use `VITE_SUPABASE_ANON_KEY` for frontend

4. **Add missing policies:**
   - Re-run migration SQL
   - Check that all policies were created

---

## Database Queries Reference

### Get All Pending Company Registrations

```sql
SELECT id, company_name, spoc_primary_email, created_at, phase_status
FROM companies_phase
WHERE phase_status = 'phase_1_pending'
ORDER BY created_at DESC;
```

### Get Access Codes for a Company

```sql
SELECT access_code, code_status, current_uses, max_uses, expires_at
FROM company_access_codes
WHERE company_id = 'company-uuid-here'
ORDER BY generated_at DESC;
```

### Get All Approved Companies

```sql
SELECT company_name, spoc_primary_email, approved_at
FROM companies_phase
WHERE phase_status = 'phase_2_approved'
ORDER BY approved_at DESC;
```

### Get HR Managers for a Company

```sql
SELECT u.id, u.full_name, u.email, u.created_at
FROM users u
WHERE u.company_id = 'company-uuid-here'
AND u.role = 'hr_manager'
ORDER BY u.created_at DESC;
```

### Check Email Notification History

```sql
SELECT notification_type, recipient_email, sent_at, status
FROM registration_notifications
WHERE company_id = 'company-uuid-here'
ORDER BY sent_at DESC;
```

---

## Next Steps: Phase 4 (Employee Registration)

After completing Phase 1-3, Phase 4 will handle:

1. **Employee Registration Flow:**
   - Employees receive unique invite codes from HR Managers
   - Employees validate invite code during signup
   - Account automatically linked to company and HR Manager
   - Email confirmation sent

2. **Components Needed:**
   - `Phase4EmployeeRegistration.jsx`
   - Employee invite code generation in HR Manager dashboard
   - Updated email templates for employee invites

3. **Database Updates:**
   - New `employee_invites` table
   - Update `users` table with HR manager reference
   - New RLS policies for employee access

---

## Support & Resources

- **Supabase Docs:** https://supabase.com/docs
- **Resend Email:** https://resend.com/docs
- **React Documentation:** https://react.dev
- **Nodemailer Guide:** https://nodemailer.com

---

## Summary

The multi-phase registration system provides:

✅ Secure company onboarding with document verification
✅ Admin-driven approval workflow
✅ Automatic access code generation and delivery
✅ Secure HR Manager registration with code validation
✅ Complete audit trail of all notifications
✅ Scalable for Phase 4 employee registration

Total Implementation Time: ~4-6 hours
Testing Time: ~1-2 hours
Production Deployment: ~30 minutes
