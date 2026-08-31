# Multi-Phase Registration System - Quick Start Guide

## 🚀 30-Minute Setup

### Step 1: Database (5 min)

```sql
-- Copy from: database/migrations/01_create_multi_phase_tables.sql
-- Paste into Supabase SQL Editor
-- Run the entire migration script
-- Verify: Check Schema → tables exist with RLS enabled
```

### Step 2: Environment Setup (5 min)

```bash
# Copy .env.multi-phase.example to .env
cp .env.multi-phase.example .env

# Edit .env with your values:
# - Supabase URL & Anon Key
# - Email service credentials (Resend OR Gmail)
# - Admin email address
```

**For Resend (Production):**
```env
VITE_USE_RESEND_EMAIL=true
VITE_RESEND_API_KEY=re_xxxxx
VITE_FROM_EMAIL=noreply@company.com
VITE_ADMIN_EMAIL=admin@company.com
```

**For Gmail (Development):**
```env
VITE_USE_RESEND_EMAIL=false
VITE_EMAIL_USER=your-email@gmail.com
VITE_EMAIL_PASSWORD=your-app-password
VITE_ADMIN_EMAIL=admin@company.com
```

### Step 3: Storage Bucket (2 min)

```
Supabase Dashboard → Storage → New Bucket
- Name: company_documents
- Privacy: Private
- Click "Create"
```

### Step 4: Routes Setup (5 min)

**File:** `src/App.tsx`

```jsx
// Add imports at top
import Phase1CompanyRegistration from './components/auth/Phase1CompanyRegistration';
import Phase3HRManagerRegistration from './components/auth/Phase3HRManagerRegistration';
import Phase2AdminApproval from './components/admin/Phase2AdminApproval';

// Add routes in your router
<Route path="/signup/company" element={<Phase1CompanyRegistration />} />
<Route path="/signup/hr-manager" element={<Phase3HRManagerRegistration />} />
<Route path="/admin/approvals" element={<Phase2AdminApproval />} />
```

### Step 5: SignupNew Update (5 min)

**File:** `src/components/auth/SignupNew.jsx`

Find the role selection handler and update it:

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

### Step 6: Start Dev Server (1 min)

```bash
npm run dev
# App runs on http://localhost:8000
```

---

## 🧪 Test the System (15 minutes)

### Test Phase 1: Company Registration

```
1. Open: http://localhost:8000/signup
2. Click: "Company Login"
3. Fill the form:
   - Company: "Test Corp"
   - Email: test@testcorp.com
   - SPOC: Your Name
   - Phone: +1-555-0000
4. Accept terms
5. Click: "Submit Registration"

Verify:
✓ Form submits without error
✓ Confirmation email received
✓ Check your email inbox
✓ Check database: SELECT * FROM companies_phase;
```

### Test Phase 2: Admin Approval

```
1. Open: http://localhost:8000/admin/approvals
2. Find your test company
3. Click: "Review & Approve/Reject"
4. Review the details
5. Click: "Approve"

Verify:
✓ Access code displayed
✓ Copy the code (e.g., COMP-XXXX-XXXX)
✓ Check email for approval with code
✓ Check database for code: SELECT * FROM company_access_codes;
```

### Test Phase 3: HR Manager Signup

```
1. Open: http://localhost:8000/signup/hr-manager
2. Enter the access code from Phase 2
3. Click: "Validate Code"

Verify:
✓ Code validation succeeds
✓ Company name displayed
✓ Form advances to registration

4. Fill registration form:
   - Name: Jane HR
   - Email: jane@testcorp.com
   - Phone: +1-555-1111
   - Password: TestPass123
5. Accept terms
6. Click: "Create Account"

Verify:
✓ Account created successfully
✓ Confirmation email received
✓ Can login with credentials
✓ Check database: SELECT * FROM users WHERE role='hr_manager';
```

---

## 📊 File Structure

```
All files already created ✓

src/
├── components/
│   ├── auth/
│   │   ├── Phase1CompanyRegistration.jsx ✓
│   │   └── Phase3HRManagerRegistration.jsx ✓
│   └── admin/
│       └── Phase2AdminApproval.jsx ✓
├── services/
│   └── emailService.js ✓
└── utils/
    └── accessCodeGenerator.js ✓

database/
└── migrations/
    └── 01_create_multi_phase_tables.sql ✓

Documentation:
├── MULTI_PHASE_REGISTRATION_GUIDE.md ✓
├── MULTI_PHASE_IMPLEMENTATION_CHECKLIST.md ✓
├── MULTI_PHASE_ARCHITECTURE.md ✓
└── MULTI_PHASE_QUICK_START.md ✓ (this file)

Config:
└── .env.multi-phase.example ✓
```

---

## 🔑 Key Components Explained

### Phase 1 Component: Company Registration
- **File:** `src/components/auth/Phase1CompanyRegistration.jsx`
- **Purpose:** Collects company details and documents
- **Output:** Saves to `companies_phase` table with status `phase_1_pending`
- **Sends:** 2 emails (company confirmation + admin notification)

### Phase 2 Component: Admin Approval
- **File:** `src/components/admin/Phase2AdminApproval.jsx`
- **Purpose:** Admin reviews and approves/rejects companies
- **Output:** Generates access code, updates status to `phase_2_approved`
- **Sends:** Approval email with code (or rejection email)

