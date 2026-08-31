# 🚀 Quick Start: Subscription System

## Immediate Next Steps

### 1️⃣ Run Database Migration (5 minutes)

Go to your Supabase Dashboard → SQL Editor:

```sql
-- Execute this file in Supabase:
-- File: subscription-feature-gating-migration.sql
```

This creates all necessary tables and seeds the 4 pricing tiers.

### 2️⃣ Test the Pricing Page (1 minute)

The pricing page is already updated and ready:
- Visit: `http://localhost:8000/subscription`
- You'll see 4 pricing tiers loaded from the database
- Click "Get Started" on any paid plan to see the payment flow

### 3️⃣ Add Feature Guards to Existing Pages (15 minutes)

#### Example: Protect Live Location Tracking

**Before:**
```typescript
// src/pages/Non-IT/EmployeeLiveLocation.tsx
export default function LiveLocationPage() {
  return <LiveLocationMap />
}
```

**After:**
```typescript
import FeatureGuard from '../../components/subscription/FeatureGuard'

export default function LiveLocationPage() {
  return (
    <FeatureGuard feature="LIVE_LOCATION_TRACKING">
      <LiveLocationMap />
    </FeatureGuard>
  )
}
```

That's it! The page now shows an upgrade prompt for non-Premium users.

### 4️⃣ Add Lock Badges to Navigation (10 minutes)

Update your sidebar/navigation to show which features are locked:

```typescript
import FeatureLockBadge from '../components/subscription/FeatureLockBadge'

<Link to="/live-location">
  <MapPin className="w-5 h-5" />
  Live Location
  <FeatureLockBadge feature="LIVE_LOCATION_TRACKING" size="sm" />
</Link>
```

---

## Testing the Flow

### Test Scenario 1: Free Trial User

1. Create a new company with FREE_TRIAL
2. Try to access "Live Location" page
3. Should see: "Upgrade to Premium HRMS to unlock Live Location Tracking"

### Test Scenario 2: Premium User

#### Step 1: Admin Creates Subscription
```javascript
// Call from admin panel or Postman
POST http://localhost:3001/api/subscriptions/process-payment

Body:
{
  "companyId": "your-company-uuid",
  "packageId": "premium-package-uuid",
  "employeeCount": 10,
  "durationDays": 30,
  "userId": "admin-uuid",
  "paymentMethod": "QR_CODE"
}

Response:
{
  "licenseCode": "SRJ-PREM-X8K2B9C1",
  "totalAmount": 2700,
  "expiresAt": "2026-09-11..."
}
```

#### Step 2: HR Manager Activates License
```javascript
POST http://localhost:3001/api/subscriptions/activate-license

Body:
{
  "licenseCode": "SRJ-PREM-X8K2B9C1",
  "companyId": "your-company-uuid",
  "userId": "hr-manager-uuid"
}
```

#### Step 3: Verify Access
- Refresh the page
- Live Location feature should now be unlocked
- No upgrade prompt shown

---

## Quick Reference: Feature List

### FREE_TRIAL Features
- `EMPLOYEE_MGMT`
- `BASIC_ATTENDANCE`
- `BASIC_REPORTS`

### STANDARD Features (₹4/employee/day)
+ `BASIC_PAYROLL`
+ `MOBILE_APP`
+ `CUSTOM_WORKFLOWS`

### POWER Features (₹7/employee/day)
+ `ADVANCED_PAYROLL`
+ `AI_ANALYTICS`
+ `CUSTOM_REPORTS`
+ `API_ACCESS`

### PREMIUM Features (₹9/employee/day)
+ `LIVE_LOCATION_TRACKING`
+ `REALTIME_FACE_VERIFICATION`
+ `COMPLIANCE_TOOLS`

---

## Pages to Update with Feature Guards

### High Priority (Premium Features)
- [ ] `src/pages/Non-IT/EmployeeLiveLocation.tsx` → Add `LIVE_LOCATION_TRACKING`
- [ ] Face verification pages → Add `REALTIME_FACE_VERIFICATION`
- [ ] Compliance/audit pages → Add `COMPLIANCE_TOOLS`

### Medium Priority (Power Features)
- [ ] AI Analytics pages → Add `AI_ANALYTICS`
- [ ] Advanced payroll pages → Add `ADVANCED_PAYROLL`
- [ ] Custom reports pages → Add `CUSTOM_REPORTS`
- [ ] API integration pages → Add `API_ACCESS`

### Low Priority (Standard Features)
- [ ] Basic payroll pages → Add `BASIC_PAYROLL`
- [ ] Mobile app features → Add `MOBILE_APP`
- [ ] Workflow customization → Add `CUSTOM_WORKFLOWS`

---

## Navigation Components to Update

