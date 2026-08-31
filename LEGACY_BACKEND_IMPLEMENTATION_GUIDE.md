# Legacy Backend Integration - Implementation Guide

**Version:** 1.0
**Date:** January 2024
**Status:** Implementation Ready
**Audience:** Backend Engineers, DevOps, Database Architects

---

## Quick Start (5 Minutes)

### What You'll Build
A secure authentication system that:
- ✅ Accepts legacy user emails and passwords
- ✅ Automatically migrates legacy users to new system
- ✅ Verifies legacy emails without re-verification
- ✅ Routes users to correct IT Dashboard
- ✅ Maintains full backward compatibility

### The Flow
```
User Login with Legacy Email
         ↓
Check New System (already migrated?)
         ↓
If No → Check Legacy System
         ↓
Verify Legacy Password
         ↓
Migrate to New System
         ↓
Mark Email Verified
         ↓
Generate JWT Token
         ↓
Route to IT Dashboard
```

---

## Prerequisites

### Technical Requirements
- Node.js 16+
- PostgreSQL 12+
- Supabase project
- TypeScript knowledge
- Express.js or similar framework

### Environment Variables
```bash
# New System (Supabase)
SUPABASE_URL=https://your-project.supabase.co
SUPABASE_KEY=your-api-key
SUPABASE_SERVICE_KEY=your-service-key

# Legacy System Database
LEGACY_DB_HOST=legacy-db.example.com
LEGACY_DB_USER=legacy_user
LEGACY_DB_PASSWORD=legacy_password
LEGACY_DB_NAME=legacy_hrms

# Legacy Company ID
LEGACY_IT_COMPANY_UUID=uuid-of-it-legacy-company

# Authentication
JWT_SECRET=your-jwt-secret
PASSWORD_HASH_ROUNDS=10
```

---

## Step-by-Step Implementation

### Step 1: Create Database Tables (SQL)

Execute `DATABASE_MIGRATION_LEGACY.sql`:

```sql
-- Key tables created:
1. migration_logs - Track all migrations
2. email_verification_logs - Track email verification
3. legacy_user_mapping - Map legacy users to new users
4. Indexes - For performance optimization
```

**Time:** 2-3 minutes

---

### Step 2: Set Up Services (Node.js)

Use the code from `BACKEND_LEGACY_INTEGRATION_CODE.ts`:

```typescript
// 1. LegacyUserBridgeService
// - Queries legacy database
// - Detects legacy users
// - Verifies legacy passwords

// 2. UserMigrationService
// - Maps old roles to new roles
// - Creates new user records
// - Validates data integrity

// 3. EmailVerificationService
// - Marks emails as verified
// - Logs verification events
// - Tracks verification status

// 4. AuthenticationService
// - Main entry point
// - Coordinates all services
// - 8-step authentication flow

// 5. DashboardRouterService
// - Routes users to correct dashboard
// - Generates sidebar items
// - Handles role-based UI
```

**Time:** 30-45 minutes

---

### Step 3: Implement Middleware

Three key middleware functions:

```typescript
// 1. authMiddleware
// - Validates JWT token
// - Sets user context

// 2. legacyUserCheckMiddleware
// - Adds legacy user info if applicable
// - Enables legacy-specific logic

// 3. roleMiddleware
// - Enforces role-based access
// - Prevents unauthorized access
```

**Time:** 15 minutes

---

### Step 4: Create API Endpoints

Three main endpoints:

```typescript
// 1. POST /auth/login
// - Main authentication endpoint
// - Accepts email and password
// - Returns JWT token and user data

// 2. GET /auth/dashboard-config
// - Returns dashboard path
// - Returns sidebar items
// - Returns legacy status

// 3. POST /auth/refresh
// - Refreshes expired JWT
// - Maintains session
```

**Time:** 15 minutes

---

## Detailed Implementation

### Email Verification Flow

#### Legacy Users (No Re-verification Needed)