### Phase 3 Component: HR Manager Registration
- **File:** `src/components/auth/Phase3HRManagerRegistration.jsx`
- **Purpose:** HR Manager validates code and creates account
- **Output:** Creates user in `users` table, marks code as `used`
- **Sends:** Welcome email to HR Manager

### Email Service
- **File:** `src/services/emailService.js`
- **Purpose:** Handles all email sending (Resend or Nodemailer)
- **Functions:** 5 email templates for all phases
- **Fallback:** Switches between email providers automatically

### Code Generator
- **File:** `src/utils/accessCodeGenerator.js`
- **Purpose:** Generates and validates access codes
- **Format:** `COMP-XXXXXXXX-XXXX` (32 chars, alphanumeric)
- **Functions:** 6 utility functions for code management

---

## 📧 Email Service Setup

### Option A: Resend (Recommended)

```bash
# 1. Sign up: https://resend.com
# 2. Get API key from dashboard
# 3. Verify domain (or use default)
# 4. Set environment variables:

VITE_USE_RESEND_EMAIL=true
VITE_RESEND_API_KEY=re_xxxxx
```

**Pros:** Simple, reliable, great for production, good deliverability

### Option B: Gmail SMTP

```bash
# 1. Enable 2FA on Gmail account
# 2. Generate app password:
#    https://myaccount.google.com/apppasswords
# 3. Copy the 16-character password
# 4. Set environment variables:

VITE_USE_RESEND_EMAIL=false
VITE_EMAIL_USER=your-email@gmail.com
VITE_EMAIL_PASSWORD=xxxxx-xxxxx-xxxxx-xxxxx
```

**Pros:** Free, immediate setup, works for development

---

## 🔍 Common Issues & Quick Fixes

### "Port 8000 already in use"
```bash
# Use different port
npm run dev -- --port 3000
# Then access at http://localhost:3000
```

### "Email not sending"
```
1. Check .env has email credentials
2. Check admin email is valid
3. If Gmail: verify app password (not regular password)
4. If Resend: verify API key in dashboard
5. Check browser console for errors (F12)
```

### "Access code validation fails"
```
1. Verify code format: COMP-XXXXXXXX-XXXX
2. Check database: SELECT * FROM company_access_codes;
3. Verify company status: SELECT phase_status FROM companies_phase;
4. Should be: phase_2_approved
```

### "Can't login with new HR Manager account"
```
1. Verify email was confirmed
2. Check Supabase Auth has user
3. Verify company_id was set correctly
4. Try resetting password
```

---

## 📊 Database Quick Queries

### Check pending companies
```sql
SELECT company_name, spoc_primary_email, created_at 
FROM companies_phase 
WHERE phase_status = 'phase_1_pending'
ORDER BY created_at DESC;
```

### Check generated codes
```sql
SELECT c.company_name, a.access_code, a.code_status, a.expires_at
FROM company_access_codes a
JOIN companies_phase c ON a.company_id = c.id
ORDER BY a.generated_at DESC;
```

### Check HR Managers
```sql
SELECT full_name, email, company_id, created_at
FROM users
WHERE role = 'hr_manager'
ORDER BY created_at DESC;
```

### Check all approvals
```sql
SELECT company_name, phase_status, approved_by, approved_at
FROM companies_phase
WHERE phase_status = 'phase_2_approved'
ORDER BY approved_at DESC;
```

---

## ✅ Production Checklist

Before deploying to production:

- [ ] Email service configured (Resend recommended)
- [ ] All 3 components tested thoroughly
- [ ] Database backup strategy in place
- [ ] RLS policies verified
- [ ] Storage bucket is private
- [ ] Error logging configured
- [ ] Performance tested (load test registration)
- [ ] Security review completed
- [ ] Admin email is monitored
- [ ] Backup admin email configured
- [ ] Rate limiting considered
- [ ] Email templates reviewed by marketing

---

## 🎯 What You Can Do Now

### With Completed Phase 1-3:

✅ Companies can register online  
✅ Admin approves companies  
✅ Unique access codes generated automatically  
✅ HR Managers can signup using codes  
✅ All users linked to correct company  
✅ Full audit trail of all notifications  
✅ Secure document upload & storage  

### Ready for Phase 4:

📋 Employee registration via invite codes  
📋 HR Manager can invite employees  
📋 Employee signup linked to HR Manager  
📋 Complete employee onboarding flow  

---

## 📞 Support Resources

- **Supabase:** https://supabase.com/docs
- **Resend:** https://resend.com/docs
- **React:** https://react.dev
- **Tailwind:** https://tailwindcss.com/docs

---

## 🎉 You're Done!

**Total Setup Time:** ~30 minutes  
**Total Testing Time:** ~15 minutes  
**Total Time to Deployment:** ~1 hour  

The complete multi-phase registration system is now ready to:
1. Accept company registrations
2. Process admin approvals
3. Generate unique access codes
4. Enable HR Manager signup

All files are pre-built. Just follow the 6 setup steps above and you're good to go!

**Questions?** Check the detailed guides:
- **Setup Issues:** `MULTI_PHASE_REGISTRATION_GUIDE.md`
- **Architecture:** `MULTI_PHASE_ARCHITECTURE.md`
- **Full Checklist:** `MULTI_PHASE_IMPLEMENTATION_CHECKLIST.md`
