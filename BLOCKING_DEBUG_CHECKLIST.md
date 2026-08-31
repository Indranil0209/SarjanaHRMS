# Cross-Portal Login Blocking - Debug Checklist

## Issue
Users report: "Non-IT can login from IT login page and vice versa" - blocking is not working

## Debug Steps (Execute in Order)

### STEP 1: Verify Database Values (Most Likely Root Cause)
**Why:** If company_type values are wrong, blocking won't work

Run in Supabase SQL Editor:
```sql
SELECT 
  id,
  email, 
  company_type, 
  is_active, 
  email_verified
FROM users 
ORDER BY email;
```

**Expected Results:**
```
nonitadmin@company.com        | non-it | true | true
nonitemployee1@company.com    | non-it | true | true
nonitemployee2@company.com    | non-it | true | true
nonitemployee3@company.com    | non-it | true | true
nonithr@company.com           | non-it | true | true
bashamohassin@gmail.com       | non-it | true | true
giwore2911@dolofan.com        | it     | true | true
hef8q@dollicons.com           | it     | true | true
zds0i@dollicons.com           | it     | true | true
```

**If Results Are Wrong:**
- Update company_type for all users using SQL below
- Commit changes
- Clear browser cache (Ctrl+Shift+Delete)
- Restart dev server (npm run dev)
- Try login again

---

### STEP 2: Fix Database Values (If Needed)

**Run this if company_type values are incorrect:**

```sql
-- Set all non-it users
UPDATE users SET company_type = 'non-it' 
WHERE email IN (
  'nonitadmin@company.com',
  'nonitemployee1@company.com',
  'nonitemployee2@company.com',
  'nonitemployee3@company.com',
  'nonithr@company.com',
  'bashamohassin@gmail.com'
);

-- Set all it users (or leave NULL - both work)
UPDATE users SET company_type = 'it' 
WHERE email IN (
  'giwore2911@dolofan.com',
  'hef8q@dollicons.com',
  'zds0i@dollicons.com'
);

-- Verify the update
SELECT email, company_type FROM users ORDER BY email;
```

---

### STEP 3: Test Blocking in Browser

**Test Case 1: Non-IT on IT Portal (SHOULD BLOCK)**
1. Open: `http://localhost:5173/login`
2. Email: `nonithr@company.com`
3. Password: `password123`
4. Click "Sign In"
5. Expected: ❌ Error message appears

**Check Console:**
- Press F12 → Console tab
- Look for: `🔍 Pre-login check - company_type: non-it`
- Look for: `❌ BLOCKED: Non-IT employee trying to login on IT portal`

---

**Test Case 2: IT on Non-IT Portal (SHOULD BLOCK)**
1. Open: `http://localhost:5173/login-non-it`
2. Email: `giwore2911@dolofan.com`
3. Password: `password123`
4. Click "Sign In"
5. Expected: ❌ Error message appears

**Check Console:**
- Look for: `🔍 Pre-login check - company_type: it`
- Look for: `❌ BLOCKED: IT employee trying to login on Non-IT portal`

---

**Test Case 3: Correct Portal (SHOULD ALLOW)**
1. Open: `http://localhost:5173/login-non-it`
2. Email: `nonithr@company.com`
3. Password: `password123`
4. Click "Sign In"
5. Expected: ✅ Redirects to dashboard

---

### STEP 4: If Blocking STILL Doesn't Work

**Add Console Debugging:**

In `src/pages/Login.tsx`, modify handleSubmit to add more logging:

```tsx
const handleSubmit = async (e: React.FormEvent) => {
  // ... existing code ...
  
  try {
    console.log('🔑 IT Login - Checking company_type for:', email);
    console.log('📊 Supabase client:', supabase); // Check if supabase is defined
    
    const { data: userCheckData, error: checkError } = await supabase
      .from('users')
      .select('company_type, email')
      .eq('email', email)
      .single();
    
    console.log('🔍 Supabase query result:');
    console.log('  Data:', userCheckData);
    console.log('  Error:', checkError);
    
    // ... rest of code ...
  }
};
```

**Then check console for:**
- Is supabase client defined? ✅
- Is query returning data? 
- What is company_type value?
- Are there any Supabase errors?

---

### STEP 5: Check Network Tab (Browser DevTools)

1. Open DevTools (F12)
2. Go to Network tab
3. Try to login (Test Case 1)
4. Look for requests to Supabase:
   - Should see a call to `rest/v1/users`
   - Status should be 200 (success)
   - Response should show company_type value

**If request fails (4xx, 5xx):**
- Check Supabase status
- Verify Supabase URL and API key in `src/lib/supabase.js`

---

### STEP 6: Check Supabase Connection

In browser console, run:
```javascript
// Import supabase first
import { supabase } from './lib/supabase'

// Test connection
const { data, error } = await supabase.from('users').select('email, company_type').limit(1)
console.log('Test query result:', data, error)
```

---

## Diagnosis Flowchart

```
Does blocking work? 
├─ YES → ✅ You're done! Blocking is working correctly
│
└─ NO → Check database values
   ├─ Database values correct? 
   │  ├─ NO → Run SQL fix (Step 2) → Restart dev server → Re-test
   │  │
   │  └─ YES → Check browser console logs
   │     ├─ See company_type in logs?
   │     │  ├─ NO → Add debugging (Step 4)
   │     │  │
   │     │  └─ YES → Check if error message shows
   │     │     ├─ NO → May be routing issue, check ProtectedRoute
   │     │     │
   │     │     └─ YES → ✅ Blocking is working!
   │     │
   │     └─ See Supabase errors?
   │        ├─ YES → Check network tab (Step 5)
   │        │
   │        └─ NO → Check Supabase connection (Step 6)
```

---

## Files to Check

If still stuck:
- `src/pages/Login.tsx` - Lines 32-57 (pre-check logic)
- `src/pages/LoginNonIT.tsx` - Lines 20-45 (pre-check logic)
- `src/lib/supabase.js` - Verify Supabase client is correctly initialized
- `src/context/AuthContext.jsx` - Lines 280-310 (signIn function)

---

## Success Criteria

✅ **Blocking is working when:**
1. ❌ Non-IT email on IT portal shows error message
2. ❌ IT email on Non-IT portal shows error message  
3. ✅ Non-IT email on Non-IT portal logs in
4. ✅ IT email on IT portal logs in
5. 🛑 Page never redirects on wrong portal
6. ✅ Error message appears BEFORE password is checked

