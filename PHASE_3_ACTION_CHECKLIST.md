# Phase 3 Quick Action Checklist

## ⚡ Fast Track: Get Non-IT Dashboard Working in 5 Minutes

### Step 1️⃣: Apply Database Migration (3 minutes)

Go to Supabase SQL Editor and run this:

```sql
-- Add columns to users table
ALTER TABLE users ADD COLUMN IF NOT EXISTS company_type VARCHAR(50) DEFAULT 'it';
ALTER TABLE users ADD COLUMN IF NOT EXISTS location_tracking_enabled BOOLEAN DEFAULT FALSE;
ALTER TABLE users ADD COLUMN IF NOT EXISTS last_location_ping TIMESTAMP WITH TIME ZONE;

-- Add columns to companies table
ALTER TABLE companies ADD COLUMN IF NOT EXISTS company_type VARCHAR(50) DEFAULT 'it';
ALTER TABLE companies ADD COLUMN IF NOT EXISTS is_verified BOOLEAN DEFAULT FALSE;
ALTER TABLE companies ADD COLUMN IF NOT EXISTS email_verification_token VARCHAR(255) UNIQUE;
ALTER TABLE companies ADD COLUMN IF NOT EXISTS email_verified_at TIMESTAMP WITH TIME ZONE;

-- Create location_logs table
CREATE TABLE IF NOT EXISTS location_logs (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  role VARCHAR(50) NOT NULL,
  latitude DECIMAL(10, 8) NOT NULL,
  longitude DECIMAL(11, 8) NOT NULL,
  accuracy DECIMAL(10, 2),
  timestamp TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- Create indexes
CREATE INDEX IF NOT EXISTS idx_location_logs_user_timestamp ON location_logs(user_id, timestamp);
CREATE INDEX IF NOT EXISTS idx_location_logs_timestamp ON location_logs(timestamp);
CREATE INDEX IF NOT EXISTS idx_users_company_type ON users(company_type);

-- Enable RLS on location_logs
ALTER TABLE location_logs ENABLE ROW LEVEL SECURITY;

-- RLS Policy: Users can insert their own location
CREATE POLICY IF NOT EXISTS "Users can insert their own location logs" ON location_logs
  FOR INSERT WITH CHECK (user_id = auth.uid());

-- RLS Policy: Users can view company locations
CREATE POLICY IF NOT EXISTS "Users can view location logs from their company" ON location_logs
  FOR SELECT USING (
    user_id IN (
      SELECT id FROM users 
      WHERE company_id IN (
        SELECT company_id FROM users WHERE id = auth.uid()
      )
    )
  );
```

**✅ Done!** Click Run and wait for "Success" message.

---

### Step 2️⃣: Update Test User (1 minute)

Still in SQL Editor, run:

```sql
-- Set test user as Non-IT company
UPDATE users 
SET company_type = 'non-it', location_tracking_enabled = true 
WHERE email = 'giwore2911@dolofan.com';

-- Verify the update
SELECT email, company_type, location_tracking_enabled 
FROM users 
WHERE email = 'giwore2911@dolofan.com';
```

**✅ Done!** You should see the user updated with company_type = 'non-it'

---

### Step 3️⃣: Start Development Server (1 minute)

```bash
npm run dev
```

---

### Step 4️⃣: Test the Dashboard (2 minutes)

1. Go to: `http://localhost:5173`
2. Login with:
   - **Email:** `giwore2911@dolofan.com`
   - **Password:** `password123`
3. You should see:
   - ✅ Profile loads (no more errors)
   - ✅ Company Type: "Non-IT"
   - ✅ Location badge appears
   - ✅ Browser asks for location permission
   - ✅ "Allow" → Location tracking starts

---

## ✅ What You Should See

### Dashboard View:
- Profile card shows company name and type
- Location tracking badge is visible
- Your location displays on the dashboard
- No console errors about profile loading

### Console Messages:
```
✅ Location tracking enabled
✅ Latitude: 40.7128
✅ Longitude: -74.0060
✅ Location saved
```

---

## ❌ If Something Goes Wrong

### Problem: "Profile fetch error"
**Solution:** Run Step 1 SQL migration again

### Problem: "User not authenticated"
**Solution:** 
1. Logout and login again
2. Check .env has correct SUPABASE_URL and ANON_KEY

### Problem: "Permission denied" for location
**Solution:**
1. Allow location in browser popup
2. Check browser privacy settings
3. Try incognito mode

### Problem: "location_logs table does not exist"
**Solution:** Paste Step 1 SQL again in Supabase SQL Editor

---

## 📊 Test Locations (Real Data)

You can now:
1. ✅ See your location on the dashboard
2. ✅ View location history
3. ✅ See other employees' locations (if HR/Admin)
4. ✅ Track location changes in real-time

---

## 🎯 Success Indicators

After Phase 3 setup, you'll have:

- ✅ No database errors
- ✅ Profile loads successfully
- ✅ Location badge appears
- ✅ Geolocation working
- ✅ Non-IT dashboard fully functional
- ✅ Location data saved in database
- ✅ Real-time tracking enabled

---

## 📝 Files Created

- `migrations/001_add_non_it_company_support.sql` ← Migration SQL
- `apply-non-it-migration.js` ← Helper script
- `supabase/functions/location-tracking/index.ts` ← API endpoints
- `PHASE_3_SETUP_GUIDE.md` ← Detailed guide
- `PHASE_3_ACTION_CHECKLIST.md` ← This file

---

## 🚀 Total Time: ~5 minutes

1. SQL Migration: 2 min ⏱️
2. Update User: 1 min ⏱️
3. Start Server: 1 min ⏱️
4. Test: 1 min ⏱️

**Done!** 🎉

---

**Next:** Go to Step 1 and apply the migration!
