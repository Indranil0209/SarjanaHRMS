# 🔧 IT Company Login Troubleshooting Guide

## Issue: IT Company Login Not Working

### STEP 1: Check Browser Console for Errors ⚠️

1. **Open the IT login page:** `http://localhost:5173/login/it`
2. **Press F12** to open Developer Tools
3. **Click "Console" tab**
4. **Look for red error messages** - Take note of them

Common errors:

#### Error A: "Invalid login credentials"
```
Message: Invalid login credentials
Cause: User doesn't exist in Supabase OR password is wrong
Solution: 
  - Check if demo user exists in Supabase
  - Verify credentials are correct
  - Ask Debdip to create the demo user
```

#### Error B: "Network error" or "Failed to fetch"
```
Message: Failed to fetch / Connection refused
Cause: Supabase is not reachable / Internet issue
Solution:
  - Check internet connection
  - Verify Supabase URL is correct
  - Check if Supabase project is active
```

#### Error C: "TypeError: signIn is not a function"
```
Message: signIn is not a function
Cause: AuthContext not properly initialized
Solution:
  - Verify App.tsx has AuthProvider
  - Restart dev server: npm run dev
```

#### Error D: "CORS error" or "Blocked by CORS"
```
Message: Access to XMLHttpRequest has been blocked by CORS
Cause: Supabase CORS settings
Solution:
  - Check Supabase project settings
  - Ensure localhost:5173 is in CORS whitelist
```

---

### STEP 2: Verify Demo User Exists in Supabase

1. **Go to Supabase Dashboard**
   - URL: https://supabase.com/dashboard

2. **Login to your project**

3. **Navigate to: Database → Users Table**

4. **Check if this user exists:**
   ```
   Email: giwore2911@dolofan.com
   Password: password123
   ```

5. **If user doesn't exist:**
   - Click "+" to add new row
   - Email: `giwore2911@dolofan.com`
   - Password: hash with bcrypt or use Supabase auth
   - Role: `super_admin` or `admin`
   - is_active: `true`
   - email_verified: `true`

---

### STEP 3: Check Network Tab

1. **Press F12** to open DevTools
2. **Click "Network" tab**
3. **Refresh the page**
4. **Look for API calls to Supabase:**
   - Should see requests to `supabase.co`
   - Should have status 200 or 201

**If no Supabase requests appear:**
- Supabase client is not initialized
- Check `src/lib/supabase.js` configuration

**If requests show 401/403 errors:**
- Authentication failed
- Check API keys in `.env` file

---

### STEP 4: Verify Environment Variables

1. **Check `.env` file exists:**
   ```
   c:\Users\...\SarjanaHRMS-main\SarjanaHRMS-main\SarjanaHRMS-main\.env
   ```

2. **File should contain:**
   ```
   VITE_SUPABASE_URL=https://ykcpdolezschqwcueuil.supabase.co
   VITE_SUPABASE_ANON_KEY=eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...
   ```

3. **If missing:**
   - Copy from `.env.example`
   - Fill in actual Supabase credentials

4. **After changes:**
   - Stop dev server: Press Ctrl+C
   - Run: `npm run dev`

---

### STEP 5: Test Supabase Connection

Run this in browser console to test Supabase:

```javascript
// Open browser console and paste this:
import { supabase } from './src/lib/supabase'

// Test connection
const { data, error } = await supabase.from('users').select('*').limit(1)
console.log('Data:', data)
console.log('Error:', error)
```

**Expected result:**
- Data should show user records
- Error should be null

**If error:**
- Check API URL
- Check API key
- Check Supabase is online

---

### STEP 6: Verify AuthContext is Working

1. **Check `src/App.tsx` has AuthProvider:**
   ```tsx
   <AuthProvider>
     <Routes>
       {/* routes */}
     </Routes>
   </AuthProvider>
   ```

2. **Check AuthContext.jsx signIn function:**
   ```javascript
   const signIn = async (emailOrEmpId, password) => {
     // Should have this function
   }
   ```

3. **Restart dev server:**
   ```bash
   npm run dev
   ```

---

### STEP 7: Test with Correct Credentials

**Demo Credentials:**
```
Email: giwore2911@dolofan.com
Password: password123
```

**Testing steps:**
1. Navigate to `/login/it`
2. Enter email exactly as shown
3. Enter password exactly as shown
4. Click "Sign In"
5. Watch console for errors

**Common mistakes:**
- Extra spaces in email
- Different capitalization
- Wrong password
- User doesn't exist yet

---

### STEP 8: Check If User Needs to be Created

If you get error: **"Invalid login credentials"**

The user probably doesn't exist. You need to:

1. **Create user in Supabase Auth:**
   - Go to Supabase Dashboard
   - Authentication → Users
   - Click "Add User"
   - Email: `giwore2911@dolofan.com`
   - Password: `password123`
   - Confirm password

2. **Add user profile in Users table:**
   - Go to Database → Users table
   - Add new row:
     ```
     id: (auto-generated from auth)
     email: giwore2911@dolofan.com
     full_name: Demo User
     role: super_admin
     company_id: (your company id)
     is_active: true
     email_verified: true
     company_type: it
     ```

3. **Try login again**

---

### STEP 9: Debug Login Function

Add this to `src/pages/Login.tsx` to see what's happening:

After line 30 (after `const { signIn } = useAuth()...`), add:

```javascript
console.log('signIn function:', signIn)
console.log('Auth context loaded:', signIn ? 'YES' : 'NO')
```

**Expected output in console:**
```
signIn function: ƒ (emailOrEmpId, password)
Auth context loaded: YES
```

**If "NO":**
- AuthContext not working
- Check App.tsx AuthProvider
- Restart dev server

---

### STEP 10: Test with Alternative User

If demo user doesn't work, try creating a test user:

1. **Go to Supabase Dashboard**
2. **Auth → Users**
3. **Click "Add User"**
4. **Email:** `test@example.com`
5. **Password:** `test123456`
6. **Confirm and create**

Then at login page:
- Email: `test@example.com`
- Password: `test123456`

If this works → original demo user needs to be created in Supabase

---

## Quick Diagnosis Checklist

- [ ] Browser console shows no red errors
- [ ] Supabase requests appear in Network tab with 200 status
- [ ] `.env` file has Supabase credentials
- [ ] Demo user exists in Supabase Auth
- [ ] Demo user profile exists in Users table
- [ ] AuthProvider is in App.tsx
- [ ] signIn function is available from useAuth()
- [ ] Internet connection is working
- [ ] Dev server is running (`npm run dev`)
- [ ] URL is exactly `http://localhost:5173/login/it`

---

## Still Not Working?

1. **Check the error message from Step 1**
2. **Share exact error with the team**
3. **Check these files:**
   - `src/App.tsx` - AuthProvider present?
   - `src/context/AuthContext.jsx` - signIn function exists?
   - `src/lib/supabase.js` - URL and key correct?
   - `.env` - Credentials filled?

4. **Try these:**
   - Restart dev server: `npm run dev`
   - Clear browser cache: Ctrl+Shift+Delete
   - Create demo user in Supabase manually
   - Check Supabase project is active

---

## Contact Support

If still stuck:
1. Take screenshot of error from console
2. Share `.env` file (without sensitive data)
3. Confirm Supabase project is accessible
4. Verify demo user exists in Supabase

**Most likely cause:** Demo user doesn't exist in Supabase yet - Debdip needs to create it!
