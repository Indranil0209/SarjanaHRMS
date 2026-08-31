# Step-by-Step: Adding Users with Roles

Follow these exact steps to add users to your system with the correct role.

---

## QUICK START: Add a Super Admin in 5 Minutes

### Step 1: Open Supabase Console (1 minute)
```
1. Go to https://app.supabase.com
2. Log in with your account
3. Select your HR Management project
4. Wait for it to load
```

### Step 2: Create Auth User (1 minute)
```
1. Click "Authentication" in the left sidebar
   (It's the key icon)

2. Click "Users" tab at the top

3. Click the button "Add user" (top right)

4. Fill in the form:
   Email: admin@company.com
   Password: SuperSecure123!
   
5. Leave other options as default

6. Click "Create user" button

7. Wait for confirmation message ✓

8. Look at the user list
   - Find your new user
   - Copy the "User ID" column
   - It looks like: 550e8400-e29b-41d4-a716-446655440000
   - 📋 SAVE THIS ID (you'll need it next)
```

### Step 3: Create User Role in Database (2 minutes)
```
1. Click "SQL Editor" in left sidebar
   (It's the curly braces {} icon)

2. Click "+ New Query" button

3. Clear any existing text

4. Copy this entire block (replacing PASTE_HERE):

---BEGIN COPY---
INSERT INTO users (
  id,
  email,
  full_name,
  first_name,
  last_name,
  role,
  is_active,
  email_verified
)
VALUES (
  'PASTE_USER_ID_HERE',
  'admin@company.com',
  'System Administrator',
  'System',
  'Admin',
  'super_admin'::user_role,
  true,
  true
);
---END COPY---

5. Click in the query area

6. Find this line: 'PASTE_USER_ID_HERE'

7. Replace PASTE_USER_ID_HERE with the UUID you copied
   Example: 
   BEFORE: 'PASTE_USER_ID_HERE'
   AFTER:  '550e8400-e29b-41d4-a716-446655440000'

8. Click "Run" button (or press Ctrl+Enter)

9. Wait for success message ✓

10. Done! Your super admin is ready
```

### Step 4: Test the Login (1 minute)
```
1. Open your HR Management app in a new tab
   (Probably http://localhost:3001)

2. Click "Sign In" button

3. Enter:
   Email: admin@company.com
   Password: SuperSecure123!

4. Click "Sign In" button

5. You should see:
   ✓ Loading page briefly
   ✓ Redirects to Admin Dashboard
   ✓ Shows admin menu options
   ✓ Full system access

6. Success! 🎉
```

---

## Adding Other Roles (Same Process)

### Add HR Manager

**Step 1: Create Auth User** (same as above)
- Email: hr@company.com
- Password: HRPass123!

**Step 2: Get the UUID** (same as above)
- Copy the User ID

**Step 3: Create User Role in Database**
```sql
INSERT INTO users (
  id,
  email,
  full_name,
  first_name,
  last_name,
  role,
  is_active,
  email_verified,
  company_id
)
VALUES (
  'PASTE_USER_ID_HERE',        -- Replace with copied UUID
  'hr@company.com',
  'HR Manager',
  'HR',
  'Manager',
  'hr_manager'::user_role,     -- Changed from super_admin
  true,
  true,
  'YOUR_COMPANY_UUID_HERE'     -- Need to add company ID
);
```

**To get Company UUID:**
- In SQL Editor, run: `SELECT id, company_name FROM companies;`
- Copy an ID from the list
- Paste it in the SQL above

### Add Employee

Same as HR Manager but with:
```
role: 'employee'::user_role
company_id: (same as HR manager)
```

### Add Admin

Same as Super Admin but with:
```
role: 'admin'::user_role
(company_id not needed - can be NULL)
```

---

## Common Issues & Fixes

### Issue: "Can't find the User ID to copy"
**Solution:**
- In Authentication > Users, look for your newly created user
- The "User ID" column is on the right side
- It's a long string of letters/numbers/dashes
- Copy the ENTIRE string exactly

### Issue: "SQL error: duplicate key value violates unique constraint"
**Solution:**
- The email already exists in the users table
- Use a different email address
- Or run: `DELETE FROM users WHERE email='email@company.com';`

### Issue: "SQL error: invalid input syntax for type uuid"
**Solution:**
- The User ID you pasted is wrong
- Copy the ID again from Auth console
- Make sure you copy the ENTIRE thing
- Don't include quotes or spaces

### Issue: "User created but still goes to Employee dashboard"
**Solution:**
1. Check the role was saved:
   - Run: `SELECT email, role FROM users WHERE email='admin@company.com';`
   - It should show: super_admin (not employee)

2. If role is employee:
   - The role might not have been set
   - Run: `UPDATE users SET role='super_admin'::user_role WHERE email='admin@company.com';`
   - Refresh the page

3. If role is correct:
   - Sign out completely
   - Clear browser cache (Ctrl+Shift+Delete)
   - Sign in again

### Issue: "SQL error: foreign key constraint"
**Solution:**
- The company_id doesn't exist
- Run: `SELECT id FROM companies;`
- Use one of the IDs shown
- Or set company_id to NULL (only for admin/super_admin)

---

## Bulk Add Multiple Users

If you need to add many users at once:

### Step 1: Get All UUIDs First
Create all Auth users first:
1. Create auth user for super-admin
2. Create auth user for hr-manager-1
3. Create auth user for hr-manager-2
4. Create auth user for employee-1
5. Create auth user for employee-2
6. Copy all UUIDs

