# Non-IT Portal - Quick Start Guide

## ⚡ 30-Second Setup

### 1. Run SQL File
```bash
psql -U postgres -d hrms_db -f non_it_demo_credentials.sql
```

### 2. Start Server
```bash
npm run dev
```

### 3. Visit Portal
```
http://localhost:5173/login-non-it
```

### 4. Login
- Email: `nonitadmin@company.com`
- Password: `password123`

---

## 🔐 All Non-IT Demo Credentials

```
┌─────────────────────────────────────────────────────┐
│              NON-IT PORTAL CREDENTIALS              │
├──────────────┬─────────────────────────┬────────────┤
│     Role     │         Email           │  Password  │
├──────────────┼─────────────────────────┼────────────┤
│ Super Admin  │ nonitadmin@company.com  │ password123│
│ HR Manager   │ nonithr@company.com     │ password123│
│ Employee 1   │ nonitemployee1@co.com   │ password123│
│ Employee 2   │ nonitemployee2@co.com   │ password123│
│ Employee 3   │ nonitemployee3@co.com   │ password123│
└──────────────┴─────────────────────────┴────────────┘
```

---

## 📱 Portal URLs

| Portal | URL |
|--------|-----|
| **Non-IT Login** | `http://localhost:5173/login-non-it` |
| **IT Login** | `http://localhost:5173/login` |
| **Dashboard** | `http://localhost:5173/dashboard` |
| **Non-IT Signup** | `http://localhost:5173/nonit/signup` |

---

## 👥 User Roles & Access

### Super Admin
- ✓ Full system access
- ✓ Company settings
- ✓ User management
- ✓ All employee data
- ✓ Payroll authority

### HR Manager
- ✓ Employee management
- ✓ Leave approvals
- ✓ Payroll processing
- ✓ Location tracking view
- ✓ Attendance management

### Employee
- ✓ Personal dashboard
- ✓ Apply leave
- ✓ View payslip
- ✓ Auto location tracking
- ✓ Team directory

---

## 🏢 Company Info

| Field | Value |
|-------|-------|
| **Company** | Non-IT Services Company |
| **Industry** | Retail & Services |
| **Employees** | 5 (1 Super Admin + 1 HR + 3 Employees) |
| **Departments** | 4 (Retail, HR, Sales, Finance) |
| **Currency** | INR |
| **Timezone** | Asia/Kolkata |

---

## 📊 Database Info

**Bcrypt Password Hash:**
```
$2a$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi
```

**Company ID:**
```
c550e8400-e29b-41d4-a716-446655440001
```

---

## ✨ Key Features (Non-IT Portal)

- ✓ Real-time Location Tracking
- ✓ Live Employee Location View
- ✓ Location History
- ✓ Geofencing
- ✓ Attendance from GPS
- ✓ Leave Management
- ✓ Payroll Processing
- ✓ Performance Reviews
- ✓ Team Directory
- ✓ Dark Mode

---

## 🧪 Quick Test Flow

### Super Admin Testing
```
1. Go to http://localhost:5173/login-non-it
2. Enter: nonitadmin@company.com / password123
3. Allow location permission
4. Click "Sign In"
5. Verify dashboard loads
6. Check Admin features available
```

### Employee Testing
```
1. Go to http://localhost:5173/login-non-it
2. Enter: nonitemployee1@company.com / password123
3. Allow location permission
4. Click "Sign In"
5. Verify location tracking active
6. Check employee dashboard features
```

---

## 🆘 Troubleshooting

### Login Failed?
```sql
-- Check if user exists
SELECT * FROM users WHERE email = 'nonitadmin@company.com';

-- Check if company is active
SELECT * FROM companies WHERE id = 'c550e8400-e29b-41d4-a716-446655440001';
```

### No Employees Showing?
```sql
-- Check employees table
SELECT * FROM employees WHERE company_id = 'c550e8400-e29b-41d4-a716-446655440001';
```

### Location Tracking Not Working?
1. Check browser location permissions
2. Verify GPS/location services enabled on device
3. Check company settings: `SELECT settings FROM companies WHERE id = 'c550e8400-e29b-41d4-a716-446655440001';`

---

## 📁 Files Created/Modified

### New Files
- ✅ `non_it_demo_credentials.sql` - Demo data
- ✅ `NON_IT_DEMO_CREDENTIALS.md` - Full documentation
- ✅ `NON_IT_SETUP_SUMMARY.md` - Setup guide
- ✅ `LOGIN_PORTALS_GUIDE.md` - Portal comparison
- ✅ `QUICK_START_NON_IT.md` - This file

### Modified Files
- ✅ `src/pages/LoginNonIT.tsx` - Updated demo credentials display

### Existing Files (Already Configured)
- ✅ `src/App.tsx` - Routes already configured
- ✅ `src/context/AuthContext.tsx` - Auth handling

---

## 🎯 Next Steps

1. **Execute SQL** → Run the non_it_demo_credentials.sql file
2. **Test Login** → Verify credentials work
3. **Test Features** → Try each role's features
4. **Add More Users** → Use SQL as template
5. **Customize** → Adjust for your needs

---

## 💡 Pro Tips

### Change Password
```sql
-- Generate new bcrypt hash first
-- Then update:
UPDATE users 
SET password_hash = 'new_hash' 
WHERE email = 'nonitadmin@company.com';
```

### Deactivate User
```sql
UPDATE users 
SET is_active = false 
WHERE email = 'nonitemployee1@company.com';
```

### Reset Demo Data
```bash
# Backup first!
pg_dump hrms_db > backup.sql

# Then reset
psql -U postgres -d hrms_db -f non_it_demo_credentials.sql
```

### View All Non-IT Users
```sql
SELECT 
  u.email, 
  u.role, 
  u.is_active, 
  e.first_name, 
  e.last_name
FROM users u
LEFT JOIN employees e ON u.id = e.user_id
WHERE u.company_id = 'c550e8400-e29b-41d4-a716-446655440001'
ORDER BY u.role;
```

---

## 🔗 Related Documentation

- **Full Setup Guide:** `NON_IT_SETUP_SUMMARY.md`
- **Credentials Reference:** `NON_IT_DEMO_CREDENTIALS.md`
- **Portal Comparison:** `LOGIN_PORTALS_GUIDE.md`
- **Database Schema:** `hr_management_complete_schema_part2.sql`

---

## ✅ Checklist

Before testing, verify:
- [ ] SQL file executed successfully
- [ ] Database server running
- [ ] Node.js dev server started (`npm run dev`)
- [ ] Browser can access localhost:5173
- [ ] Location services enabled on device
- [ ] No console errors in browser

---

**Status:** ✅ Ready to Use  
**Last Updated:** July 16, 2026  
**Version:** 1.0

---

## Quick Links

| Need Help With | See File |
|---|---|
| Setup instructions | `NON_IT_SETUP_SUMMARY.md` |
| All credentials | `NON_IT_DEMO_CREDENTIALS.md` |
| Portal comparison | `LOGIN_PORTALS_GUIDE.md` |
| SQL data | `non_it_demo_credentials.sql` |

---

**Happy Testing! 🚀**
