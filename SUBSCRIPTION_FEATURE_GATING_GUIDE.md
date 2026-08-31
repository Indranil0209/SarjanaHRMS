# Subscription & Feature Gating Implementation Guide

## Overview

This guide explains how to use the Subscription & Feature Gating system implemented for Sarjana HRMS.

## System Architecture

### 4 Pricing Tiers

1. **FREE_TRIAL** (₹0/day)
   - Features: EMPLOYEE_MGMT, BASIC_ATTENDANCE, BASIC_REPORTS
   - Duration: 14 days

2. **STANDARD** (₹4/employee/day)
   - Features: EMPLOYEE_MGMT, BASIC_ATTENDANCE, BASIC_PAYROLL, MOBILE_APP, CUSTOM_WORKFLOWS

3. **POWER** (₹7/employee/day)
   - Features: EMPLOYEE_MGMT, BASIC_ATTENDANCE, ADVANCED_PAYROLL, AI_ANALYTICS, CUSTOM_REPORTS, API_ACCESS

4. **PREMIUM** (₹9/employee/day)
   - Features: EMPLOYEE_MGMT, BASIC_ATTENDANCE, ADVANCED_PAYROLL, AI_ANALYTICS, LIVE_LOCATION_TRACKING, REALTIME_FACE_VERIFICATION, COMPLIANCE_TOOLS

---

## Database Setup

### 1. Run Migration

Execute the SQL migration file on your Supabase database:

```bash
# File: subscription-feature-gating-migration.sql
```

This creates:
- `subscription_packages` table (seeded with 4 tiers)
- `company_subscriptions` table
- `subscription_audit_logs` table
- Helper functions for license generation and feature checks

### 2. Row Level Security (RLS)

Add RLS policies in Supabase for secure access:

```sql
-- Allow authenticated users to read subscription packages
CREATE POLICY "Anyone can view subscription packages"
ON subscription_packages FOR SELECT
TO authenticated
USING (is_active = true);

-- Allow users to view their company's subscriptions
CREATE POLICY "Users can view own company subscriptions"
ON company_subscriptions FOR SELECT
TO authenticated
USING (company_id IN (
  SELECT company_id FROM users WHERE id = auth.uid()
));

-- Allow admins to insert subscriptions
CREATE POLICY "Admins can create subscriptions"
ON company_subscriptions FOR INSERT
TO authenticated
WITH CHECK (
  EXISTS (
    SELECT 1 FROM users 
    WHERE id = auth.uid() 
    AND role IN ('admin', 'super_admin')
  )
);
```

---

## Backend API Usage

### Available Endpoints

#### Public Routes

```javascript
// Get all subscription packages (for pricing page)
GET /api/subscriptions/packages

// Get specific package
GET /api/subscriptions/packages/:packageId
```

#### Admin Routes

```javascript
// Process payment and create subscription (ADMIN ONLY)
POST /api/subscriptions/process-payment
Body: {
  companyId: "uuid",
  packageId: "uuid",
  employeeCount: 50,
  durationDays: 30,
  userId: "uuid",
  paymentMethod: "QR_CODE",
  paymentTransactionId: "TXN123456"
}

Response: {
  subscription: {...},
  licenseCode: "SRJ-PREM-A8X2B9C1",
  totalAmount: 13500,
  expiresAt: "2026-09-11T..."
}
```

#### HR Manager Routes

```javascript
// Activate license code
POST /api/subscriptions/activate-license
Body: {
  licenseCode: "SRJ-PREM-A8X2B9C1",
  companyId: "uuid",
  userId: "uuid"
}

Response: {
  subscription: {...},
  message: "License activated successfully",
  features: ["LIVE_LOCATION_TRACKING", ...],
  expiresAt: "2026-09-11T..."
}
```

#### Protected Routes

```javascript
// Get active subscription for company
GET /api/subscriptions/active/:companyId

// Check feature access
POST /api/subscriptions/check-feature
Body: {
  companyId: "uuid",
  featureName: "LIVE_LOCATION_TRACKING"
}

// Get subscription history
GET /api/subscriptions/history/:companyId
```

---

## Frontend Usage

### 1. Using SubscriptionContext

```typescript
import { useSubscription } from '../context/SubscriptionContext'

function MyComponent() {
  const {
    subscriptionPackages,     // All available packages
    activeSubscription,        // Current active subscription
    loading,                   // Loading state
    hasFeatureAccess,          // Check feature access
    getCurrentPackage,         // Get package name
    isSubscriptionActive,      // Check if active
    getDaysUntilExpiry,        // Days remaining
    processPayment,            // Admin: process payment
    activateLicense            // HR: activate license
  } = useSubscription()

  // Check if feature is accessible
  const canUseTracking = hasFeatureAccess('LIVE_LOCATION_TRACKING')

  // Get current plan details
  const currentPlan = getCurrentPackage() // 'PREMIUM'
  const daysLeft = getDaysUntilExpiry()   // 27

  return (
    <div>
      {canUseTracking ? (
        <LiveLocationMap />
      ) : (
        <UpgradePrompt />
      )}
    </div>
  )
}
```

