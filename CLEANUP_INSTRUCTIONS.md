# Database Cleanup Instructions

## Goal
Keep only 6 specific users and delete all other demo/test accounts.

## Users to Keep

### IT Company (3 users)
1. ✅ **Super Admin:** giwore2911@dolofan.com / password123
2. ✅ **HR Manager:** hef8q@dollicons.com / password123
3. ✅ **Employee:** zds0i@dollicons.com / password123

### Non-IT Company (3 users)
1. ✅ **Super Admin:** nonitadmin@company.com / password123
2. ✅ **HR Manager:** nonithr@company.com / password123
3. ✅ **Employee:** nonitemployee1@company.com / password123

**Total:** 6 users (all others will be deleted)

---

## ⚠️ IMPORTANT: BACKUP FIRST!

Before running cleanup, create a backup:

```sql
-- Export current users to review
COPY (
    SELECT * FROM users
) TO '/tmp/users_backup.csv' CSV HEADER;

-- Or just view them
SELECT email, role, full_name, company_id 
FROM users 
ORDER BY email;
```

---

## Step-by-Step Cleanup

### Step 1: Check Current Users

Run this to see all current users:

```sql
SELECT 
    email,
    role,
    full_name,
    is_active,
    created_at
FROM users
ORDER BY email;
```

**Count them:**
```sql
SELECT COUNT(*) as total_users FROM users;
```

### Step 2: Preview What Will Be Deleted

**See which users will be DELETED:**

```sql
SELECT 
    email,
    role,
    full_name
FROM users
WHERE email NOT IN (
    'giwore2911@dolofan.com',
    'hef8q@dollicons.com',
    'zds0i@dollicons.com',
    'nonitadmin@company.com',
    'nonithr@company.com',
    'nonitemployee1@company.com'
)
ORDER BY email;
```

**Count how many will be deleted:**
```sql
SELECT COUNT(*) as users_to_delete
FROM users
WHERE email NOT IN (
    'giwore2911@dolofan.com',
    'hef8q@dollicons.com',
    'zds0i@dollicons.com',
    'nonitadmin@company.com',
    'nonithr@company.com',
    'nonitemployee1@company.com'
);
```

### Step 3: Delete Users (Point of No Return)

**⚠️ THIS WILL DELETE DATA! Make sure you reviewed Step 2 first!**

```sql
BEGIN;

-- Delete all users except the 6 we want to keep
DELETE FROM users 
WHERE email NOT IN (
    'giwore2911@dolofan.com',
    'hef8q@dollicons.com',
    'zds0i@dollicons.com',
    'nonitadmin@company.com',
    'nonithr@company.com',
    'nonitemployee1@company.com'
);

-- Check the result before committing
SELECT email, role FROM users ORDER BY email;

-- If it looks correct, commit:
COMMIT;

-- If you made a mistake, run this instead:
-- ROLLBACK;
```

### Step 4: Clean Up Orphaned Employee Records

Remove employee records linked to deleted users:

```sql
-- Delete employees whose users were deleted
DELETE FROM employees 
WHERE user_id IS NOT NULL 
AND user_id NOT IN (SELECT id FROM users);

-- Verify
SELECT COUNT(*) FROM employees WHERE user_id IS NOT NULL;
```

### Step 5: Verify Final State

**Should show only 6 users:**

```sql
SELECT 
    u.email,
    u.role,
    u.full_name,
    c.name as company_name
FROM users u
LEFT JOIN companies c ON u.company_id = c.id
ORDER BY u.email;
```

**Count (should be 6):**
```sql
SELECT COUNT(*) as remaining_users FROM users;
```

---

## Supabase Auth Cleanup (Optional)

If you want to also delete from Supabase Auth (the authentication system):

### Option 1: Via SQL (Requires Service Role)

```sql
-- Run this in Supabase SQL Editor
-- Must have RLS disabled or use service_role key

DELETE FROM auth.users 
WHERE email NOT IN (
    'giwore2911@dolofan.com',
    'hef8q@dollicons.com',
    'zds0i@dollicons.com',
    'nonitadmin@company.com',
    'nonithr@company.com',
    'nonitemployee1@company.com'
);
```

### Option 2: Via Supabase Dashboard

