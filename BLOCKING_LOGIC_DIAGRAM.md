# Cross-Portal Login Blocking - Visual Logic Diagram

## System Architecture

```
┌─────────────────────────────────────────────────────────────────┐
│                      USER LOGIN FLOW                             │
└─────────────────────────────────────────────────────────────────┘

                    ┌──────────────────────┐
                    │  User Visits URL     │
                    └──────────┬───────────┘
                               │
                ┌──────────────┴──────────────┐
                │                             │
        ┌───────▼────────┐          ┌────────▼────────┐
        │  /login (IT)   │          │  /login-non-it  │
        │  or /login/it  │          │   (Non-IT)      │
        └───────┬────────┘          └────────┬────────┘
                │                            │
     ┌──────────▼────────────┐    ┌─────────▼──────────────┐
     │  Login.tsx Component  │    │  LoginNonIT.tsx        │
     │  (IT Portal)          │    │  (Non-IT Portal)       │
     └──────────┬────────────┘    └─────────┬──────────────┘
                │                            │
                │ User enters email/password │
                │ and clicks Sign In         │
                │                            │
        ┌───────▼────────────────────────────▼────────┐
        │  STEP 1: Pre-Check Company Type (NEW)       │
        │  ════════════════════════════════════════   │
        │  Query Supabase:                            │
        │  SELECT company_type FROM users             │
        │  WHERE email = user@company.com             │
        └───────┬────────────────────────────┬────────┘
                │                            │
    ┌───────────▼─────────┐      ┌──────────▼──────────┐
    │ IT Portal Check:    │      │ Non-IT Portal Check:│
    │ ═══════════════════ │      │ ════════════════════│
    │ Is company_type ==  │      │ Is company_type ==  │
    │ 'non-it' ?          │      │ 'it' or NULL ?      │
    │                     │      │                     │
    │ YES → BLOCK ❌      │      │ YES → BLOCK ❌      │
    │ NO  → CONTINUE ✅   │      │ NO  → CONTINUE ✅   │
    └───────┬─────────────┘      └──────────┬──────────┘
            │                               │
        ┌───▼──────────────────────────────▼────┐
        │ STEP 2: Attempt signIn()               │
        │ (Password verification with Supabase) │
        │ ≈≈≈≈≈≈≈≈≈≈≈≈≈≈≈≈≈≈≈≈≈≈≈≈≈≈≈≈≈≈≈≈ │
        │ Try auth.signInWithPassword()          │
        └───┬──────────────────────────────┬────┘
            │                              │
    ┌───────▼──────┐          ┌───────────▼──────┐
    │ Credentials  │          │  Invalid          │
    │ Valid ✅     │          │  Credentials ❌   │
    └───────┬──────┘          └───────────┬──────┘
            │                             │
    ┌───────▼──────────────┐    ┌────────▼─────────────┐
    │ Success! 🎉          │    │ Show Error Message   │
    │ Set user state       │    │ "Invalid credentials"│
    │ Redirect to          │    │ Stay on login page   │
    │ /dashboard           │    └──────────────────────┘
    └──────────────────────┘

```

---

## Decision Tree

```
START: User submits login form
  │
  └─→ [PRE-CHECK] Query company_type from database
      │
      ├─→ ERROR: User not found in database
      │   └─→ Show "User not found or database error"
      │       └─→ STOP: User cannot proceed
      │
      └─→ SUCCESS: User found with company_type value
          │
          ├─→ FOR IT PORTAL (/login):
          │   │
          │   ├─→ company_type == 'non-it'
          │   │   └─→ ❌ BLOCKED: "Non-IT employees cannot use IT portal"
          │   │       └─→ STOP: User cannot proceed
          │   │
          │   ├─→ company_type == 'it'
          │   │   └─→ ✅ PASSED: Proceed to password check
          │   │
          │   └─→ company_type == NULL or undefined
          │       └─→ ✅ PASSED: Default to IT, proceed to password check
          │
          └─→ FOR NON-IT PORTAL (/login-non-it):
              │
              ├─→ company_type == 'it'
              │   └─→ ❌ BLOCKED: "IT employees cannot use Non-IT portal"
              │       └─→ STOP: User cannot proceed
              │
              ├─→ company_type == NULL or undefined
              │   └─→ ❌ BLOCKED: Default to IT, cannot use Non-IT portal
              │       └─→ STOP: User cannot proceed
              │
              └─→ company_type == 'non-it'
                  └─→ ✅ PASSED: Proceed to password check
```

---

## Database Values

