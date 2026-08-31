# Company-Level Location Tracking Controls - Implementation Guide

## Overview

This guide explains the customizable company-level controls for live location tracking and geo-tagging in Sarjana HR Tech. HR Admins can now configure location and tracking settings specific to their company's needs.

---

## 🎯 Features Implemented

### 1. **Geo-Tagging Control**
- Toggle ON/OFF coordinate verification for check-in/check-out
- When disabled: Attendance works without location verification (manual entry)
- When enabled: Employees must be within office geofence boundaries

### 2. **Live Location Tracking Control**
- Toggle ON/OFF real-time employee tracking (Premium feature)
- When disabled: Background location pings are rejected
- When enabled: Field employees are tracked at custom intervals

### 3. **Custom Tracking Interval**
- Adjustable update frequency: 15-300 seconds
- Default: 30 seconds (balanced)
- Affects battery consumption vs. accuracy

### 4. **Custom Geofence Radius**
- Configurable per-office boundary (50-500 meters)
- Default: 100 meters
- Applied to new office locations

---

## 📊 Database Schema

### New Tables Created

#### `company_settings` Table
```sql
- company_id (UUID, unique)
- is_geo_tagging_enabled (boolean, default: true)
- is_live_tracking_enabled (boolean, default: false)
- tracking_interval_seconds (integer, default: 30)
- default_allowed_radius_meters (integer, default: 100)
- require_face_verification (boolean)
- allow_manual_attendance (boolean)
- location_data_retention_days (integer)
```

### Modified Tables

#### `office_locations` Table (Optional columns added)
```sql
- is_geo_tagging_enabled (boolean)
- is_live_tracking_enabled (boolean)
- tracking_interval_seconds (integer)
- custom_allowed_radius (integer)
```

---

## 🔧 Setup Instructions

### Step 1: Run Database Migration

Execute in Supabase SQL Editor:

```bash
# File: location-tracking-controls-migration.sql
```

This creates:
- ✅ `company_settings` table
- ✅ Helper functions for settings management
- ✅ Auto-initialization trigger for new companies
- ✅ View for easy settings access
- ✅ Default settings for existing companies

### Step 2: Verify Tables Created

Check in Supabase Table Editor:
- `company_settings` table should exist
- All existing companies should have default settings

### Step 3: Test Settings API

```bash
# Get company settings
GET /api/company-settings/:companyId

# Update settings
PATCH /api/company-settings/:companyId
Body: {
  "userId": "admin-uuid",
  "is_geo_tagging_enabled": false,
  "is_live_tracking_enabled": true,
  "tracking_interval_seconds": 60
}
```

---

## 🎨 Frontend Integration

### Add to Your Settings Page

```typescript
import LocationTrackingSettings from '../components/settings/LocationTrackingSettings'

function SettingsPage() {
  return (
    <div>
      <LocationTrackingSettings />
    </div>
  )
}
```

### Using the Context

```typescript
import { useCompanySettings } from '../context/CompanySettingsContext'

function MyComponent() {
  const {
    settings,
    isGeoTaggingEnabled,
    isLiveTrackingEnabled,
    toggleGeoTagging,
    updateTrackingInterval
  } = useCompanySettings()

  // Check if geo-tagging is enabled
  if (isGeoTaggingEnabled()) {
    // Require location verification
  } else {
    // Allow manual check-in
  }
}
```

---

## 🔌 Backend API Reference

### Get Company Settings
```javascript
GET /api/company-settings/:companyId

Response:
{
  "success": true,
  "settings": {
    "company_id": "uuid",
    "is_geo_tagging_enabled": true,
    "is_live_tracking_enabled": false,
    "tracking_interval_seconds": 30,
    "default_allowed_radius_meters": 100
  }
}
```

### Update Company Settings
```javascript
PATCH /api/company-settings/:companyId

Body:
{
  "userId": "admin-uuid",
  "is_geo_tagging_enabled": false,
  "is_live_tracking_enabled": true
}

Response:
{
  "success": true,
  "message": "Company settings updated successfully",
  "settings": {...}
}
```