```typescript
// User logs in with legacy email
const result = await authService.authenticate(email, password)

// Steps:
// 1. Check if already migrated
// 2. If not → Check legacy system
// 3. Verify password against legacy hash
// 4. Migrate to new system
// 5. Mark email_verified = true (auto-verify)
// 6. Generate JWT token

// Result: User has access immediately
```

#### Verification Levels

**Option 1: Implicit (Recommended for IT)**
- Trust legacy verification
- Auto-verify on first login
- No additional email step
- Faster UX

**Option 2: Explicit (Extra Secure)**
- Send verification email
- User clicks link
- Email marked verified
- Slightly slower but secure

**Option 3: Hybrid (Best Practice)**
- Implicit for normal usage
- Explicit for sensitive operations (password change, etc.)
- Balance security and UX

---

### Data Migration Strategy

#### Phase-Based Approach

```
Phase 1: Assessment
├─ Backup legacy database
├─ Document all relationships
└─ Plan storage strategy

Phase 2: Schema Alignment
├─ Create new tables
├─ Map old → new structures
└─ Design bridging logic

Phase 3: Data Transformation
├─ Create temp transformation table
├─ Map roles
├─ Transform data

Phase 4: Migration
├─ Insert users
├─ Create mappings
├─ Log migrations

Phase 5: Validation
├─ Verify counts
├─ Check data integrity
├─ Identify failures

Phase 6: Optimization
├─ Create indexes
├─ Optimize queries
├─ Performance test
```

---

### Role Mapping

```
Legacy Role          →  New Role              →  Permissions
─────────────────────────────────────────────────────────────
admin                →  admin                 →  All company features
hr                   →  hr_manager            →  HR operations only
employee             →  employee              →  Self-service features
(null/missing)       →  employee              →  Default to employee
```

---

## Testing Strategy

### Unit Tests

```typescript
// Test LegacyUserBridgeService
describe('LegacyUserBridgeService', () => {
  test('isLegacyUser returns true for existing legacy users', async () => {
    const result = await legacyBridge.isLegacyUser('legacy@example.com')
    expect(result).toBe(true)
  })

  test('verifyLegacyPassword validates password correctly', async () => {
    const legacy = await legacyBridge.getLegacyUserByEmail('admin@legacy.com')
    const valid = await legacyBridge.verifyLegacyPassword('password', legacy.password_hash)
    expect(valid).toBe(true)
  })
})

// Test UserMigrationService
describe('UserMigrationService', () => {
  test('mapLegacyRole converts correctly', () => {
    expect(migration.mapLegacyRole('admin')).toBe('admin')
    expect(migration.mapLegacyRole('hr')).toBe('hr_manager')
    expect(migration.mapLegacyRole('employee')).toBe('employee')
  })

  test('migrateLegacyUser creates new user record', async () => {
    const result = await migration.migrateLegacyUser(legacyUser, 'password')
    expect(result).toBeDefined()
    expect(result.legacy_user_id).toBe(legacyUser.id)
  })
})

// Test AuthenticationService
describe('AuthenticationService', () => {
  test('authenticate legacy user on first login', async () => {
    const result = await authService.authenticate('legacy@example.com', 'password')
    expect(result.success).toBe(true)
    expect(result.token).toBeDefined()
  })

  test('authenticate migrated user on second login', async () => {
    const result = await authService.authenticate('legacy@example.com', 'password')
    expect(result.success).toBe(true)
    expect(result.user.legacy_source).toBe('it_backend')
  })
})
```

### Integration Tests