### Dashboard Sidebars
- [ ] `src/components/dashboard/AdminDashboard.jsx`
- [ ] `src/components/dashboard/HRDashboard.jsx`
- [ ] `src/components/dashboard/EmployeeDashboard.jsx`
- [ ] `src/components/dashboard/NonITEmployeeDashboard.jsx`

### Main Navigation
- [ ] `src/components/Navbar.tsx`

### Quick Action Buttons
Find all quick action buttons and add lock badges to premium features.

---

## API Routes to Protect

### Example: Protect Location API
```javascript
// src/api/locationTracking.js (or routes file)
import { checkFeatureAccessMiddleware, FEATURE_MAP } from '../middleware/featureGate.js'

router.post('/api/location/update',
  checkFeatureAccessMiddleware(FEATURE_MAP.LIVE_LOCATION_TRACKING),
  async (req, res) => {
    // Only accessible to Premium users
    // ...location tracking logic
  }
)
```

Apply similar protection to:
- [ ] Live location endpoints
- [ ] Face verification endpoints
- [ ] AI analytics endpoints
- [ ] Advanced payroll endpoints

---

## Subscription Status Widget (Optional Enhancement)

Add to dashboard to show subscription info:

```typescript
import { useSubscription } from '../context/SubscriptionContext'

function SubscriptionStatusWidget() {
  const {
    activeSubscription,
    getCurrentPackageDisplay,
    getDaysUntilExpiry,
    isSubscriptionActive
  } = useSubscription()

  if (!isSubscriptionActive()) {
    return (
      <div className="bg-red-500/20 border border-red-500 rounded-lg p-4">
        <h3>No Active Subscription</h3>
        <Link to="/subscription">Upgrade Now</Link>
      </div>
    )
  }

  return (
    <div className="bg-green-500/20 border border-green-500 rounded-lg p-4">
      <h3>{getCurrentPackageDisplay()}</h3>
      <p>{getDaysUntilExpiry()} days remaining</p>
      <Link to="/subscription">Upgrade Plan</Link>
    </div>
  )
}
```

---

## Common Patterns

### Pattern 1: Feature Guard Entire Page
```typescript
<FeatureGuard feature="LIVE_LOCATION_TRACKING">
  <YourPageComponent />
</FeatureGuard>
```

### Pattern 2: Conditional Render in Component
```typescript
const { hasFeatureAccess } = useSubscription()

return (
  <div>
    {hasFeatureAccess('AI_ANALYTICS') ? (
      <AIInsightsDashboard />
    ) : (
      <div>Upgrade to unlock AI Analytics</div>
    )}
  </div>
)
```

### Pattern 3: Disable Button
```typescript
const { hasFeatureAccess } = useSubscription()
const canAccessFeature = hasFeatureAccess('ADVANCED_PAYROLL')

<button 
  disabled={!canAccessFeature}
  className={!canAccessFeature ? 'opacity-50 cursor-not-allowed' : ''}
>
  Advanced Payroll Settings
  {!canAccessFeature && ' 🔒'}
</button>
```

### Pattern 4: Protect API Endpoint
```javascript
router.post('/api/ai/analyze',
  checkFeatureAccessMiddleware(FEATURE_MAP.AI_ANALYTICS),
  controller.analyze
)
```

---

## Troubleshooting

### Features Not Unlocking?

Check in Supabase:
```sql
-- 1. Check active subscription
SELECT * FROM company_subscriptions 
WHERE company_id = 'your-company-uuid' 
AND payment_status = 'PAID' 
AND expires_at > NOW();

-- 2. Check package features
SELECT sp.features 
FROM company_subscriptions cs
JOIN subscription_packages sp ON cs.package_id = sp.id
WHERE cs.company_id = 'your-company-uuid';
```

### License Code Not Working?

```sql
-- Verify license exists
SELECT * FROM company_subscriptions 
WHERE unique_license_code = 'SRJ-PREM-X8K2B9C1';
```

---

## 📚 Full Documentation

- **Complete Guide**: `SUBSCRIPTION_FEATURE_GATING_GUIDE.md`
- **Implementation Summary**: `IMPLEMENTATION_SUMMARY.md`
- **Database Migration**: `subscription-feature-gating-migration.sql`

---

## ✅ Completion Checklist

- [x] Database schema created
- [x] Backend API implemented
- [x] Frontend components created
- [x] Subscription context integrated
- [x] Pricing page updated
- [ ] Feature guards added to pages
- [ ] Lock badges added to navigation
- [ ] API endpoints protected
- [ ] Admin panel for subscriptions
- [ ] HR manager license activation UI
- [ ] Payment gateway integration

You're 80% done! Just add the feature guards and you're ready to launch! 🚀