### Toggle Geo-Tagging
```javascript
POST /api/company-settings/:companyId/toggle-geotagging

Body:
{
  "userId": "admin-uuid",
  "enabled": false
}
```

### Toggle Live Tracking
```javascript
POST /api/company-settings/:companyId/toggle-live-tracking

Body:
{
  "userId": "admin-uuid",
  "enabled": true
}
```

### Update Tracking Interval
```javascript
PATCH /api/company-settings/:companyId/tracking-interval

Body:
{
  "userId": "admin-uuid",
  "intervalSeconds": 60
}
```

### Update Default Radius
```javascript
PATCH /api/company-settings/:companyId/default-radius

Body:
{
  "userId": "admin-uuid",
  "radiusMeters": 150
}
```

---

## 🚀 How It Works

### Attendance Check-In Flow

```
1. Employee initiates check-in
2. Backend checks: is_geo_tagging_enabled?
   
   IF ENABLED:
   - Verify employee is within office radius
   - Reject if outside geofence
   - Allow if within boundary
   
   IF DISABLED:
   - Skip location verification
   - Allow manual check-in
   - Log coordinates if provided (optional)
```

### Live Location Tracking Flow

```
1. Employee checks in successfully
2. Frontend checks:
   - Is live tracking enabled for company?
   - Does company have PREMIUM subscription?
   
   IF BOTH TRUE:
   - Start background location polling
   - Use tracking_interval_seconds from settings
   - Send location pings to backend
   
3. Backend receives location ping:
   - Verify is_live_tracking_enabled = TRUE
   - If FALSE: Reject with 403 Forbidden
   - If TRUE: Log location data
```

---

## 🔒 Permission & Subscription Checks

### Geo-Tagging
- **Permission**: HR Manager or Admin
- **Subscription**: Available in all tiers
- **Default**: Enabled

### Live Location Tracking
- **Permission**: HR Manager or Admin
- **Subscription**: Requires **PREMIUM** tier
- **Default**: Disabled

---

## 💡 Usage Examples

### Example 1: Disable Geo-Tagging for Office Workers

```typescript
// HR Admin disables geo-tagging
await toggleGeoTagging(false, adminUserId)

// Result: Office workers can now check in without location verification
// Useful for: Office-based employees, WFH employees
```

### Example 2: Enable Live Tracking for Field Sales

```typescript
// HR Admin enables live tracking (requires Premium)
await toggleLiveTracking(true, adminUserId)

// Set aggressive tracking for high-value field employees
await updateTrackingInterval(15, adminUserId) // Every 15 seconds

// Result: Real-time visibility of field sales team locations
```

### Example 3: Battery-Saving Configuration

```typescript
// Enable live tracking but with longer intervals
await toggleLiveTracking(true, adminUserId)
await updateTrackingInterval(300, adminUserId) // Every 5 minutes

// Result: Live tracking with minimal battery impact
```

### Example 4: Flexible Geofence for Large Campus

```typescript
// Increase geofence radius for large office campus
await updateDefaultRadius(300, adminUserId) // 300 meters

// Result: Employees can check in from anywhere on campus
```

---

## 🎛️ Settings UI Features

The `LocationTrackingSettings` component provides:

1. **Toggle Switches**
   - Easy ON/OFF for geo-tagging
   - Easy ON/OFF for live tracking

2. **Slider Controls**
   - Tracking interval: 15s - 300s
   - Geofence radius: 50m - 500m

3. **Visual Feedback**
   - Current status indicators
   - Success/error messages
   - Loading states

4. **Premium Badge**
   - Shows which features require Premium

5. **Info Tooltips**
   - Explains each setting
   - Shows current values
   - Displays recommendations

---

## 🔍 Testing Checklist