```typescript
// Test complete flow
describe('Legacy Integration Flow', () => {
  test('complete login and dashboard routing', async () => {
    // 1. First login as legacy user
    const auth = await authService.authenticate('john@legacy.com', 'pass123')
    expect(auth.success).toBe(true)

    // 2. Verify user migrated
    const user = await authService.getMigratedUser(auth.user.legacy_user_id)
    expect(user).toBeDefined()

    // 3. Verify dashboard routing
    const router = new DashboardRouterService()
    const dashboard = router.getDashboardPath(auth.user)
    expect(dashboard).toContain('/dashboard')

    // 4. Second login should be faster
    const auth2 = await authService.authenticate('john@legacy.com', 'pass123')
    expect(auth2.success).toBe(true)
  })
})
```

---

## Monitoring & Alerts

### Key Metrics

```typescript
// 1. Migration Rate
metrics.trackMigrationRate() // X users per minute

// 2. Login Success Rate
metrics.trackLoginSuccess() // Target: > 99%

// 3. Login Performance
metrics.trackLoginTime() // Target: < 300ms

// 4. Error Rates
metrics.trackErrors() // Alert if > 1%

// 5. Legacy User Logins
metrics.trackLegacyLogins() // Track X per day
```

### Alert Triggers

```typescript
const alerts = {
  LOGIN_SUCCESS_RATE_LOW: { threshold: 95, severity: 'critical' },
  LOGIN_TIME_HIGH: { threshold: 500, severity: 'warning' },
  MIGRATION_HALTED: { timeout: 60000, severity: 'critical' },
  ERROR_RATE_HIGH: { threshold: 1, severity: 'warning' }
}
```

---

## Troubleshooting

### Issue 1: Legacy Password Verification Fails

**Symptoms:**
- Login fails for legacy users
- Error: "Invalid credentials"

**Solution:**
```typescript
// Ensure legacy database connection is valid
const connection = await legacyPool.getConnection()
const [rows] = await connection.execute(
  'SELECT * FROM legacy_users LIMIT 1'
)
// Should return data successfully
```

### Issue 2: Duplicate Email Errors

**Symptoms:**
- Error when migrating users
- "Duplicate entry for email"

**Solution:**
```sql
-- Check for duplicates in legacy system
SELECT email, COUNT(*) FROM legacy_users
GROUP BY email HAVING COUNT(*) > 1;

-- Handle duplicates before migration:
-- Option 1: Merge duplicate records
-- Option 2: Add suffix to email
-- Option 3: Skip duplicate
```

### Issue 3: Role Mapping Issues

**Symptoms:**
- Users have wrong roles after migration
- Permissions not working

**Solution:**
```typescript
// Verify role mapping
const legacyRole = 'hr'
const mappedRole = migration.mapLegacyRole(legacyRole)
console.log(`${legacyRole} → ${mappedRole}`)

// Check database
SELECT role, COUNT(*) FROM users 
WHERE company_id = 'legacy-company-id'
GROUP BY role
```

### Issue 4: Performance Degradation

**Symptoms:**
- Login time increases
- Database queries slow

**Solution:**
```typescript
// 1. Check indexes exist
SELECT * FROM pg_indexes 
WHERE tablename IN ('users', 'legacy_user_mapping');

// 2. Verify index usage
EXPLAIN ANALYZE
SELECT * FROM users 
WHERE email = 'test@example.com' 
AND company_id = 'company-uuid';

// 3. Add missing indexes
CREATE INDEX idx_users_email_company 
ON users(email, company_id);
```

---

## Rollback Procedure

### If Migration Fails

```typescript
// Step 1: Stop accepting new logins
authenticator.setMigrationMode('READONLY')

// Step 2: Delete migrated data
DELETE FROM users WHERE legacy_source = 'it_backend'
DELETE FROM legacy_user_mapping
DELETE FROM migration_logs

// Step 3: Restore from backup
await database.restoreFromBackup('pre-migration-backup')

// Step 4: Verify restoration
const count = await database.query('SELECT COUNT(*) FROM legacy_users')
console.log(`Restored ${count} users`)

// Step 5: Notify stakeholders
await notification.sendAlert('Migration rollback completed')
```

---

## Performance Optimization

### Caching Strategy