### 2. Using FeatureGuard Component

```typescript
import FeatureGuard from '../components/subscription/FeatureGuard'

function LiveLocationPage() {
  return (
    <FeatureGuard 
      feature="LIVE_LOCATION_TRACKING"
      showUpgradeButton={true}
    >
      {/* This content only shows if feature is accessible */}
      <LiveLocationTrackingDashboard />
    </FeatureGuard>
  )
}
```

### 3. Using FeatureLockBadge

```typescript
import FeatureLockBadge from '../components/subscription/FeatureLockBadge'

function NavigationMenu() {
  return (
    <nav>
      <Link to="/live-location">
        Live Location
        <FeatureLockBadge 
          feature="LIVE_LOCATION_TRACKING" 
          size="sm" 
        />
      </Link>
    </nav>
  )
}
```

### 4. Conditionally Disable Buttons

```typescript
import { useSubscription } from '../context/SubscriptionContext'
import { useNavigate } from 'react-router-dom'

function QuickActions() {
  const { hasFeatureAccess } = useSubscription()
  const navigate = useNavigate()

  const handleLiveLocationClick = () => {
    if (!hasFeatureAccess('LIVE_LOCATION_TRACKING')) {
      navigate('/subscription') // Redirect to upgrade
      return
    }
    navigate('/live-location')
  }

  return (
    <button
      onClick={handleLiveLocationClick}
      className={!hasFeatureAccess('LIVE_LOCATION_TRACKING') ? 'opacity-50 cursor-not-allowed' : ''}
    >
      Live Location
      {!hasFeatureAccess('LIVE_LOCATION_TRACKING') && ' 🔒'}
    </button>
  )
}
```

---

## Backend Middleware Usage

### Protecting API Routes

```javascript
import { checkFeatureAccessMiddleware, FEATURE_MAP } from '../middleware/featureGate.js'

// Protect location tracking endpoints
router.post('/location/track',
  checkFeatureAccessMiddleware(FEATURE_MAP.LIVE_LOCATION_TRACKING),
  async (req, res) => {
    // Only executes if company has LIVE_LOCATION_TRACKING
    // Otherwise returns 403 with upgrade message
  }
)

// Protect AI analytics endpoints
router.get('/analytics/ai-insights',
  checkFeatureAccessMiddleware(FEATURE_MAP.AI_ANALYTICS),
  async (req, res) => {
    // Only executes if company has AI_ANALYTICS
  }
)
```

### Feature Map Reference

```javascript
export const FEATURE_MAP = {
  LIVE_LOCATION_TRACKING: 'LIVE_LOCATION_TRACKING',
  REALTIME_FACE_VERIFICATION: 'REALTIME_FACE_VERIFICATION',
  AI_ANALYTICS: 'AI_ANALYTICS',
  ADVANCED_PAYROLL: 'ADVANCED_PAYROLL',
  COMPLIANCE_TOOLS: 'COMPLIANCE_TOOLS',
  API_ACCESS: 'API_ACCESS',
  CUSTOM_REPORTS: 'CUSTOM_REPORTS',
  CUSTOM_WORKFLOWS: 'CUSTOM_WORKFLOWS',
  BASIC_PAYROLL: 'BASIC_PAYROLL',
  MOBILE_APP: 'MOBILE_APP',
  BASIC_ATTENDANCE: 'BASIC_ATTENDANCE',
  EMPLOYEE_MGMT: 'EMPLOYEE_MGMT',
  BASIC_REPORTS: 'BASIC_REPORTS'
}
```

---

## Admin Workflow

### Creating Subscriptions for Companies

1. Company registers and pays via QR code
2. Admin verifies payment
3. Admin calls process payment API:

```javascript
const result = await processPayment({
  companyId: 'company-uuid',
  packageId: 'premium-package-uuid',
  employeeCount: 100,
  durationDays: 365,
  userId: 'admin-uuid',
  paymentMethod: 'QR_CODE',
  paymentTransactionId: 'TXN789456'
})

console.log('License Code:', result.licenseCode)
// Output: SRJ-PREM-X8K2B9D1
```

4. Admin shares license code with company HR Manager

---

## HR Manager Workflow

### Activating License

1. HR Manager receives unique license code from admin
2. HR Manager activates via UI or API:

```javascript
const result = await activateLicense('SRJ-PREM-X8K2B9D1', userId)

if (result.success) {
  alert('License activated! You now have access to Premium features.')
  // Reload subscription data
}
```