```
┌─────────────────────────────────────────────────────────────┐
│                   USERS TABLE                               │
├─────────────────────────────────────────────────────────────┤
│ id  │ email                      │ company_type │ can access│
├─────────────────────────────────────────────────────────────┤
│ 1   │ giwore2911@dolofan.com     │ 'it'        │ /login    │
│ 2   │ hef8q@dollicons.com        │ 'it'        │ /login    │
│ 3   │ zds0i@dollicons.com        │ 'it'        │ /login    │
│ 4   │ nonithr@company.com        │ 'non-it'    │ /login-.. │
│ 5   │ nonitemployee1@company.com │ 'non-it'    │ /login-.. │
│ 6   │ nonitemployee2@company.com │ 'non-it'    │ /login-.. │
│ 7   │ nonitemployee3@company.com │ 'non-it'    │ /login-.. │
│ 8   │ nonitadmin@company.com     │ 'non-it'    │ /login-.. │
│ 9   │ bashamohassin@gmail.com    │ 'non-it'    │ /login-.. │
└─────────────────────────────────────────────────────────────┘

Legend:
- /login = IT portal (company_type = 'it' or NULL)
- /login-.. = /login-non-it (company_type = 'non-it')
```

---

## Error Messages

```
┌─────────────────────────────────────────────────────┐
│              ERROR SCENARIOS                        │
├─────────────────────────────────────────────────────┤
│                                                     │
│ SCENARIO 1: Non-IT on IT Portal                    │
│ ─────────────────────────────────                  │
│ URL: /login                                         │
│ Email: nonithr@company.com (company_type='non-it') │
│ Error: ❌ Non-IT employees cannot use the IT       │
│        portal! Please use the Non-IT login page.   │
│                                                     │
│ SCENARIO 2: IT on Non-IT Portal                    │
│ ─────────────────────────────────                  │
│ URL: /login-non-it                                 │
│ Email: giwore2911@dolofan.com (company_type='it')  │
│ Error: ❌ IT employees cannot use the Non-IT       │
│        portal! Please use the IT login page.       │
│                                                     │
│ SCENARIO 3: User Not Found                         │
│ ─────────────────────────────────                  │
│ URL: /login                                         │
│ Email: ghost@company.com (not in database)         │
│ Error: User not found or database error.           │
│        Please try again.                           │
│                                                     │
└─────────────────────────────────────────────────────┘
```

---

## Code Execution Timeline

```
TIME    LOCATION              ACTION
────────────────────────────────────────────────────────
  1     User Browser          User enters email/password
  2     Browser              User clicks "Sign In" button
  3     Login.tsx             handleSubmit() triggered
  4     Login.tsx             Pre-check starts
  5     Supabase             Query: SELECT company_type...
  6     Supabase DB          Database lookup
  7     Supabase             Returns company_type value
  8     Login.tsx             Evaluate company_type
  9     Login.tsx             Decision: Block or Continue
  │
  ├─→ IF BLOCK:
  │   10    Login.tsx             Set error state
  │   11    Login.tsx             setLoading(false)
  │   12    Login.tsx             return (stop execution)
  │   13    Browser              User sees error message
  │   
  └─→ IF CONTINUE:
      10    Login.tsx             Call signIn(email, password)
      11    Supabase Auth         Authenticate password
      12    Supabase             Returns auth result
      13    Login.tsx             Handle success/error
      14    Browser              Redirect or show error
```

---

## Files Involved

```
┌─────────────────────────────────────────┐
│          FILES & THEIR ROLES            │
├─────────────────────────────────────────┤
│                                         │
│ src/pages/Login.tsx                    │
│ ├─ IT Portal Login Page                │
│ ├─ Contains: Pre-check for 'non-it'    │
│ └─ Blocks non-IT employees             │
│                                         │
│ src/pages/LoginNonIT.tsx               │
│ ├─ Non-IT Portal Login Page            │
│ ├─ Contains: Pre-check for 'it'/null   │
│ └─ Blocks IT employees                 │
│                                         │
│ src/lib/supabase.js                    │
│ ├─ Supabase client config              │
│ └─ Used by both login pages            │
│                                         │
│ src/context/AuthContext.jsx            │
│ ├─ SignIn function                     │
│ ├─ Called AFTER pre-check passes       │
│ └─ Does password verification          │
│                                         │
│ Supabase Database (users table)        │
│ ├─ Stores company_type value           │
│ └─ Queried during pre-check            │
│                                         │
└─────────────────────────────────────────┘
```

---

## Summary of How Blocking Works

1. **User visits `/login` or `/login-non-it`**
2. **User enters credentials and submits**
3. **[NEW] Pre-check queries database** ← THIS BLOCKS CROSS-PORTAL LOGIN
   - Gets the user's `company_type` value
   - Validates it matches the current portal
   - If mismatch → Error + Stop
   - If match → Continue
4. **[Existing] SignIn attempts password verification**
   - Only runs if pre-check passes
   - Blocks invalid credentials normally

**Key Difference:** Pre-check happens BEFORE password is ever sent to Supabase Auth!

This prevents accidental/intentional cross-portal access at the earliest possible point.

---

## Testing the Blocking

See `TESTING_LOGIN_BLOCKING.md` for 6 complete test cases with expected results.