```typescript
// Cache legacy user lookups (5 min TTL)
const legacyUserCache = new Map()

async function getLegacyUserCached(email) {
  const cached = legacyUserCache.get(email)
  if (cached && Date.now() - cached.timestamp < 300000) {
    return cached.data
  }

  const data = await legacyBridge.getLegacyUserByEmail(email)
  legacyUserCache.set(email, { data, timestamp: Date.now() })
  return data
}

// Cache role mapping (persistent)
const roleMapCache = {
  'admin': 'admin',
  'hr': 'hr_manager',
  'employee': 'employee'
}

// Clear cache on deployment
function clearCaches() {
  legacyUserCache.clear()
  // roleMapCache is persistent, don't clear
}
```

### Query Optimization

```typescript
// Batch queries instead of individual lookups
async function getManyLegacyUsers(emails) {
  const placeholders = emails.map(() => '?').join(',')
  const [rows] = await legacyPool.execute(
    `SELECT * FROM legacy_users WHERE email IN (${placeholders})`,
    emails
  )
  return rows
}

// Use connection pooling
const pool = mysql.createPool({
  host: process.env.LEGACY_DB_HOST,
  connectionLimit: 10,
  waitForConnections: true,
  queueLimit: 0
})
```

---

## Deployment Checklist

### Pre-Deployment
- [ ] Backup legacy database
- [ ] Backup new system database
- [ ] Test all services locally
- [ ] Test with staging data
- [ ] Security audit completed
- [ ] Performance testing done
- [ ] Team trained on procedures

### Deployment
- [ ] Deploy code to staging
- [ ] Run smoke tests
- [ ] Deploy to production
- [ ] Monitor logs in real-time
- [ ] Test with real users (canary)
- [ ] Gradual rollout to 100%

### Post-Deployment
- [ ] Monitor login success rate
- [ ] Check error logs
- [ ] Verify email verification
- [ ] Test dashboard routing
- [ ] Review audit logs
- [ ] Document any issues
- [ ] Plan improvements

---

## Next Steps

1. **Review Code** - Read through BACKEND_LEGACY_INTEGRATION_CODE.ts
2. **Prepare Database** - Execute DATABASE_MIGRATION_LEGACY.sql
3. **Install Dependencies** - npm install
4. **Configure Environment** - Set all .env variables
5. **Run Tests** - npm run test
6. **Deploy to Staging** - npm run deploy:staging
7. **Test Thoroughly** - Execute all test scenarios
8. **Deploy to Production** - npm run deploy:prod
9. **Monitor** - Watch metrics for 24+ hours
10. **Optimize** - Fine-tune based on real usage

---

## Resources

### Files Provided
1. **LEGACY_BACKEND_INTEGRATION_STRATEGY.md** - Architecture and design
2. **BACKEND_LEGACY_INTEGRATION_CODE.ts** - Complete implementation
3. **DATABASE_MIGRATION_LEGACY.sql** - Database migration script
4. **LEGACY_BACKEND_IMPLEMENTATION_GUIDE.md** - This guide

### External Resources
- [Bcrypt Documentation](https://github.com/kelektiv/node.bcrypt.js)
- [JWT Guide](https://jwt.io/)
- [Supabase Auth](https://supabase.com/docs/guides/auth)
- [PostgreSQL Migration](https://www.postgresql.org/docs/)

---

## Support

### Common Questions

**Q: How long does migration take?**
A: Depends on user count. ~1000 users = 5-10 minutes

**Q: Will users be locked out?**
A: No, seamless login without re-verification

**Q: Can we rollback?**
A: Yes, complete rollback procedure documented

**Q: What about performance?**
A: Expected +50-100ms on login, stabilizes after cache warmup

**Q: Is data safe?**
A: All data preserved, complete audit trail maintained

---

**Implementation Status:** Ready to Deploy
**Last Updated:** January 2024
**Next Review:** After staging validation