### Step 2: Get Company IDs
```sql
SELECT id, company_name FROM companies;
```
Copy one or more company IDs

### Step 3: Insert All at Once
```sql
INSERT INTO users (
  id, email, full_name, first_name, last_name,
  role, is_active, email_verified, company_id
)
VALUES
  ('UUID_1', 'super-admin@company.com', 'Super Admin', 'Super', 'Admin', 'super_admin'::user_role, true, true, NULL),
  ('UUID_2', 'hr1@company.com', 'HR Manager 1', 'HR', 'One', 'hr_manager'::user_role, true, true, 'COMPANY_UUID'),
  ('UUID_3', 'hr2@company.com', 'HR Manager 2', 'HR', 'Two', 'hr_manager'::user_role, true, true, 'COMPANY_UUID'),
  ('UUID_4', 'emp1@company.com', 'Employee 1', 'Employee', 'One', 'employee'::user_role, true, true, 'COMPANY_UUID'),
  ('UUID_5', 'emp2@company.com', 'Employee 2', 'Employee', 'Two', 'employee'::user_role, true, true, 'COMPANY_UUID');
```

Replace:
- UUID_1, UUID_2, etc. with the auth user IDs
- COMPANY_UUID with the company ID from step 2

---

## Verification Checklist

After adding each user, verify:

### ✓ Auth User Created
```
In Supabase Console:
- Authentication > Users
- See the email in the list
- User ID is visible
```

### ✓ Database User Created
```
In Supabase Console:
- SQL Editor
- Run: SELECT * FROM users WHERE email='email@company.com';
- Should return one row with your data
```

### ✓ Role is Correct
```
In Supabase Console:
- SQL Editor
- Run: SELECT email, role FROM users WHERE email='email@company.com';
- Should show correct role (super_admin, admin, hr_manager, or employee)
```

### ✓ Can Login
```
In your app:
- Go to Sign In page
- Use the email and password you set in Auth
- Should login successfully
- Should redirect to correct dashboard
```

### ✓ Dashboard is Correct
```
After login check:
- Super Admin → Admin Dashboard with full menu
- Admin → Admin Dashboard with admin menu
- HR Manager → HR Dashboard with HR menu
- Employee → Employee Dashboard with employee menu
```

---

## Cheat Sheet: All Roles

### Role: super_admin
- **Level:** Highest
- **Company Required:** No
- **Dashboard:** Admin Dashboard (full access)
- **SQL:** `'super_admin'::user_role`

### Role: admin  
- **Level:** High
- **Company Required:** No
- **Dashboard:** Admin Dashboard (admin access)
- **SQL:** `'admin'::user_role`

### Role: hr_manager
- **Level:** Medium
- **Company Required:** Yes (must provide company_id)
- **Dashboard:** HR Manager Dashboard
- **SQL:** `'hr_manager'::user_role`

### Role: employee
- **Level:** Low
- **Company Required:** Yes (must provide company_id)
- **Dashboard:** Employee Dashboard
- **SQL:** `'employee'::user_role`

---

## SQL Cheat Sheet

### View all users
```sql
SELECT id, email, full_name, role, is_active FROM users;
```

### View users by role
```sql
SELECT email, full_name FROM users WHERE role='super_admin'::user_role;
```

### Change user role
```sql
UPDATE users SET role='admin'::user_role WHERE email='user@company.com';
```

### Delete user
```sql
DELETE FROM users WHERE email='user@company.com';
```

### Check if user exists
```sql
SELECT * FROM users WHERE email='user@company.com';
```

### Count users by role
```sql
SELECT role, COUNT(*) FROM users GROUP BY role;
```

---

## When You're Stuck

1. **Check the user exists:**
   ```sql
   SELECT * FROM users WHERE email='your-email@company.com';
   ```

2. **If user doesn't exist:**
   - Make sure you did Step 1 (Create Auth user)
   - Make sure you did Step 2 (Create user profile)
   - Check you used same email in both steps

3. **If user exists but wrong role:**
   ```sql
   UPDATE users SET role='correct_role'::user_role WHERE email='your-email@company.com';
   ```

4. **If login doesn't work:**
   - Make sure password matches what you set in Auth
   - Make sure email matches exactly
   - Clear browser cache

5. **If routed to wrong dashboard:**
   - Check the database role is correct: `SELECT role FROM users WHERE email='...';`
   - Sign out and sign in again
   - Clear browser cache and local storage

---

## Quick Copy-Paste Templates

### Template 1: Super Admin
```sql
INSERT INTO users (id, email, full_name, first_name, last_name, role, is_active, email_verified)
VALUES ('PASTE_UUID', 'admin@company.com', 'Admin Name', 'Admin', 'Name', 'super_admin'::user_role, true, true);
```

### Template 2: HR Manager
```sql
INSERT INTO users (id, email, full_name, first_name, last_name, role, is_active, email_verified, company_id)
VALUES ('PASTE_UUID', 'hr@company.com', 'HR Name', 'HR', 'Name', 'hr_manager'::user_role, true, true, 'COMPANY_UUID');
```

### Template 3: Employee
```sql
INSERT INTO users (id, email, full_name, first_name, last_name, role, is_active, email_verified, company_id)
VALUES ('PASTE_UUID', 'employee@company.com', 'Emp Name', 'Emp', 'Name', 'employee'::user_role, true, true, 'COMPANY_UUID');
```

---

## Done!

You now know how to:
✅ Create users with specific roles
✅ Test that roles work correctly
✅ Fix common issues
✅ Add multiple users at once
✅ Manage user roles

Your system is fully set up for role-based access control!
