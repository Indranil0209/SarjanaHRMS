# Subscription & Feature Gating Architecture

## System Flow Diagram

```
┌─────────────────────────────────────────────────────────────────────┐
│                         PRICING PAGE                                │
│  ┌──────────┐  ┌──────────┐  ┌──────────┐  ┌──────────────────┐  │
│  │   FREE   │  │ STANDARD │  │  POWER   │  │  PREMIUM (👑)    │  │
│  │   ₹0     │  │   ₹4     │  │   ₹7     │  │   ₹9             │  │
│  └──────────┘  └──────────┘  └──────────┘  └──────────────────┘  │
│       │             │             │                │                │
└───────┼─────────────┼─────────────┼────────────────┼────────────────┘
        │             └─────────────┴────────────────┘
        │                          │
        │                          ▼
        │              ┌────────────────────────┐
        │              │  PAYMENT FLOW (QR)     │
        │              │  - Select Duration     │
        │              │  - Enter Employee Count│
        │              │  - Scan QR Code        │
        │              └────────────────────────┘
        │                          │
        ▼                          ▼
┌─────────────────┐    ┌──────────────────────────┐
│  FREE TRIAL     │    │  ADMIN VERIFICATION      │
│  - Auto Approve │    │  - Verify Payment        │
│  - 14 Days      │    │  - Generate License Code │
└─────────────────┘    │    "SRJ-PREM-X8K2B9C1"  │
        │              └──────────────────────────┘
        │                          │
        │                          ▼
        │              ┌──────────────────────────┐
        │              │  HR MANAGER ACTIVATION   │
        │              │  - Enter License Code    │
        │              │  - Activate Subscription │
        │              └──────────────────────────┘
        │                          │
        └──────────────────────────┘
                   │
                   ▼
        ┌──────────────────────────┐
        │  SUBSCRIPTION ACTIVATED  │
        │  - Features Unlocked     │
        │  - Access Granted        │
        └──────────────────────────┘
```

---

## Database Architecture

```
┌─────────────────────────────────────────────────────────────┐
│                    SUBSCRIPTION TABLES                      │
└─────────────────────────────────────────────────────────────┘

┌──────────────────────────────┐
│  subscription_packages       │
├──────────────────────────────┤
│ id (uuid)                    │◄──────────┐
│ package_name (varchar)       │           │
│ display_name (varchar)       │           │
│ price_per_employee_per_day   │           │
│ features (jsonb)             │           │
│   ["FEATURE_1", "FEATURE_2"] │           │
│ is_active (boolean)          │           │
└──────────────────────────────┘           │
                                            │
                                            │
┌──────────────────────────────┐           │
│  company_subscriptions       │           │
├──────────────────────────────┤           │
│ id (uuid)                    │           │
│ company_id (uuid)            │◄──────────┼─── companies.id
│ package_id (uuid)            │───────────┘
│ unique_license_code (varchar)│
│   "SRJ-PREM-X8K2B9C1"       │
│ employee_count (integer)     │
│ duration_days (integer)      │
│ total_amount (decimal)       │
│ payment_status (varchar)     │
│   PENDING | PAID | EXPIRED   │
│ activated_at (timestamp)     │
│ expires_at (timestamp)       │
└──────────────────────────────┘
                │
                │
                ▼
┌──────────────────────────────┐
│  subscription_audit_logs     │
├──────────────────────────────┤
│ id (uuid)                    │
│ subscription_id (uuid)       │
│ company_id (uuid)            │
│ action (varchar)             │
│ details (jsonb)              │
│ performed_by (uuid)          │
│ created_at (timestamp)       │
└──────────────────────────────┘
```

---

## Backend Architecture

