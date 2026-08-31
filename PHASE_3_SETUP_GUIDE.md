# Phase 3: Non-IT Company Backend & Database Setup Guide

## Overview
Phase 3 sets up the backend infrastructure needed for Non-IT company location tracking. The frontend (Phase 2) is already complete. This phase must be completed before testing the Non-IT dashboard.

## Current Status
- ✅ **Phase 2 Frontend:** Complete (dashboards, tracking components, authentication)
- ⏳ **Phase 3 Backend:** Needs setup (database schema, API endpoints)

---

## STEP 1: Apply Database Migration

### Option A: Using Supabase SQL Editor (Recommended)

1. Open Supabase Dashboard: https://supabase.com/dashboard
2. Select your project
3. Go to **SQL Editor** → Click **"New Query"**
4. Copy and paste the SQL from: `migrations/001_add_non_it_company_support.sql`
5. Click **Run**
6. Wait for success message

### Option B: Using the Helper Script

```bash
node apply-non-it-migration.js
```

This script will:
- Check if the migration is already applied
- Print instructions if manual SQL entry is needed
- Verify the database is ready

### What the Migration Does

The migration adds:

1. **Users Table Changes:**
   - `company_type` (VARCHAR): 'it' or 'non-it'
   - `location_tracking_enabled` (BOOLEAN): Enable/disable tracking
   - `last_location_ping` (TIMESTAMP): Last location update time

2. **Companies Table Changes:**
   - `company_type` (VARCHAR): 'it' or 'non-it'
   - `is_verified` (BOOLEAN): Email verification status
   - `email_verification_token` (VARCHAR): For email verification
   - `email_verified_at` (TIMESTAMP): When verification happened

3. **New Table: location_logs**
   ```
   - id (UUID): Primary key
   - user_id (UUID): References users
   - role (VARCHAR): 'employee', 'hr_manager', 'admin'
   - latitude (DECIMAL): Employee's latitude
   - longitude (DECIMAL): Employee's longitude
   - accuracy (DECIMAL): GPS accuracy in meters
   - timestamp (TIMESTAMP): When location was recorded
   - created_at (TIMESTAMP): Record creation time
   ```

4. **Indexes:** For fast queries on user_id, timestamp

5. **RLS Policies:** Security policies for location_logs table

---

## STEP 2: Update Existing Demo Users

After migration, update the existing demo user to test Non-IT company:

```sql
-- Update demo user to Non-IT company for testing
UPDATE users 
SET company_type = 'non-it', location_tracking_enabled = true 
WHERE email = 'giwore2911@dolofan.com';

-- Optional: Create a Non-IT company record if needed
UPDATE companies 
SET company_type = 'non-it' 
WHERE id IN (SELECT company_id FROM users WHERE email = 'giwore2911@dolofan.com');
```

---

## STEP 3: Deploy Location Tracking API (Optional - Advanced)

If you want to use Supabase Edge Functions for the location API:

1. Install Supabase CLI: `npm install -g supabase`
2. Deploy the function:
   ```bash
   supabase functions deploy location-tracking
   ```

Or use the provided backend endpoints directly (see below).

---

## STEP 4: Backend API Endpoints

The frontend makes these API calls. Implement these as Supabase REST endpoints or custom backend routes:

### 1. Log Location
**POST** `/api/location-tracking/log`
```json
{
  "latitude": 40.7128,
  "longitude": -74.0060,
  "accuracy": 5.5
}
```

**Response:**
```json
{
  "success": true,
  "data": {
    "id": "uuid",
    "user_id": "uuid",
    "latitude": 40.7128,
    "longitude": -74.0060,
    "timestamp": "2024-07-16T10:00:00Z"
  }
}
```

### 2. Get Latest Locations for Company
**GET** `/api/location-tracking/latest`

**Response:**
```json
{
  "success": true,
  "data": [
    {
      "user_id": "uuid",
      "full_name": "John Doe",
      "role": "employee",
      "location": {
        "latitude": 40.7128,
        "longitude": -74.0060,
        "timestamp": "2024-07-16T10:00:00Z"
      }
    }
  ]
}
```

### 3. Get Location History
**GET** `/api/location-tracking/history/:userId`

**Response:**
```json
{
  "success": true,
  "data": [
    {
      "id": "uuid",
      "latitude": 40.7128,
      "longitude": -74.0060,
      "timestamp": "2024-07-16T10:00:00Z"
    }
  ]
}
```

---

## STEP 5: Verify Setup

After applying migration, verify by checking Supabase:

1. Go to **Table Editor**
2. Check if you see these new columns in `users`:
   - ✅ company_type
   - ✅ location_tracking_enabled
   - ✅ last_location_ping

3. Check if new table exists:
   - ✅ location_logs

4. Check if companies table has:
   - ✅ company_type
   - ✅ is_verified
   - ✅ email_verification_token
   - ✅ email_verified_at

---

## STEP 6: Test the Non-IT Dashboard

Once migration is complete:

1. **Start the development server:**
   ```bash
   npm run dev
   ```

2. **Login with test credentials:**
   - Email: `giwore2911@dolofan.com`
   - Password: `password123`

3. **You should see:**
   - Profile loads successfully
   - Company Type: "Non-IT"
   - Location tracking badge on dashboard
   - Location permissions prompt
   - Location tracking controls

---

## Troubleshooting

### Error: "Profile fetch error"
**Cause:** Database query failing because columns don't exist yet
**Fix:** Run the migration (Step 1)

### Error: "Failed to load resource: 400"
**Cause:** Supabase is returning 400 error on location_logs table
**Fix:** The table doesn't exist. Run the migration SQL.

### Error: "User not authenticated"
**Cause:** Authentication issue
**Fix:** Check that VITE_SUPABASE_URL and VITE_SUPABASE_ANON_KEY are correct in .env

### Location not showing on map
**Cause:** Browser geolocation permission denied
**Fix:** Allow location access when prompted. Check browser privacy settings.

---

## File Checklist

After Phase 3 setup, you should have:

- ✅ `migrations/001_add_non_it_company_support.sql` - Migration file
- ✅ `apply-non-it-migration.js` - Helper script
- ✅ `supabase/functions/location-tracking/index.ts` - API endpoints (optional)
- ✅ Database with new schema applied
- ✅ Test user updated with company_type = 'non-it'

---

## Next Steps

Once Phase 3 is complete:

1. ✅ Database schema is ready
2. ✅ Location tracking APIs are available
3. ✅ Frontend can save and retrieve locations
4. ✅ Non-IT dashboard is fully functional

Now you can:
- Test location tracking on Non-IT dashboard
- Track employee locations in real-time
- View location history
- Run full end-to-end tests

---

## Timeline

- Database Migration: ~15 minutes
- API Setup: ~30 minutes (optional)
- Testing: ~30 minutes

**Total: ~45 minutes to 1 hour**

---

## Support

If you encounter issues:

1. Check the error message in browser console
2. Verify migration was applied successfully
3. Confirm .env variables are set
4. Check Supabase dashboard for table structure
5. Review RLS policies if data is not showing

---

**Phase 3 Status:** Ready to start ⏳
**Next:** Run STEP 1 to apply database migration
