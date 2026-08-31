# Setup Checklist for Three-Step Signup Implementation

## Database Setup

### ✅ Step 1: Create company_registrations Table
```sql
-- Run this in Supabase SQL Editor:
CREATE TABLE IF NOT EXISTS company_registrations (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    company_login VARCHAR(255) UNIQUE NOT NULL,
    company_name VARCHAR(255) NOT NULL,
    company_location TEXT NOT NULL,
    employee_size INTEGER,
    incorporation_certificate_id VARCHAR(100),
    incorporation_certificate_file TEXT,
    pan_number VARCHAR(20),
    pan_file TEXT,
    tan_number VARCHAR(20),
    tan_file TEXT,
    gst_number VARCHAR(20),
    gst_file TEXT,
    spoc_primary_name VARCHAR(100) NOT NULL,
    spoc_primary_phone VARCHAR(20) NOT NULL,
    spoc_primary_email VARCHAR(255) NOT NULL,
    spoc_primary_address TEXT NOT NULL,
    spoc_secondary_name VARCHAR(100),
    spoc_secondary_phone VARCHAR(20),
    spoc_secondary_email VARCHAR(255),
    spoc_secondary_address TEXT,
    status VARCHAR(50) DEFAULT 'pending_verification',
    rejection_reason TEXT,
    verified_at TIMESTAMP WITH TIME ZONE,
    verified_by UUID REFERENCES users(id),
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

CREATE INDEX idx_company_registrations_status ON company_registrations(status);
CREATE INDEX idx_company_registrations_company_login ON company_registrations(company_login);
CREATE INDEX idx_company_registrations_spoc_primary_email ON company_registrations(spoc_primary_email);
CREATE INDEX idx_company_registrations_created_at ON company_registrations(created_at DESC);

CREATE OR REPLACE FUNCTION update_company_registrations_updated_at()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trigger_company_registrations_updated_at
BEFORE UPDATE ON company_registrations
FOR EACH ROW
EXECUTE FUNCTION update_company_registrations_updated_at();
```

### ✅ Step 2: Create Storage Bucket
1. Go to Supabase Dashboard → Storage
2. Click "New Bucket"
3. Name it: `company_documents`
4. Choose "Public" for easier access
5. Click Create

### ✅ Step 3: Enable Row Level Security (RLS) Policies
```sql
-- Allow authenticated users to read their own registrations
CREATE POLICY "Users can read own registrations"
ON company_registrations FOR SELECT
USING (auth.uid()::text = created_at::text OR verified_by = auth.uid());

-- Allow anyone to insert registrations
CREATE POLICY "Anyone can register companies"
ON company_registrations FOR INSERT
WITH CHECK (true);

-- Allow admins to update registrations
CREATE POLICY "Admins can update registrations"
ON company_registrations FOR UPDATE
USING (verified_by = auth.uid() OR auth.uid() IN (
    SELECT id FROM users WHERE role = 'super_admin'
));
```

## Environment Configuration

### ✅ Step 4: Update .env File
```env
# Existing variables (keep these)
VITE_SUPABASE_URL=your_supabase_url
VITE_SUPABASE_ANON_KEY=your_anon_key

# Add these new variables for email notifications
EMAIL_USER=your-gmail@gmail.com
EMAIL_PASSWORD=your-app-password
ADMIN_EMAIL=admin@yourcompany.com
ADMIN_PANEL_URL=http://localhost:8000/admin

# Optional: Email service alternative
# EMAIL_SERVICE=sendgrid
# SENDGRID_API_KEY=your-key
```

### ✅ Step 5: Setup Gmail App Password (for Nodemailer)
1. Go to https://myaccount.google.com/security
2. Enable 2-Factor Authentication
3. Go to App passwords
4. Select Mail and Windows Computer
5. Generate app password
6. Copy the 16-character password to EMAIL_PASSWORD in .env

## Frontend Configuration

### ✅ Step 6: Update Routes
In `src/App.tsx` or main routing file:
```typescript
// Import the new signup component
import SignupNew from './components/auth/SignupNew';

// Update or add this route:
<Route path="/signup" element={<SignupNew />} />
```

### ✅ Step 7: Update Navigation Links
Update any links pointing to `/signup` (they should now go to the new three-step flow):
```jsx
<Link to="/signup">Sign Up</Link>
```

## Component Verification

### ✅ Step 8: Verify Component Files Exist
Check that these files have been created:
- ✅ `src/components/auth/CompanyRegistration.jsx`
- ✅ `src/components/auth/SignupNew.jsx`
- ✅ `src/api/company-registration.js`
- ✅ `database/migrations/create_company_registrations.sql`

