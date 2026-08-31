# Quick Start - Test Login Blocking Now

## In 5 Minutes

### Step 1: Start Dev Server (30 sec)
```bash
npm run dev
```
Wait for "Local: http://localhost:5173"

### Step 2: Open Two Browser Windows
- Window 1: `http://localhost:5173/login` (IT Portal)
- Window 2: `http://localhost:5173/login-non-it` (Non-IT Portal)

### Step 3: Open Console in Both
- Press **F12**
- Click **Console** tab
- Keep it open during testing

### Step 4: Run 4 Quick Tests (2 min)

#### Test 1: Non-IT on IT (Should Block ❌)
**Window 1:**
- Email: `nonithr@company.com`
- Password: `password123`
- Click Sign In
- ❓ Does error message appear?

#### Test 2: IT on Non-IT (Should Block ❌)
**Window 2:**
- Email: `giwore2911@dolofan.com`
- Password: `password123`
- Click Sign In
- ❓ Does error message appear?

#### Test 3: Non-IT Correct (Should Allow ✅)
**Window 2:**
- Email: `nonithr@company.com`
- Password: `password123`
- Click Sign In
- ❓ Does it redirect to dashboard?

#### Test 4: IT Correct (Should Allow ✅)
**Window 1:**
- Email: `giwore2911@dolofan.com`
- Password: `password123`
- Click Sign In
- ❓ Does it redirect to dashboard?

### Step 5: Report Results
```
Results:
Test 1 (Non-IT on IT):     ❓ PASS / FAIL
Test 2 (IT on Non-IT):     ❓ PASS / FAIL
Test 3 (Non-IT Correct):   ❓ PASS / FAIL
Test 4 (IT Correct):       ❓ PASS / FAIL
```

---

## What to Look For in Console

### ✅ If Blocking Works

You should see:
```
🔑 IT Login - Checking company_type for: nonithr@company.com
📊 Supabase client: ✓ Connected
🔍 Pre-login query result: {...}
❌ BLOCKED: Non-IT employee trying to login on IT portal
```

And on page: Red error message

### ❌ If Blocking Fails

You might see:
```
🔑 IT Login - Checking company_type for: nonithr@company.com
📊 Supabase client: ✗ Not connected
```
Or:
```
🔍 Pre-login check - company_type: it (WRONG!)
✅ Pre-check passed, proceeding with signin
```

---

## If Test 1 or 2 Fail (Blocking Doesn't Work)

### Check 1: Database Values (1 min)
Go to Supabase → SQL Editor → Run:
```sql
SELECT email, company_type FROM users ORDER BY email;
```

Look for:
```
nonithr@company.com           | non-it  ✅
giwore2911@dolofan.com        | it      ✅
```

If values are wrong (it=it, non-it=it), that's the problem.

### Check 2: Fix Database (1 min)
Go to Supabase → SQL Editor → Run:
```sql
UPDATE users SET company_type = 'non-it' WHERE email = 'nonithr@company.com';
UPDATE users SET company_type = 'it' WHERE email = 'giwore2911@dolofan.com';
```

Then:
1. Close dev server (Ctrl+C)
2. Clear browser cache (Ctrl+Shift+Delete)
3. Restart dev server (`npm run dev`)
4. Re-run tests

---

## If All Tests Pass ✅

**Great!** Blocking is working. Mark Task 4 as complete.

---

## If Some Tests Still Fail

Refer to full guide: **LOGIN_BLOCKING_ENHANCED_DEBUG.md**

Key sections:
- "Troubleshooting Guide" - Detailed debugging
- "Console Should Show" - Expected outputs
- "Diagnostic Checklist" - Step by step

---

## Demo Credentials Reference

### IT Portal (`/login`)
```
giwore2911@dolofan.com  / password123   (Super Admin)
hef8q@dollicons.com     / password123   (HR Manager)
zds0i@dollicons.com     / password123   (Employee)
```

### Non-IT Portal (`/login-non-it`)
```
nonitadmin@company.com      / password123  (Super Admin)
nonithr@company.com         / password123  (HR Manager)
nonitemployee1@company.com  / password123  (Employee)
```

---

## Success = All 4 Tests Pass ✅

```
Test 1: Non-IT email blocked on IT portal     ✅
Test 2: IT email blocked on Non-IT portal     ✅
Test 3: Non-IT can login on Non-IT portal     ✅
Test 4: IT can login on IT portal             ✅
```

When complete, the cross-portal blocking task is done! 🎉

