# 🔐 Login Flow Guide

## User Journey

### Starting Point: `/login`

When a user navigates to `/login`, they see the **LoginSelector Page**:

```
┌────────────────────────────────────────────────────────────┐
│                                                            │
│                      SarjanaHRMS                          │
│              Choose your login type to continue            │
│                                                            │
│  ┌──────────────────┐      ┌──────────────────┐          │
│  │  💼 IT Company   │      │ 🏢 Non-IT Company│          │
│  │                  │      │                  │          │
│  │ Login to your IT │      │ Login to Non-IT  │          │
│  │ company dashboard│      │ company dashboard│          │
│  │                  │      │                  │          │
│  │ Demo Creds:      │      │ Demo Creds:      │          │
│  │ Email: ...       │      │ Email: ...       │          │
│  │ Pass: ****       │      │ Pass: ****       │          │
│  │                  │      │                  │          │
│  │  Continue →      │      │  Continue →      │          │
│  └──────────────────┘      └──────────────────┘          │
│                                                            │
│    Need to create an account? Sign up here               │
└────────────────────────────────────────────────────────────┘
```

---

## Route Mapping

### Scenario 1: User Clicks "IT Company"
```
User at /login
    ↓
Sees LoginSelector
    ↓
Clicks "IT Company" card (blue)
    ↓
Navigates to → /login/it
    ↓
Sees IT Company Login Form
    ↓
Enters credentials:
  • Email: giwore2911@dolofan.com
  • Password: password123
    ↓
Logs in successfully
    ↓
Redirected to → /dashboard
    ↓
Shows EmployeeDashboard (if IT employee)
       or HRDashboard (if IT HR)
       or CompanyDashboard (if Admin)
```

---

### Scenario 2: User Clicks "Non-IT Company"
```
User at /login
    ↓
Sees LoginSelector
    ↓
Clicks "Non-IT Company" card (purple)
    ↓
Navigates to → /login-non-it
    ↓
Sees Non-IT Company Login Form
    ↓
Enters credentials:
  • Email: nonithr@company.com
  • Password: password123
    ↓
Logs in successfully
    ↓
Redirected to → /dashboard
    ↓
Shows NonITEmployeeDashboard (if Non-IT employee)
       or NonITHRDashboard (if Non-IT HR)
       or CompanyDashboard (if Admin)
```

---

### Scenario 3: Direct Links (Bypass Selector)
Users can bypass the LoginSelector and go directly to login pages:

```
/login/it          → Go directly to IT login form
/login-non-it      → Go directly to Non-IT login form
```

---

## Route Table

| Path | Component | Purpose |
|------|-----------|---------|
| `/login` | LoginSelector | Choose company type |
| `/login/it` | Login | IT company login form |
| `/login-non-it` | LoginNonIT | Non-IT company login form |
| `/dashboard` | Dashboard (router) | Route to correct dashboard based on role |

---

## Dashboard Router Logic (in `/dashboard`)

After login, the Dashboard page determines which dashboard to show:

```
/dashboard
    ↓
Check user.companyType & profile.role
    ├─ companyType='IT' && role='employee' → EmployeeDashboard
    ├─ companyType='IT' && role='hr' → HRDashboard  
    ├─ companyType='non-it' && role='employee' → NonITEmployeeDashboard
    ├─ companyType='non-it' && role='hr' → NonITHRDashboard
    └─ role='admin' or 'super_admin' → CompanyDashboard
```

---

## Visual Design

### LoginSelector Page Features

✨ **Animations:**
- Smooth hover scale effect (cards grow slightly)
- Gradient glow effect on hover
- Smooth transitions for all interactive elements
- Animated blob background elements

🎨 **Theming:**
- Light mode: Blue/purple gradient with white cards
- Dark mode: Slate gradient with dark cards
- Theme switching preserves user preference

📱 **Responsive:**
- Mobile: Single column stack
- Tablet: Two columns
- Desktop: Two columns side by side

---

## Demo Credentials

### IT Company
```
Email:    giwore2911@dolofan.com
Password: password123
```

### Non-IT Company
```
Email:    nonithr@company.com
Password: password123
```

---

## Feature Highlights

✅ **Beautiful UI** - Gradient backgrounds, smooth animations
✅ **Mobile Friendly** - Responsive design works on all devices
✅ **Dark/Light Mode** - Full theme support
✅ **Clear Messaging** - Descriptions for each option
✅ **Easy Navigation** - One click to choose company type
✅ **Signup Link** - Quick access to sign up page
✅ **Demo Credentials** - Visible on selector for quick testing

---

## Testing Instructions

1. **Start Dev Server:**
   ```bash
   npm run dev
   ```

2. **Navigate to Login:**
   - Go to `http://localhost:5173/login`

3. **You should see:**
   - LoginSelector page with two options
   - Beautiful gradient background
   - Animated blob effects
   - Two clickable cards with demo credentials

4. **Test IT Company:**
   - Click "IT Company" card
   - Should navigate to `/login/it`
   - You can then login or go back

5. **Test Non-IT Company:**
   - Click "Non-IT Company" card
   - Should navigate to `/login-non-it`
   - You can then login or go back

6. **Test Direct Links:**
   - Try `/login/it` directly
   - Try `/login-non-it` directly
   - Both should work

7. **Test Theme Toggle:**
   - Toggle dark/light mode
   - LoginSelector should adapt colors

---

## Troubleshooting

### Issue: LoginSelector not showing
**Solution:** Check browser console for errors, ensure build succeeded

### Issue: Navigation not working
**Solution:** Verify react-router-dom is installed, check App.tsx routes

### Issue: Styling looks wrong
**Solution:** Clear browser cache, run `npm run build` again

### Issue: Theme not switching
**Solution:** Check ThemeContext is working, verify theme toggle button

---

## Files Involved

- `src/pages/LoginSelector.tsx` - The selector component
- `src/pages/Login.tsx` - IT company login
- `src/pages/LoginNonIT.tsx` - Non-IT company login
- `src/App.tsx` - Route definitions
- `src/context/ThemeContext.tsx` - Theme support

---

✅ **LoginSelector Implementation Complete!**