## Testing

### ✅ Step 9: Test Signup Type Selection
1. Go to `/signup`
2. You should see three options:
   - Company Login
   - HR Manager
   - Employee
3. Click each to verify navigation

### ✅ Step 10: Test Company Registration
1. Click "Company Login"
2. Fill in all required fields:
   - Company Login
   - Company Name
   - Location
   - SPOC Primary Details
   - Legal Documents (upload PDFs)
3. Accept declaration and submit
4. Verify success message appears

### ✅ Step 11: Test HR Manager Signup
1. Click "HR Manager"
2. Click "Choose Role"
3. Fill in registration form:
   - First Name, Last Name
   - Email
   - Select Company
   - Password
4. Submit and verify account created

### ✅ Step 12: Test Employee Signup
1. Click "Employee"
2. Click "Choose Role"
3. Fill in registration form
4. Submit and verify account created

### ✅ Step 13: Test Email Notifications
1. Check inbox of SPOC email entered
2. Verify thank you email received
3. Check admin email inbox
4. Verify admin notification received

## Database Queries for Testing

### View Pending Registrations
```sql
SELECT * FROM company_registrations WHERE status = 'pending_verification' ORDER BY created_at DESC;
```

### View Verified Companies
```sql
SELECT * FROM company_registrations WHERE status = 'verified' ORDER BY verified_at DESC;
```

### Check User Count by Role
```sql
SELECT role, COUNT(*) FROM users GROUP BY role;
```

### View Company Documents in Storage
```
-- Use Supabase Dashboard → Storage → company_documents
-- You should see folders with registration IDs
```

## Performance Optimization

### ✅ Step 14: Add Database Indexes
Already included in migration, but verify:
```sql
-- Check indexes exist
SELECT indexname FROM pg_indexes WHERE tablename = 'company_registrations';
```

### ✅ Step 15: Enable Caching (Optional)
In your auth context, consider caching companies list:
```javascript
// Cache company data for 5 minutes
const CACHE_DURATION = 5 * 60 * 1000;
```

## Security Checklist

### ✅ Authentication
- [ ] API endpoints require authentication where appropriate
- [ ] PDF upload restricted to authorized users
- [ ] Email validation on both client and server

### ✅ File Security
- [ ] PDF files validated (type and size)
- [ ] Files stored in private storage bucket (optional)
- [ ] File names sanitized

### ✅ Data Protection
- [ ] PAN, TAN, GST numbers encrypted (future enhancement)
- [ ] SPOC emails not public
- [ ] Admin verification required before approval

### ✅ Rate Limiting
- Consider adding rate limiting to signup endpoint
- Prevent spam registrations

## Deployment Checklist

### ✅ Before Going Live
- [ ] All environment variables set in production
- [ ] Database migrations run in production
- [ ] Storage bucket created in production
- [ ] Email service configured and tested
- [ ] Admin panel created for verification
- [ ] SSL certificate active
- [ ] Error logging configured
- [ ] Backup enabled

### ✅ Monitoring
- [ ] Track signup completion rates
- [ ] Monitor email delivery
- [ ] Alert on failed registrations
- [ ] Track document upload success

## Troubleshooting

### Email Not Sending
1. Check EMAIL_USER and EMAIL_PASSWORD in .env
2. Verify Gmail app password is correct
3. Check admin email address is valid
4. Look for errors in server logs

### PDF Upload Failing
1. Verify file size < 5MB
2. Check file is valid PDF
3. Verify storage bucket exists and is public
4. Check Supabase storage credentials

### Company Not Visible After Registration
1. Check registration status in database
2. Verify admin verified the registration
3. Check company created in companies table
4. Verify user has correct role assigned

### Database Connection Issues
1. Check Supabase credentials in .env
2. Verify database table exists
3. Check RLS policies are correct
4. Look for connection pool issues

## Support Resources

- Supabase Docs: https://supabase.com/docs
- React Documentation: https://react.dev
- Tailwind CSS: https://tailwindcss.com
- Nodemailer: https://nodemailer.com

## Success Indicators

✅ All three signup types working
✅ Company registration accepts PDF uploads
✅ Thank you email sent to SPOC
✅ Admin receives notification email
✅ HR Manager can sign up and access dashboard
✅ Employee can sign up and access dashboard
✅ Company registration data stored correctly
✅ No console errors in browser
✅ All form validations working
✅ Success page shows "Connect with you soon"
