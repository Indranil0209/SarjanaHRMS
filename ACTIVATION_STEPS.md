# Activation Steps - Three-Step Signup Implementation

## ✅ Current Status

All components and files have been **created and ready to use**. Here's what you need to do to activate the new three-step signup flow.

---

## 🚀 Step 1: Database Setup (CRITICAL)

### Run This SQL in Supabase

1. Go to **Supabase Dashboard** → **SQL Editor**
2. Click "New Query"
3. Copy the entire contents of: `database/migrations/create_company_registrations.sql`
4. Paste into Supabase SQL Editor
5. Click "Run"

**What it does:**
- Creates `company_registrations` table
- Adds 4 indexes for performance
- Adds trigger for `updated_at` auto-update

**Verify Success:**
```sql
SELECT * FROM company_registrations LIMIT 1;
-- Should return empty table, not error
```

---

## 🪣 Step 2: Create Storage Bucket

1. Go to **Supabase Dashboard** → **Storage**
2. Click "New Bucket"
3. **Bucket Name:** `company_documents`
4. **Make it Public:** Yes (toggle on)
5. Click "Create Bucket"

**Verify Success:**
- Bucket appears in storage list
- Can click on it to see empty folder

---

## ⚙️ Step 3: Environment Variables

### Option A: Development (.env file)

Add these lines to your `.env` file:

```env
# Email Configuration
EMAIL_USER=your-gmail@gmail.com
EMAIL_PASSWORD=your-app-password
ADMIN_EMAIL=admin@yourcompany.com
ADMIN_PANEL_URL=http://localhost:8000/admin
```

### Option B: Using Gmail

**If using Gmail:**

1. Go to https://myaccount.google.com/security
2. Enable "2-Step Verification" (if not already enabled)
3. Go to "App passwords"
4. Select "Mail" and "Windows Computer"
5. Click "Generate"
6. Copy the 16-character password
7. Use that password as `EMAIL_PASSWORD`

**Important:** Use the app-generated password, NOT your regular Gmail password

---

## 🔄 Step 4: Update Routing (REQUIRED FOR ACTIVATION)

### File: `src/App.tsx`

Find this line (around line 9):
```typescript
import Signup from './pages/Signup';
```

Add this line after it:
```typescript
import SignupNew from './components/auth/SignupNew';
```

Then find the routes section and look for:
```typescript
<Route path="/signup" element={<Signup />} />
```

Replace it with:
```typescript
<Route path="/signup" element={<SignupNew />} />
```

**Verify:** Look for syntax errors in your IDE - it should show no red squiggles

---

## ✨ Step 5: Restart Development Server

```bash
# Stop current server (Ctrl+C in terminal)
# Then restart:
npm run dev
```

Wait for message: `ready in X ms`

---

## 🧪 Step 6: Test the Implementation

### Test Basic Access

1. Open browser to `http://localhost:8000/signup` (or your dev port)
2. You should see **3 signup options:**
   - 🏢 Company Login
   - 👨‍💼 HR Manager
   - 👤 Employee

✅ **If you see these 3 options, routing is working!**

---

## 🧑‍💼 Step 7: Test Company Registration

### Do This Test:

1. Click **"Company Login"** on signup page
2. Fill form with test data:
   ```
   Company Login: test_company_001
   Company Name: Test Company Inc
   Location: 123 Main St, City, State
   Employee Size: 50
   ```

3. **For PDF files:** You can upload any PDF or create one:
   - Open Word/Google Docs → export as PDF
   - For each document field, upload this PDF
   - Important: Must be actual PDF format

4. **SPOC Details:**
   ```
   Name: John Doe
   Phone: 9999999999
   Email: test@example.com (or your email)
   Address: Some address here
   ```

5. Check the declaration checkbox
6. Click "Submit Registration"

### Expected Result:

- ✅ Should see success page with "Connect with you soon"
- ✅ If email configured: Should receive thank you email
- ✅ Data visible in database query:
  ```sql
  SELECT * FROM company_registrations ORDER BY created_at DESC LIMIT 1;
  ```

---

## 👨‍💼 Step 8: Test HR Manager Signup

1. Go back to `http://localhost:8000/signup`
2. Click **"HR Manager"**
3. Click the **role selection area** for HR Manager
4. Fill form:
   ```
   First Name: John
   Last Name: Manager
   Email: hrmanager@test.com
   Company: (select any from dropdown)
   Password: TestPass123
   Confirm: TestPass123
   ```
5. Click "Create Account"

### Expected Result:

- ✅ Account created in database
- ✅ Redirects to `/dashboard`
- ✅ Query check:
  ```sql
  SELECT * FROM users WHERE email = 'hrmanager@test.com';
  ```

---

## 👤 Step 9: Test Employee Signup

1. Go back to `http://localhost:8000/signup`
2. Click **"Employee"**
3. Select company and fill form
4. Create account