---

## Example: Gating Live Location Feature

### Frontend Component

```typescript
import FeatureGuard from '../components/subscription/FeatureGuard'
import LiveLocationMap from '../components/tracking/LiveLocationMap'

export default function LiveLocationPage() {
  return (
    <div className="p-6">
      <h1>Live Location Tracking</h1>
      
      <FeatureGuard feature="LIVE_LOCATION_TRACKING">
        <LiveLocationMap />
      </FeatureGuard>
    </div>
  )
}
```

### Backend Route

```javascript
import { checkFeatureAccessMiddleware, FEATURE_MAP } from '../middleware/featureGate.js'

router.post('/api/location/update',
  checkFeatureAccessMiddleware(FEATURE_MAP.LIVE_LOCATION_TRACKING),
  async (req, res) => {
    // Location tracking logic here
    // Only accessible to PREMIUM tier
    const { latitude, longitude, employeeId } = req.body
    
    // Save location...
    res.json({ success: true })
  }
)
```

### Sidebar Menu with Lock Badge

```typescript
import FeatureLockBadge from '../components/subscription/FeatureLockBadge'

function Sidebar() {
  const { hasFeatureAccess } = useSubscription()

  return (
    <nav>
      <Link 
        to="/live-location"
        className={!hasFeatureAccess('LIVE_LOCATION_TRACKING') ? 'opacity-50' : ''}
      >
        <MapPin className="w-5 h-5" />
        Live Location
        <FeatureLockBadge feature="LIVE_LOCATION_TRACKING" size="sm" />
      </Link>
    </nav>
  )
}
```

---

## Testing

### Test Feature Access

```javascript
// Check if a company has access to a feature
const response = await fetch('/api/subscriptions/check-feature', {
  method: 'POST',
  headers: { 'Content-Type': 'application/json' },
  body: JSON.stringify({
    companyId: 'test-company-uuid',
    featureName: 'LIVE_LOCATION_TRACKING'
  })
})

const result = await response.json()
console.log(result.hasAccess) // true or false
```

### Test License Activation

```javascript
const response = await fetch('/api/subscriptions/activate-license', {
  method: 'POST',
  headers: { 'Content-Type': 'application/json' },
  body: JSON.stringify({
    licenseCode: 'SRJ-PREM-X8K2B9D1',
    companyId: 'test-company-uuid',
    userId: 'test-user-uuid'
  })
})

const result = await response.json()
console.log(result.message)
```

---

## Feature List Reference

### FREE_TRIAL
- ✅ EMPLOYEE_MGMT
- ✅ BASIC_ATTENDANCE
- ✅ BASIC_REPORTS

### STANDARD
- ✅ All FREE_TRIAL features
- ✅ BASIC_PAYROLL
- ✅ MOBILE_APP
- ✅ CUSTOM_WORKFLOWS

### POWER
- ✅ All STANDARD features
- ✅ ADVANCED_PAYROLL
- ✅ AI_ANALYTICS
- ✅ CUSTOM_REPORTS
- ✅ API_ACCESS

### PREMIUM
- ✅ All POWER features
- ✅ LIVE_LOCATION_TRACKING
- ✅ REALTIME_FACE_VERIFICATION
- ✅ COMPLIANCE_TOOLS

---

## Troubleshooting

### Feature not unlocking after payment

1. Verify subscription in database:
```sql
SELECT * FROM company_subscriptions 
WHERE company_id = 'your-company-uuid' 
AND payment_status = 'PAID';
```

2. Check expiry date:
```sql
SELECT expires_at > NOW() as is_active 
FROM company_subscriptions 
WHERE company_id = 'your-company-uuid';
```

3. Verify package features:
```sql
SELECT sp.features 
FROM company_subscriptions cs
JOIN subscription_packages sp ON cs.package_id = sp.id
WHERE cs.company_id = 'your-company-uuid';
```

### License code not working

1. Check if code exists and is valid:
```sql
SELECT * FROM company_subscriptions 
WHERE unique_license_code = 'SRJ-PREM-X8K2B9D1';
```

2. Verify it's assigned to the correct company
3. Ensure payment_status is 'PAID'

---

## Next Steps

1. ✅ Database migration completed
2. ✅ Backend API implemented
3. ✅ Frontend components created
4. ⏳ Update existing pages with FeatureGuard
5. ⏳ Add subscription status to dashboard
6. ⏳ Implement payment gateway integration (Razorpay/Stripe)
7. ⏳ Add subscription renewal reminders

---

## Support

For issues or questions:
- Check the migration file: `subscription-feature-gating-migration.sql`
- Review API endpoints: `src/api/subscriptions.js`
- Check middleware: `src/middleware/featureGate.js`
- Frontend context: `src/context/SubscriptionContext.jsx`
