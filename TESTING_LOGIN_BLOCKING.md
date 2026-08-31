# Testing Cross-Portal Login Blocking

## Setup Before Testing

1. **Start the dev server:**
   ```bash
   npm run dev
   ```

2. **Open browser developer console:** 
   - Press F12 or right-click → Inspect → Console tab
   - This shows the debug logs for the blocking logic

3. **Keep Supabase open** to verify database values if needed

---

## Test Cases

### ✅ TEST 1: Non-IT employee tries IT portal (SHOULD BLOCK)

**Steps:**
1. Go to: `http://localhost:8000/login/it` (or `/login`)
2. Enter: `nonithr@company.com`
3. Enter password: `password123`
4. Click "Sign In"

**Expected Result:**
- ❌ Error message appears: `"❌ Non-IT employees cannot use the IT portal! Please use the Non-IT login page."`
- 🛑 Page does NOT redirect to dashboard
- User stays on login page

**Console Output:**
```
🔑 IT Login - Checking company_type for: nonithr@company.com
🔍 Pre-login check - company_type: non-it
❌ BLOCKED: Non-IT employee trying to login on IT portal
```

---

### ✅ TEST 2: IT employee tries Non-IT portal (SHOULD BLOCK)

**Steps:**
1. Go to: `http://localhost:8000/login-non-it`
2. Enter: `giwore2911@dolofan.com` (or `hef8q@dollicons.com`)
3. Enter password: `password123`
4. Click "Sign In"

**Expected Result:**
- ❌ Error message appears: `"❌ IT employees cannot use the Non-IT portal! Please use the IT login page."`
- 🛑 Page does NOT redirect to dashboard
- User stays on login page

**Console Output:**
```
🔑 Non-IT Login - Checking company_type for: giwore2911@dolofan.com
🔍 Pre-login check - company_type: it
❌ BLOCKED: IT employee trying to login on Non-IT portal
```

---

### ✅ TEST 3: Non-IT employee on correct portal (SHOULD ALLOW)

**Steps:**
1. Go to: `http://localhost:8000/login-non-it`
2. Enter: `nonithr@company.com`
3. Enter password: `password123`
4. Click "Sign In"

**Expected Result:**
- ✅ Success message appears: `"Signed In Successfully!"`
- ✅ Page redirects to `/dashboard`
- ✅ Non-IT dashboard loads (with location tracking)

**Console Output:**
```
🔑 Non-IT Login - Checking company_type for: nonithr@company.com
🔍 Pre-login check - company_type: non-it
✅ Pre-check passed, proceeding with signin
```

---

### ✅ TEST 4: IT employee on correct portal (SHOULD ALLOW)

**Steps:**
1. Go to: `http://localhost:8000/login/it` (or `/login`)
2. Enter: `giwore2911@dolofan.com`
3. Enter password: `password123`
4. Click "Sign In"

**Expected Result:**
- ✅ Success message appears: `"Signed In Successfully!"`
- ✅ Page redirects to `/dashboard`
- ✅ IT dashboard loads

**Console Output:**
```
🔑 IT Login - Checking company_type for: giwore2911@dolofan.com
🔍 Pre-login check - company_type: it
✅ Pre-check passed, proceeding with signin
```

---

### ✅ TEST 5: Invalid credentials (SHOULD BLOCK AFTER pre-check passes)

**Steps:**
1. Go to: `http://localhost:8000/login/it`
2. Enter: `giwore2911@dolofan.com` (valid company_type)
3. Enter password: `wrong_password`
4. Click "Sign In"

**Expected Result:**
- ✅ Pre-check passes (company_type is correct)
- ❌ Sign in fails with: `"Invalid credentials."`
- 🛑 Page stays on login

**Console Output:**
```
🔑 IT Login - Checking company_type for: giwore2911@dolofan.com
🔍 Pre-login check - company_type: it
✅ Pre-check passed, proceeding with signin
❌ Sign in error: Invalid password
```

---

### ✅ TEST 6: Non-existent user (SHOULD BLOCK)

**Steps:**
1. Go to: `http://localhost:8000/login/it`
2. Enter: `nonexistent@company.com`
3. Enter password: `password123`
4. Click "Sign In"

**Expected Result:**
- ❌ Error message appears: `"User not found or database error. Please try again."`
- 🛑 Page stays on login

**Console Output:**
```
🔑 IT Login - Checking company_type for: nonexistent@company.com
User not found in database
```

---

## Troubleshooting

### If blocking is NOT working:

**Check 1: Database values**
```sql
-- Run in Supabase SQL Editor
SELECT email, company_type FROM users;
```

Expected:
- nonithr@company.com → 'non-it'
- giwore2911@dolofan.com → 'it' or NULL

**Check 2: Browser console for errors**
- Look for red errors in console
- Especially errors about `supabase` or query failures

**Check 3: Clear browser cache**
```
Press Ctrl+Shift+Delete to open cache clearing dialog
Clear cookies and cached files
Refresh the page
```

**Check 4: Verify Supabase connection**
Go to `/dashboard/admin/database` (if logged in as admin) to test Supabase connection

---

## Success Criteria

✅ All 6 tests pass:
- Tests 1-2: Blocking works correctly
- Tests 3-4: Valid logins work
- Tests 5-6: Error handling works

If all pass, **cross-portal blocking is COMPLETE** ✅

---

## Portal URLs Reference

| Portal | URL | For Users |
|--------|-----|-----------|
| IT Company | `/login` or `/login/it` | company_type = 'it' |
| Non-IT Company | `/login-non-it` | company_type = 'non-it' |
| Admin Approval | `/admin/approvals` | Admins only |

---

## After Testing

Once all tests pass:
1. Deploy to production
2. Inform users about correct portal for their role
3. Monitor first week for login issues
4. Keep console open during user testing for debugging