### Expected Result:

- ✅ Employee account created
- ✅ Can log in with created credentials

---

## 📧 Step 10: Verify Email Notifications (If Configured)

Check your email inbox for:

1. **Thank You Email** (from SPOC email in company registration)
   - Subject: "Welcome to Sarjana HR - Test Company Inc"
   - Message contains: "Connect with you soon"

2. **Admin Notification Email** (at ADMIN_EMAIL)
   - Subject: "New Company Registration: Test Company Inc"
   - Contains registration details

---

## 🔍 Troubleshooting Activation

### Problem: 404 Error on `/signup`

**Solution:**
- Clear browser cache (Ctrl+Shift+Delete)
- Restart dev server
- Check routing in `src/App.tsx`

### Problem: Form not showing

**Solution:**
- Check browser console for errors (F12)
- Verify all imports exist
- Ensure `npm install` ran successfully

### Problem: PDF upload fails

**Solution:**
- File must be actual PDF (not image renamed to .pdf)
- File must be < 5MB
- Check Supabase storage bucket exists and is public

### Problem: Email not sending

**Solution:**
- Double-check EMAIL_USER and EMAIL_PASSWORD in .env
- Verify app password from Gmail (not regular password)
- Check if emails went to spam folder
- If not configured, form still works without emails

### Problem: Database errors

**Solution:**
- Verify SQL migration ran successfully
- Check table exists: 
  ```sql
  \dt company_registrations
  ```
- Verify RLS policies (if using Supabase)

---

## ✅ Activation Checklist

Before considering activation complete:

- [ ] SQL migration executed successfully
- [ ] Storage bucket `company_documents` created
- [ ] Environment variables added to `.env`
- [ ] Routing updated in `src/App.tsx`
- [ ] Dev server restarted
- [ ] Can access `/signup`
- [ ] See all 3 signup options
- [ ] Company registration form loads
- [ ] Can submit test registration
- [ ] Success page shows "Connect with you soon"
- [ ] Data visible in database
- [ ] HR Manager signup works
- [ ] Employee signup works

**Once all items checked: ✅ YOU'RE ACTIVATED!**

---

## 📊 What Gets Created When Testing

### In Database:
```
company_registrations table:
├─ 1 test registration record
└─ status: 'pending_verification'

users table:
├─ 1 HR Manager user
└─ 1 Employee user
```

### In Storage:
```
company_documents/
└─ company_{timestamp}_{random}/
   ├─ incorporation_certificate.pdf
   ├─ company_pan.pdf
   ├─ company_tan.pdf
   └─ company_gst.pdf
```

### In Email (if configured):
```
SPOC Inbox:
└─ 1 Welcome Email

Admin Inbox:
└─ 1 Registration Notification
```

---

## 🎯 Next Recommended Steps

After activation is confirmed:

### Immediate:
1. **Create Admin Verification Page**
   - List pending registrations
   - Allow admin to verify/reject
   - Auto-create company on approval

2. **Test with Real Data**
   - Use actual company details
   - Test with real email addresses
   - Verify full workflow

### Short-term:
1. **Customize Email Templates**
   - Add company logo
   - Match brand styling
   - Add helpful links

2. **Add Validation Rules**
   - Company name uniqueness (already done)
   - Phone number format
   - Address validation

### Medium-term:
1. **Add SMS Notifications**
   - OTP verification
   - Notification to SPOC

2. **Analytics**
   - Track signup completion rates
   - Monitor document upload success
   - Measure verification time

---

## 🆘 Support Commands

### Check Table Exists:
```sql
SELECT * FROM company_registrations LIMIT 0;
```

### View Pending Registrations:
```sql
SELECT id, company_name, status, created_at 
FROM company_registrations 
WHERE status = 'pending_verification'
ORDER BY created_at DESC;
```

### Check User Count:
```sql
SELECT role, COUNT(*) as count FROM users GROUP BY role;
```

### Check Storage:
```
Supabase Dashboard → Storage → company_documents
(Should see folder with registration ID)
```

---

## 🎉 Activation Complete!

Once you've completed all steps above, the three-step signup flow is fully activated and ready for use!

**Next:** Users can now:
- Register companies with document uploads
- Join as HR managers
- Join as employees
- Receive confirmation emails
- Admins can verify registrations

---

## 📞 Quick Reference

| Item | Location |
|------|----------|
| Components | `src/components/auth/` |
| API Functions | `src/api/company-registration.js` |
| Database Migration | `database/migrations/create_company_registrations.sql` |
| Routes File | `src/App.tsx` |
| Environment File | `.env` |
| Test URL | `http://localhost:8000/signup` |
| Signup Type Selection | First page after /signup |
| Company Registration | When "Company Login" selected |
| Success Message | "Connect with you soon" |

---

**🚀 Ready to activate? Start with Step 1 above!**