```
┌──────────────────────────────────────────────────────────────┐
│                      EXPRESS API SERVER                      │
│                   http://localhost:3001                      │
└──────────────────────────────────────────────────────────────┘
                            │
                            │
        ┌───────────────────┼───────────────────┐
        │                   │                   │
        ▼                   ▼                   ▼
┌──────────────┐  ┌──────────────────┐  ┌──────────────┐
│  PUBLIC      │  │  PROTECTED       │  │  ADMIN ONLY  │
├──────────────┤  ├──────────────────┤  ├──────────────┤
│ GET /packages│  │ GET /active/:id  │  │ POST /process│
│ GET /pkg/:id │  │ POST /check-feat │  │  -payment    │
└──────────────┘  │ GET /history/:id │  └──────────────┘
                  │ POST /activate-  │
                  │   license        │
                  └──────────────────┘
                            │
                            ▼
        ┌─────────────────────────────────────┐
        │   FEATURE GATE MIDDLEWARE           │
        │   checkFeatureAccessMiddleware()    │
        ├─────────────────────────────────────┤
        │ 1. Extract company_id               │
        │ 2. Check active subscription        │
        │ 3. Verify feature in package        │
        │ 4. Return 403 if locked             │
        │ 5. Proceed if unlocked              │
        └─────────────────────────────────────┘
                            │
                            ▼
        ┌─────────────────────────────────────┐
        │      PROTECTED ENDPOINTS            │
        ├─────────────────────────────────────┤
        │ POST /location/track                │
        │   → requires LIVE_LOCATION_TRACKING │
        │                                     │
        │ GET /analytics/ai                   │
        │   → requires AI_ANALYTICS           │
        │                                     │
        │ POST /payroll/advanced              │
        │   → requires ADVANCED_PAYROLL       │
        └─────────────────────────────────────┘
```

---

## Frontend Architecture

```
┌──────────────────────────────────────────────────────────────┐
│                         APP.TSX                              │
│                     (Context Hierarchy)                      │
└──────────────────────────────────────────────────────────────┘
                            │
                            ▼
        ┌───────────────────────────────────────┐
        │      SubscriptionProvider             │
        │  (SubscriptionContext.jsx)            │
        ├───────────────────────────────────────┤
        │ State:                                │
        │  - subscriptionPackages []            │
        │  - activeSubscription                 │
        │  - loading                            │
        │  - companyId                          │
        │                                       │
        │ Methods:                              │
        │  - hasFeatureAccess(feature)          │
        │  - getCurrentPackage()                │
        │  - isSubscriptionActive()             │
        │  - getDaysUntilExpiry()               │
        │  - processPayment(data)               │
        │  - activateLicense(code)              │
        └───────────────────────────────────────┘
                            │
        ┌───────────────────┼───────────────────┐
        │                   │                   │
        ▼                   ▼                   ▼
┌──────────────┐  ┌──────────────────┐  ┌──────────────┐
│ PAGES        │  │ COMPONENTS       │  │ GUARDS       │
├──────────────┤  ├──────────────────┤  ├──────────────┤
│ Subscription │  │ FeatureLockBadge │  │ FeatureGuard │
│ Dashboard    │  │ Navbar           │  │              │
│ Settings     │  │ Sidebar          │  │              │
└──────────────┘  └──────────────────┘  └──────────────┘
```

---

## Feature Guard Component Flow

```
┌──────────────────────────────────────────────────────────────┐
│  <FeatureGuard feature="LIVE_LOCATION_TRACKING">             │
│    <LiveLocationMap />                                       │
│  </FeatureGuard>                                             │
└──────────────────────────────────────────────────────────────┘
                            │
                            ▼
        ┌───────────────────────────────────────┐
        │   1. Get useSubscription()            │
        │   2. Check hasFeatureAccess()         │
        └───────────────────────────────────────┘
                            │
        ┌───────────────────┴───────────────────┐
        │                                       │
        ▼                                       ▼
┌──────────────┐                      ┌──────────────────┐
│ HAS ACCESS   │                      │ NO ACCESS        │
├──────────────┤                      ├──────────────────┤
│ Render       │                      │ Show Locked UI   │
│ children     │                      │ - Blur content   │
│              │                      │ - Lock icon      │
│              │                      │ - Upgrade button │
└──────────────┘                      └──────────────────┘
```

---

## License Code Generation

