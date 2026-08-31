# Supabase Configuration Setup Instructions

**Task:** Set company_type = 'non-it' for Non-IT demo users  
**Importance:** ⚠️ CRITICAL - Must be done before testing  
**Time Required:** 2-3 minutes

---

## Step-by-Step Instructions

### Step 1: Open Supabase Dashboard
1. Go to https://app.supabase.com
2. Log in with your Supabase credentials
3. Select your project
4. Navigate to **SQL Editor**

---

### Step 2: Open SQL Editor
1. In left sidebar, click **SQL Editor**
2. Click **+ New Query** button
3. You'll see a blank SQL editor window

---

### Step 3: Copy and Paste SQL

**Copy this entire SQL script:**

```sql
-- ============================================
-- UPDATE NON-IT USERS COMPANY_TYPE
-- ============================================

-- Step 1: Update company_type for Non-IT users
UPDATE public.users 
SET company_type = 'non-it' 
WHERE email IN (
  'nonitadmin@company.com',
  'nonithr@company.com',
  'nonitemployee1@company.com',
  'nonitemployee2@company.com',
  'nonitemployee3@company.com'
);
```

**Paste into the SQL Editor**

---

### Step 4: Run the Update Query

1. Click the blue **Run** button (or press Ctrl+Enter)
2. You should see: "Query executed successfully"
3. The output will show: "0 rows" or the number of rows updated

**Expected Output:**
```
Query executed successfully
0 rows
```

⚠️ **Note:** If you see "0 rows", it means no users were found. This could mean:
- Users don't exist yet (create them first)
- Email addresses are different
- Users table doesn't have company_type column

---

### Step 5: Verify the Update

**Copy and paste this verification query:**

```sql
-- Verify the update
SELECT 
  email, 
  role, 
  company_type,
  is_active,
  email_verified
FROM public.users 
WHERE email IN (
  'nonitadmin@company.com',
  'nonithr@company.com',
  'nonitemployee1@company.com',
  'nonitemployee2@company.com',
  'nonitemployee3@company.com'
)
ORDER BY email;
```

**Click Run**

---

### Step 6: Check Results

You should see a table like this:

| email | role | company_type | is_active | email_verified |
|-------|------|--------------|-----------|----------------|
| nonitadmin@company.com | super_admin | **non-it** | true | true |
| nonitemployee1@company.com | employee | **non-it** | true | true |
| nonitemployee2@company.com | employee | **non-it** | true | true |
| nonitemployee3@company.com | employee | **non-it** | true | true |
| nonithr@company.com | hr_manager | **non-it** | true | true |

**If all show `company_type = 'non-it'` ✅ Success!**

---

### Step 7: Verify IT Users Are Unchanged

**Copy this verification query:**

```sql
-- Verify IT users are unchanged
SELECT 
  email, 
  role, 
  company_type
FROM public.users 
WHERE email IN (
  'giwore2911@dolofan.com',
  'hef8q@dollicons.com',
  'zds0i@dollicons.com'
);
```

**Click Run**

You should see:

| email | role | company_type |
|-------|------|--------------|
| giwore2911@dolofan.com | super_admin | **it** |
| hef8q@dollicons.com | hr_manager | **it** |
| zds0i@dollicons.com | employee | **it** |

**If all show `company_type = 'it'` ✅ Success!**

---

## Troubleshooting

### Issue 1: "No rows returned" in verification

**Cause:** Users don't exist in the database

**Solution:**
1. First create the users in Supabase Auth:
   - Go to Authentication → Users
   - Click "Add user" for each Non-IT email
   - Set passwords and roles manually
2. Then run the SQL update again

### Issue 2: "Column company_type does not exist"

**Cause:** Your users table doesn't have the company_type column

**Solution:**
1. Add the column using this SQL:
```sql
ALTER TABLE public.users 
ADD COLUMN company_type TEXT DEFAULT 'it';
```
2. Then run the update query

### Issue 3: "Permission denied"

**Cause:** Your Supabase role doesn't have permissions

**Solution:**
1. Make sure you're logged in as project owner
2. Try using a new "Anonymous" connection if available
3. Contact Supabase support if issue persists

---

## What Gets Updated

### Before Running SQL:
```
Non-IT users: company_type = NULL or 'it'
IT users: company_type = 'it'
```

### After Running SQL:
```
Non-IT users: company_type = 'non-it' ✅
IT users: company_type = 'it' (unchanged)
```

---

## Impact on Application

### Routing Changes After Update:

**Non-IT Employees**
- ❌ Before: See EmployeeDashboard (IT version)
- ✅ After: See NonITEmployeeDashboard (with live location)

**Non-IT HR Managers**
- ❌ Before: See HRDashboard (IT version)
- ✅ After: See NonITHRDashboard (with location tracking)

**Non-IT Admin**
- ❌ Before: See AdminDashboard
- ✅ After: See CompanyDashboard (with all locations)

**IT Users**
- ✅ Unchanged: Still see their normal dashboards

---

## Verification Checklist

After running the SQL:

- [ ] Update query executed successfully
- [ ] Verification query shows all Non-IT users with company_type = 'non-it'
- [ ] IT users still have company_type = 'it'
- [ ] No error messages in SQL editor
- [ ] Can log in with Non-IT credentials
- [ ] Non-IT dashboards display correctly
- [ ] Location tracking features visible

---

## Rollback Instructions (If Needed)

If you need to revert the changes:

```sql
-- Rollback: Set Non-IT users back to 'it'
UPDATE public.users 
SET company_type = 'it' 
WHERE email IN (
  'nonitadmin@company.com',
  'nonithr@company.com',
  'nonitemployee1@company.com',
  'nonitemployee2@company.com',
  'nonitemployee3@company.com'
);
```

---

## Next Steps After Supabase Setup

1. ✅ Run SQL update (this guide)
2. Verify all users have correct company_type
3. Log in with Non-IT credentials
4. Test Non-IT Employee Dashboard
5. Test Non-IT HR Dashboard
6. Test Admin Company Dashboard
7. Fill in BACKEND_VERIFICATION_REPORT.md

---

## Important Notes

⚠️ **Do NOT:**
- Run this on production without backup
- Modify other columns while updating
- Delete any users while updating
- Run the SQL multiple times (it's idempotent, but verify once)

✅ **DO:**
- Save this SQL in your documentation
- Record the execution timestamp
- Note any error messages
- Test with demo accounts after update
- Monitor logs for any issues

---

## Support

If you encounter issues:

1. Check the Troubleshooting section above
2. Review your Supabase project logs
3. Verify database connection
4. Check that users exist before updating
5. Ensure you have proper permissions

---

**Prepared by:** AI Assistant  
**Date:** July 16, 2026  
**Status:** Ready for execution

**Execute this before testing Non-IT features!**
