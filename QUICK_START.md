# Quick Start - Three-Step Signup Implementation

## 🎯 What Was Built

A complete three-page signup flow replacing the old "Super Administrator" registration with:

1. **🏢 Company Login** - Company registration with document uploads
2. **👨‍💼 HR Manager** - HR manager signup for existing companies  
3. **👤 Employee** - Employee signup for existing companies

---

## ⚡ 5-Minute Setup

### Step 1: Database (2 min)
```sql
-- Copy the SQL from:
-- database/migrations/create_company_registrations.sql
-- Paste in Supabase SQL Editor and execute
```

### Step 2: Storage (1 min)
- Go to Supabase Dashboard → Storage
- Click "New Bucket" → Name: `company_documents` → Create

### Step 3: Environment (1 min)
Add to `.env`:
```
EMAIL_USER=your-email@gmail.com
EMAIL_PASSWORD=your-app-password
ADMIN_EMAIL=admin@company.com
```

### Step 4: Routes (1 min)
Update `src/App.tsx`:
```typescript
import SignupNew from './components/auth/SignupNew';
// Change route from Signup to SignupNew:
<Route path="/signup" element={<SignupNew />} />
```

---

## 🧪 Test It

### Go to `/signup` and:

✅ **Test Company Login Flow**
1. Click "Company Login"
2. Fill form with test data
3. Upload PDF files (use any PDF or convert image to PDF)
4. Submit
5. See "Connect with you soon" message
6. Check email inbox for thank you email

✅ **Test HR Manager Flow**
1. Click "HR Manager"
2. Select a company
3. Fill employee form and submit
4. Redirects to dashboard

✅ **Test Employee Flow**
1. Click "Employee"
2. Select a company
3. Fill employee form and submit
4. Redirects to dashboard

---

## 📁 New Files Created

```
src/components/auth/
├── CompanyRegistration.jsx          ← Company registration form
└── SignupNew.jsx                    ← Three-step signup flow

src/api/
└── company-registration.js          ← Backend API functions

database/migrations/
└── create_company_registrations.sql ← Database schema

Documentation/
├── IMPLEMENTATION_GUIDE.md          ← Detailed guide
├── SETUP_CHECKLIST.md              ← Step-by-step checklist
├── IMPLEMENTATION_SUMMARY.md        ← Complete summary
└── QUICK_START.md                  ← This file
```

---

## 🔍 What Happens Behind Scenes

### Company Registration:
1. User fills form with company and SPOC details
2. Selects 4 PDF documents to upload
3. Clicks submit
4. PDFs uploaded to Supabase Storage
5. Registration record created in database
6. Thank you email sent to SPOC
7. Admin notification email sent
8. Success page shows "Connect with you soon"

### HR Manager/Employee Registration:
1. User selects company
2. Fills name, email, password
3. Clicks submit
4. User account created
5. Redirected to dashboard

---

## 📊 Form Fields

### Company Registration
**Always Required:**
- ✅ Company Login (unique identifier)
- ✅ Company Name
- ✅ Location/Details
- ✅ Incorporation Certificate (PDF + ID)
- ✅ Company PAN (Text + PDF)
- ✅ Company TAN (Text + PDF)
- ✅ Company GST (Text + PDF)
- ✅ SPOC Primary: Name, Phone, Email, Address
- ✅ Accept Declaration

**Optional:**
- ⭕ Employee Size
- ⭕ SPOC Secondary Details

### HR Manager/Employee
- ✅ First Name
- ✅ Last Name
- ✅ Email
- ✅ Company (dropdown)
- ✅ Password (8+ chars)

---

## 📧 Emails Sent

### To SPOC (Company Email):
**Subject:** Welcome to Sarjana HR - CompanyName
**Message:** "Connect with you soon."

### To Admin:
**Subject:** New Company Registration: CompanyName
**Content:** Company details, SPOC info, verify link

---

## 🔧 Troubleshooting

**Q: Where do I upload PDFs?**
A: In the Company Registration form, Section 2

**Q: What if PDF upload fails?**
A: Check file size (max 5MB) and format (.pdf only)

**Q: Can I test without setting up emails?**
A: Yes, just skip Step 3 (Environment). Form still works.

**Q: Where's the admin panel to verify companies?**
A: Need to create it. For now, manually verify in database.

**Q: How do I enable the new signup?**
A: Follow Step 4 in "5-Minute Setup" above

---

## ✅ Success Checklist

After setup, verify:
- [ ] Can access `/signup`
- [ ] See 3 signup type options
- [ ] "Company Login" option works
- [ ] Can upload PDF files
- [ ] Success message appears
- [ ] Email received (if configured)
- [ ] "HR Manager" option works
- [ ] "Employee" option works
- [ ] New accounts can log in

---

## 📚 Full Documentation

For complete details, see:
- `IMPLEMENTATION_GUIDE.md` - Detailed architecture
- `SETUP_CHECKLIST.md` - Step-by-step instructions
- `IMPLEMENTATION_SUMMARY.md` - File-by-file breakdown

---

## 🚀 Next Steps

### To Fully Activate:
1. ✅ Run database migration
2. ✅ Create storage bucket
3. ✅ Update `.env` with email credentials
4. ✅ Update routing to use SignupNew
5. ⭐ Create admin verification page (optional but recommended)

### To Test with Real Emails:
1. Set up Gmail app password (see SETUP_CHECKLIST.md)
2. Add to `.env`
3. Restart dev server
4. Test signup flow

### To Deploy:
1. Ensure `.env` vars set in production
2. Run migration on production database
3. Create bucket in production storage
4. Test signup on production
5. Monitor error logs

---

## 💡 Key Features

✨ **PDF Uploads** - Supports legal document uploads
✨ **Email Notifications** - Auto emails to SPOC and admin
✨ **Validation** - Client and server-side validation
✨ **Responsive** - Works on mobile and desktop
✨ **Three Roles** - Company, HR Manager, Employee paths
✨ **Success Message** - "Connect with you soon" on completion

---

## 🎓 Learning Resources

Check each component file for detailed comments:
- `CompanyRegistration.jsx` - Form handling, file uploads
- `SignupNew.jsx` - State management, routing
- `company-registration.js` - Email service, API functions

---

## 📞 Quick Help

**Files Modified:**
- `src/App.tsx` - Need to update import + route

**Files Created (don't modify):**
- `CompanyRegistration.jsx`
- `SignupNew.jsx`
- `company-registration.js`
- `create_company_registrations.sql`

**Test URLs:**
- `/signup` - New signup flow
- `/login` - Login page
- `/dashboard` - After signup

---

## ✨ You're All Set!

All components are ready. Just follow the 5-minute setup above and you're good to go! 🚀

Questions? Check the documentation files or review the component code comments.