```
┌──────────────────────────────────────────────────────────────┐
│              ADMIN PROCESSES PAYMENT                         │
└──────────────────────────────────────────────────────────────┘
                            │
                            ▼
        ┌───────────────────────────────────────┐
        │  1. Get package details               │
        │     - package_name: "PREMIUM"         │
        │     - prefix: "PREM"                  │
        └───────────────────────────────────────┘
                            │
                            ▼
        ┌───────────────────────────────────────┐
        │  2. Generate random 8-char string     │
        │     - MD5(random + timestamp)         │
        │     - Take first 8 chars              │
        │     - Convert to uppercase            │
        │     - Example: "X8K2B9D1"             │
        └───────────────────────────────────────┘
                            │
                            ▼
        ┌───────────────────────────────────────┐
        │  3. Construct license code            │
        │     Format: SRJ-{PREFIX}-{RANDOM}     │
        │     Result: "SRJ-PREM-X8K2B9D1"       │
        └───────────────────────────────────────┘
                            │
                            ▼
        ┌───────────────────────────────────────┐
        │  4. Verify uniqueness in database     │
        │     - Check company_subscriptions     │
        │     - Regenerate if exists (rare)     │
        └───────────────────────────────────────┘
                            │
                            ▼
        ┌───────────────────────────────────────┐
        │  5. Save subscription record          │
        │     - unique_license_code             │
        │     - payment_status: PAID            │
        │     - expires_at: calculated          │
        └───────────────────────────────────────┘
                            │
                            ▼
        ┌───────────────────────────────────────┐
        │  6. Return license to admin           │
        │     Admin shares with HR Manager      │
        └───────────────────────────────────────┘
```

---

## Feature Access Check Flow

```
┌──────────────────────────────────────────────────────────────┐
│         USER TRIES TO ACCESS PREMIUM FEATURE                 │
│         (e.g., Live Location Tracking)                       │
└──────────────────────────────────────────────────────────────┘
                            │
                            ▼
        ┌───────────────────────────────────────┐
        │  FRONTEND: FeatureGuard Component     │
        │  - Checks useSubscription context     │
        │  - hasFeatureAccess(feature)          │
        └───────────────────────────────────────┘
                            │
                            ▼
        ┌───────────────────────────────────────┐
        │  CONTEXT: SubscriptionContext          │
        │  - Looks up activeSubscription        │
        │  - Gets features array                │
        │  - Checks if feature in array         │
        └───────────────────────────────────────┘
                            │
        ┌───────────────────┴───────────────────┐
        │                                       │
        ▼                                       ▼
┌──────────────┐                      ┌──────────────────┐
│ GRANTED      │                      │ DENIED           │
├──────────────┤                      ├──────────────────┤
│ - Show       │                      │ - Blur content   │
│   content    │                      │ - Show lock icon │
│ - Full access│                      │ - Upgrade prompt │
└──────────────┘                      └──────────────────┘
                                                │
                                                ▼
                                      ┌──────────────────┐
                                      │ User clicks      │
                                      │ "Upgrade Now"    │
                                      └──────────────────┘
                                                │
                                                ▼
                                      ┌──────────────────┐
                                      │ Redirect to      │
                                      │ /subscription    │
                                      └──────────────────┘
```

---

## Backend API Feature Gate Flow

```
┌──────────────────────────────────────────────────────────────┐
│  POST /api/location/track                                    │
│  (Protected by checkFeatureAccessMiddleware)                 │
└──────────────────────────────────────────────────────────────┘
                            │
                            ▼
        ┌───────────────────────────────────────┐
        │  1. Extract company_id from request   │
        │     - req.body.company_id             │
        │     - OR req.user.company_id          │
        └───────────────────────────────────────┘
                            │
                            ▼
        ┌───────────────────────────────────────┐
        │  2. Query active subscription         │
        │     - payment_status = 'PAID'         │
        │     - expires_at > NOW()              │
        └───────────────────────────────────────┘
                            │
                            ▼
        ┌───────────────────────────────────────┐
        │  3. Check if feature in package       │
        │     - subscription.features           │
        │     - includes(requiredFeature)       │
        └───────────────────────────────────────┘
                            │
        ┌───────────────────┴───────────────────┐
        │                                       │
        ▼                                       ▼
┌──────────────┐                      ┌──────────────────┐
│ HAS ACCESS   │                      │ NO ACCESS        │
├──────────────┤                      ├──────────────────┤
│ next()       │                      │ res.status(403)  │
│ Proceed to   │                      │ {                │
│ route handler│                      │   error: "..."   │
│              │                      │   upgradeReq: T  │
└──────────────┘                      │ }                │
                                      └──────────────────┘
```

---

## Subscription Expiry Handling

