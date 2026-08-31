# Cross-Portal Login Blocking - Changes Summary

## Files Modified

### 1. `src/pages/Login.tsx` (IT Portal)

#### Change 1: Added Supabase Import
```typescript
// BEFORE:
import { useAuth } from '../context/AuthContext';

// AFTER:
import { useAuth } from '../context/AuthContext';
import { supabase } from '../lib/supabase';
```

#### Change 2: Updated handleSubmit Function
```typescript
// BEFORE: Direct signin without pre-check
const handleSubmit = async (e: React.FormEvent) => {
  e.preventDefault();
  setLoading(true);
  setStatus('idle');
  setErrorMessage('');

  const email = formData.email.trim().toLowerCase();
  const password = formData.password;

  try {
    const { error } = await signIn(email, password);
    // ... error handling
  } catch (err: any) {
    // ... catch handling
  } finally {
    setLoading(false);
  }
};

// AFTER: Pre-check for company_type BEFORE signin
const handleSubmit = async (e: React.FormEvent) => {
  e.preventDefault();
  setLoading(true);
  setStatus('idle');
  setErrorMessage('');

  const email = formData.email.trim().toLowerCase();
  const password = formData.password;

  try {
    // NEW: Pre-check company_type
    console.log('🔑 IT Login - Checking company_type for:', email);
    
    const { data: userCheckData, error: checkError } = await supabase
      .from('users')
      .select('company_type, email')
      .eq('email', email)
      .single();
    
    if (checkError) {
      console.warn('User not found in database:', checkError);
      setStatus('error');
      setErrorMessage('User not found or database error. Please try again.');
      setLoading(false);
      return;
    }

    const userCompanyType = userCheckData?.company_type;
    console.log('🔍 Pre-login check - company_type:', userCompanyType);

    // NEW: Block non-IT employees
    if (userCompanyType === 'non-it') {
      console.error('❌ BLOCKED: Non-IT employee trying to login on IT portal');
      setStatus('error');
      setErrorMessage('❌ Non-IT employees cannot use the IT portal! Please use the Non-IT login page.');
      setLoading(false);
      return;
    }

    console.log('✅ Pre-check passed, proceeding with signin');
    const { error } = await signIn(email, password);
    
    // ... rest of error handling
  } catch (err: any) {
    // ... catch handling
  } finally {
    setLoading(false);
  }
};
```

---

### 2. `src/pages/LoginNonIT.tsx` (Non-IT Portal)

#### Change 1: Added Supabase Import
```typescript
// BEFORE:
import { AlertCircle, Eye, EyeOff, MapPin } from 'lucide-react';

// AFTER:
import { AlertCircle, Eye, EyeOff, MapPin } from 'lucide-react';
import { supabase } from '../lib/supabase';
```

#### Change 2: Updated handleSubmit Function
```typescript
// BEFORE: Direct signin without pre-check
const handleSubmit = async (e: React.FormEvent) => {
  e.preventDefault();
  setError('');
  setLoading(true);

  try {
    await signIn(email, password);
    navigate('/dashboard');
  } catch (err: any) {
    setError(err.message || 'Failed to sign in. Please check your credentials.');
  } finally {
    setLoading(false);
  }
};

// AFTER: Pre-check for company_type BEFORE signin
const handleSubmit = async (e: React.FormEvent) => {
  e.preventDefault();
  setError('');
  setLoading(true);

  try {
    // NEW: Pre-check company_type
    console.log('🔑 Non-IT Login - Checking company_type for:', email);
    
    const { data: userCheckData, error: checkError } = await supabase
      .from('users')
      .select('company_type, email')
      .eq('email', email.toLowerCase())
      .single();
    
    if (checkError) {
      console.warn('User not found in database:', checkError);
      setError('User not found or database error. Please try again.');
      setLoading(false);
      return;
    }

    const userCompanyType = userCheckData?.company_type;
    console.log('🔍 Pre-login check - company_type:', userCompanyType);

    // NEW: Block IT employees (default is IT)
    if (userCompanyType === 'it' || userCompanyType === null || userCompanyType === undefined) {
      console.error('❌ BLOCKED: IT employee trying to login on Non-IT portal');
      setError('❌ IT employees cannot use the Non-IT portal! Please use the IT login page.');
      setLoading(false);
      return;
    }

    console.log('✅ Pre-check passed, proceeding with signin');
    await signIn(email, password);
    navigate('/dashboard');
  } catch (err: any) {
    setError(err.message || 'Failed to sign in. Please check your credentials.');
  } finally {
    setLoading(false);
  }
};
```

---

## Logic Flow

### IT Portal (`/login`) - Login.tsx
```
User submits form
    ↓
Query DB: SELECT company_type FROM users WHERE email = ?
    ↓
Is company_type === 'non-it' ?
    ├─ YES → BLOCK with error message
    │
    └─ NO → Allow signin (company_type is 'it' or NULL/undefined)
```

### Non-IT Portal (`/login-non-it`) - LoginNonIT.tsx
```
User submits form
    ↓
Query DB: SELECT company_type FROM users WHERE email = ?
    ↓
Is company_type === 'it' OR NULL/undefined ?
    ├─ YES → BLOCK with error message
    │
    └─ NO → Allow signin (company_type is 'non-it')
```

---

## Key Points

1. **Pre-check happens BEFORE signin** - User cannot proceed to password verification if company_type doesn't match
2. **Database query is direct** - Uses Supabase to query users table without going through AuthContext
3. **Error messages are clear** - Users know which portal to use
4. **Console logging included** - For debugging in production
5. **Null/undefined defaults to IT** - If company_type is not set, user defaults to IT portal

---

## Build Result
✅ **Success** - 0 errors, 17.74s build time

---

## Files NOT Modified

- `src/context/AuthContext.jsx` - SignIn logic unchanged
- `src/components/auth/Login.jsx` - Old component (not used by current routing)
- `src/pages/Dashboard.jsx` - Dashboard routing unchanged
- `.env` - Environment variables unchanged
- Database schema - No changes needed to existing company_type column

---

## Next: Database Verification

Before testing, verify all users have correct `company_type` values:

```sql
SELECT email, company_type FROM users ORDER BY email;
```

Update if needed (see VERIFY_COMPANY_TYPE.sql for full script)