### Database
- [ ] Migration runs successfully
- [ ] `company_settings` table created
- [ ] Default settings initialized for existing companies
- [ ] Helper functions work correctly

### Backend API
- [ ] Get settings endpoint returns data
- [ ] Update settings endpoint saves changes
- [ ] Toggle endpoints work correctly
- [ ] Settings are enforced in check-in API
- [ ] Settings are enforced in location tracking API

### Frontend
- [ ] Settings UI loads correctly
- [ ] Toggles update state
- [ ] Sliders update values
- [ ] Save button persists changes
- [ ] Success/error messages display
- [ ] Context provides current settings

### Integration
- [ ] Geo-tagging disabled = manual check-in works
- [ ] Geo-tagging enabled = location verified
- [ ] Live tracking disabled = location pings rejected (403)
- [ ] Live tracking enabled = location pings accepted
- [ ] Tracking interval affects polling frequency

---

## 📋 Configuration Options

### Tracking Intervals

| Interval | Use Case | Battery Impact |
|----------|----------|----------------|
| 15s | High-value field employees, critical tracking | High |
| 30s | Balanced - recommended default | Medium |
| 60s | Standard field employees | Low |
| 120s | Light tracking | Very Low |
| 300s | Minimal tracking, battery-saving | Minimal |

### Geofence Radius

| Radius | Use Case |
|--------|----------|
| 50m | Small office, tight control |
| 100m | Standard office - recommended default |
| 200m | Large building or complex |
| 300m | Campus or multi-building site |
| 500m | Very large campus or flexible policy |

---

## 🛠️ Files Created/Modified

### New Files
1. `location-tracking-controls-migration.sql` - Database schema
2. `src/api/companySettings.js` - Settings API
3. `src/api/routes/companySettings.js` - Settings routes
4. `src/context/CompanySettingsContext.jsx` - React context
5. `src/components/settings/LocationTrackingSettings.tsx` - UI component
6. `LOCATION_TRACKING_CONTROLS_GUIDE.md` - This guide

### Modified Files
1. `src/api/attendanceCheckIn.js` - Added geo-tagging check
2. `src/api/locationTracking.js` - Added live tracking check
3. `src/api/server.js` - Added settings routes

---

## ⚠️ Important Notes

### Subscription Requirements
- **Geo-Tagging Control**: All tiers ✅
- **Live Location Tracking**: Premium tier only 👑

### Performance Considerations
- Lower tracking intervals = higher battery consumption
- Recommended: 30-60 seconds for balanced performance
- Use 15s only for critical tracking needs

### Privacy & Compliance
- Inform employees about location tracking policies
- Provide opt-out where legally required
- Set appropriate data retention periods
- Follow local privacy regulations (GDPR, etc.)

### Data Retention
- Default: 90 days for location data
- Configurable in `company_settings.location_data_retention_days`
- Old data automatically deleted via scheduled job (TODO)

---

## 🎉 Benefits

### For HR Admins
✅ Full control over location policies  
✅ Flexible configuration per company needs  
✅ Easy toggle switches - no technical knowledge needed  
✅ Real-time updates - changes apply immediately  

### For Employees
✅ Fair attendance policies  
✅ Manual check-in when geo-tagging disabled  
✅ Battery-efficient tracking options  
✅ Transparent location usage  

### For Company
✅ Cost optimization - disable unused features  
✅ Compliance with local regulations  
✅ Customizable to business needs  
✅ Scalable across different employee types  

---

## 📞 Support

For issues or questions:
- Check the database migration log
- Verify API endpoints are responding
- Check browser console for frontend errors
- Review Supabase logs for backend errors

---

## 🚀 Future Enhancements

- [ ] Per-office location settings override
- [ ] Scheduled tracking (e.g., only during work hours)
- [ ] Geofence shapes (polygon vs circle)
- [ ] Employee-level tracking preferences
- [ ] Analytics dashboard for location data
- [ ] Automated data retention cleanup job
- [ ] Mobile app settings sync