1. Go to Supabase Dashboard
2. Navigate to **Authentication** → **Users**
3. Manually delete users one by one (except the 6 we're keeping)

---

## Verification Checklist

After cleanup, verify:

- [ ] Only 6 users remain in database
- [ ] IT Super Admin can login: giwore2911@dolofan.com
- [ ] IT HR Manager can login: hef8q@dollicons.com
- [ ] IT Employee can login: zds0i@dollicons.com
- [ ] Non-IT Super Admin can login: nonitadmin@company.com
- [ ] Non-IT HR Manager can login: nonithr@company.com
- [ ] Non-IT Employee can login: nonitemployee1@company.com
- [ ] All other test accounts are gone
- [ ] No orphaned employee records

---

## Test Logins After Cleanup

### Test IT Company Logins:

**Super Admin:**
- URL: http://localhost:8000/login
- Email: giwore2911@dolofan.com
- Password: password123
- Should access: Super Admin Dashboard

**HR Manager:**
- Email: hef8q@dollicons.com
- Password: password123
- Should access: HR Dashboard

**Employee:**
- Email: zds0i@dollicons.com
- Password: password123
- Should access: Employee Dashboard

### Test Non-IT Company Logins:

**Super Admin:**
- Email: nonitadmin@company.com
- Password: password123
- Should access: Super Admin Dashboard

**HR Manager:**
- Email: nonithr@company.com
- Password: password123
- Should access: HR Dashboard

**Employee:**
- Email: nonitemployee1@company.com
- Password: password123
- Should access: Employee Dashboard

---

## Final Database State

### Expected Users Table:

```
email                          | role          | company_type
-------------------------------|---------------|-------------
giwore2911@dolofan.com        | super_admin   | IT
hef8q@dollicons.com           | hr_manager    | IT
zds0i@dollicons.com           | employee      | IT
nonitadmin@company.com        | super_admin   | Non-IT
nonithr@company.com           | hr_manager    | Non-IT
nonitemployee1@company.com    | employee      | Non-IT
```

**Total: 6 users** ✅

---

## Rollback (If Something Goes Wrong)

If you're in a transaction and something looks wrong:

```sql
ROLLBACK;
```

If you already committed and need to restore:

1. Check if you have a backup
2. Restore from backup
3. Or manually recreate deleted users

---

## Common Issues

### Issue 1: "Cannot delete - foreign key constraint"

**Solution:** Delete related records first:
```sql
-- Delete attendance records
DELETE FROM attendance WHERE employee_id IN (
    SELECT id FROM employees WHERE user_id NOT IN (SELECT id FROM users)
);

-- Then delete employees
DELETE FROM employees WHERE user_id NOT IN (SELECT id FROM users);

-- Then delete users
DELETE FROM users WHERE email NOT IN (...);
```

### Issue 2: "Auth user still exists"

**Solution:** Delete from auth.users table (see Optional section above)

### Issue 3: "Can't login after cleanup"

**Check:**
```sql
-- Verify user exists
SELECT * FROM users WHERE email = 'giwore2911@dolofan.com';

-- Verify auth user exists
SELECT * FROM auth.users WHERE email = 'giwore2911@dolofan.com';

-- Verify is_active = true
UPDATE users SET is_active = true WHERE email IN (
    'giwore2911@dolofan.com',
    'hef8q@dollicons.com',
    'zds0i@dollicons.com',
    'nonitadmin@company.com',
    'nonithr@company.com',
    'nonitemployee1@company.com'
);
```

---

## Summary

**Before Cleanup:** Multiple demo/test users
**After Cleanup:** Only 6 production users
**Result:** Clean database with only necessary accounts ✅

**Files Created:**
- 📄 `CLEANUP_DATABASE.sql` - SQL script
- 📄 `CLEANUP_INSTRUCTIONS.md` - This guide

**⚠️ WARNING:** This is a destructive operation. Make sure you have backups and review the preview queries before running delete commands!

---

## Quick Cleanup (All-in-One)

If you're sure you want to proceed:

```sql
BEGIN;

-- Delete users
DELETE FROM users 
WHERE email NOT IN (
    'giwore2911@dolofan.com',
    'hef8q@dollicons.com',
    'zds0i@dollicons.com',
    'nonitadmin@company.com',
    'nonithr@company.com',
    'nonitemployee1@company.com'
);

-- Clean up orphaned employees
DELETE FROM employees 
WHERE user_id IS NOT NULL 
AND user_id NOT IN (SELECT id FROM users);

-- Verify
SELECT email, role FROM users ORDER BY email;
SELECT COUNT(*) as total_users FROM users;

-- If looks good:
COMMIT;

-- If not:
-- ROLLBACK;
```

**Run this and you're done!** 🎉