```
┌──────────────────────────────────────────────────────────────┐
│                    DAILY CRON JOB                            │
│              (Run at midnight every day)                     │
└──────────────────────────────────────────────────────────────┘
                            │
                            ▼
        ┌───────────────────────────────────────┐
        │  SELECT * FROM company_subscriptions  │
        │  WHERE expires_at < NOW()             │
        │  AND payment_status = 'PAID'          │
        └───────────────────────────────────────┘
                            │
                            ▼
        ┌───────────────────────────────────────┐
        │  UPDATE payment_status = 'EXPIRED'    │
        │  Log expiry in audit_logs             │
        └───────────────────────────────────────┘
                            │
                            ▼
        ┌───────────────────────────────────────┐
        │  Send notification to company         │
        │  - Email to HR Manager                │
        │  - In-app notification                │
        │  - "Your subscription has expired"    │
        └───────────────────────────────────────┘
                            │
                            ▼
        ┌───────────────────────────────────────┐
        │  Features automatically lock          │
        │  - Frontend checks expires_at         │
        │  - Backend middleware blocks access   │
        └───────────────────────────────────────┘
```

---

## Multi-Tenant Security

```
┌──────────────────────────────────────────────────────────────┐
│                  COMPANY ISOLATION                           │
└──────────────────────────────────────────────────────────────┘

Company A (company_id: UUID-A)
├── Subscription: PREMIUM
├── License: SRJ-PREM-ABC123
├── Features: [LIVE_LOCATION_TRACKING, ...]
└── Employees: 100

Company B (company_id: UUID-B)
├── Subscription: FREE_TRIAL
├── License: N/A
├── Features: [BASIC_ATTENDANCE, ...]
└── Employees: 10

┌──────────────────────────────────────────────────────────────┐
│  Company A tries to access Company B's data                  │
└──────────────────────────────────────────────────────────────┘
                            │
                            ▼
        ┌───────────────────────────────────────┐
        │  1. enforceCompanyIsolation()         │
        │     - Checks req.user.company_id      │
        │     - Adds WHERE company_id filter    │
        └───────────────────────────────────────┘
                            │
                            ▼
        ┌───────────────────────────────────────┐
        │  2. Row Level Security (Supabase)     │
        │     - Filters at database level       │
        │     - company_id = auth.company_id    │
        └───────────────────────────────────────┘
                            │
                            ▼
        ┌───────────────────────────────────────┐
        │  Result: Access Denied                │
        │  Company A can only see own data      │
        └───────────────────────────────────────┘
```

---

## Pricing Calculation

```
┌──────────────────────────────────────────────────────────────┐
│                   PRICING FORMULA                            │
└──────────────────────────────────────────────────────────────┘

Total Amount = Price Per Employee Per Day × Employee Count × Duration Days

Example 1: STANDARD Plan
- Price: ₹4/employee/day
- Employees: 50
- Duration: 30 days (1 month)
- Total: ₹4 × 50 × 30 = ₹6,000

Example 2: PREMIUM Plan
- Price: ₹9/employee/day
- Employees: 100
- Duration: 365 days (1 year)
- Total: ₹9 × 100 × 365 = ₹328,500

Example 3: POWER Plan (6 months)
- Price: ₹7/employee/day
- Employees: 25
- Duration: 180 days (6 months)
- Total: ₹7 × 25 × 180 = ₹31,500
```

---

## Implementation Checklist

### ✅ Completed
- [x] Database schema & migration
- [x] Backend API endpoints
- [x] Feature gate middleware
- [x] Frontend context & hooks
- [x] UI components (FeatureGuard, FeatureLockBadge)
- [x] Subscription page integration
- [x] App-level provider setup

### 🔄 In Progress (Your Action)
- [ ] Add FeatureGuard to protected pages
- [ ] Add FeatureLockBadge to navigation
- [ ] Protect backend API routes
- [ ] Create admin subscription panel
- [ ] Create HR license activation UI
- [ ] Add subscription status widget

### 🔮 Future Enhancements
- [ ] Payment gateway integration (Razorpay/Stripe)
- [ ] Automated expiry notifications
- [ ] Usage analytics & reports
- [ ] Subscription renewal automation
- [ ] Proration for plan changes
- [ ] Free trial to paid conversion flow

---

This architecture ensures:
✅ Secure multi-tenant data isolation
✅ Feature-based access control
✅ Scalable pricing model
✅ Clean separation of concerns
✅ Comprehensive audit logging
✅ User-friendly upgrade flows
