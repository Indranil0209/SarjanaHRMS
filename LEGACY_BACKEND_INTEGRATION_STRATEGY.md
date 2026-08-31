# Legacy IT Backend Integration Strategy

**Version:** 1.0
**Date:** January 2024
**Status:** Design Document
**Project:** SarjanaHRMS Multi-Tenant Migration

---

## Executive Summary

This document outlines the comprehensive strategy for integrating the legacy IT backend into the new multi-tenant, multi-sector SarjanaHRMS architecture while maintaining:

✅ **Full backward compatibility** with existing users
✅ **Zero data loss** from legacy system
✅ **Seamless login experience** for legacy users
✅ **Clean separation** between legacy and new data
✅ **Gradual migration path** to new architecture

---

## Table of Contents

1. [Current State Analysis](#current-state-analysis)
2. [Target Architecture](#target-architecture)
3. [Data Migration Strategy](#data-migration-strategy)
4. [Email Verification Workflow](#email-verification-workflow)
5. [Backend Implementation](#backend-implementation)
6. [Code Examples](#code-examples)
7. [Testing & Validation](#testing--validation)
8. [Rollback Plan](#rollback-plan)

---

## Current State Analysis

### Legacy System Components

```
Legacy IT Backend
├── User Management
│   ├── Users table (with old email format)
│   ├── Roles (basic admin/hr/employee)
│   ├── Authentication (JWT/Sessions)
│   └── Email verification (basic)
├── Data Structure
│   ├── Employees
│   ├── Departments
│   ├── Attendance
│   ├── Payroll
│   └── Leave Requests
└── Infrastructure
    ├── Database (MySQL/PostgreSQL)
    ├── API (REST endpoints)
    └── Authentication (custom or OAuth)
```

### Key Assumptions

- Legacy system has users with verified emails
- User roles exist but may be mapped differently
- Email is the unique identifier in legacy system
- Data integrity is critical
- No users should be locked out during migration

---

## Target Architecture

### New Multi-Tenant Structure

```
New Architecture
├── Multi-Tenant Support
│   ├── Companies table
│   ├── Users (linked to companies)
│   └── Sectors (IT, Non-IT)
├── Role-Based Access Control
│   ├── Super Admin (platform-wide)
│   ├── Admin (company-level)
│   ├── HR Manager
│   └── Employee
├── Data Organization
│   ├── Company-isolated data
│   ├── Sector-specific features
│   └── Historical data preservation
└── Authentication
    ├── Email verification
    ├── Legacy user bridge
    ├── Multi-factor authentication (future)
    └── Session management
```

---

## Data Migration Strategy

### Phase 1: Assessment & Backup

**Before any migration:**
1. Create complete backup of legacy database
2. Document all data relationships
3. Identify data gaps or anomalies
4. Plan storage strategy

**Database Inventory:**
```sql
-- Legacy system analysis queries
SELECT TABLE_NAME, 
       COUNT(*) as row_count,
       COLUMN_COUNT
FROM INFORMATION_SCHEMA.TABLES
WHERE TABLE_SCHEMA = 'legacy_db'
GROUP BY TABLE_NAME;
```

### Phase 2: Schema Alignment

#### Legacy User Structure (Example)
```sql
-- Legacy users table
CREATE TABLE legacy_users (
    id INT PRIMARY KEY AUTO_INCREMENT,
    email VARCHAR(255) UNIQUE NOT NULL,
    password_hash VARCHAR(255) NOT NULL,
    first_name VARCHAR(100),
    last_name VARCHAR(100),
    role ENUM('admin', 'hr', 'employee') DEFAULT 'employee',
    is_active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP,
    updated_at TIMESTAMP,
    last_login TIMESTAMP
);
```

#### New User Structure (Example)
```sql
-- New users table with multi-tenant support
CREATE TABLE users (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    email VARCHAR(255) NOT NULL,
    password_hash VARCHAR(255) NOT NULL,
    full_name VARCHAR(255),
    company_id UUID NOT NULL REFERENCES companies(id),
    role ENUM('super_admin', 'admin', 'hr_manager', 'employee') DEFAULT 'employee',
    company_type ENUM('it', 'non-it') NOT NULL,
    is_active BOOLEAN DEFAULT TRUE,
    email_verified BOOLEAN DEFAULT FALSE,
    legacy_user_id INT, -- Link to legacy system
    legacy_source ENUM('it_backend', 'native') DEFAULT 'native',
    migration_date TIMESTAMP,
    created_at TIMESTAMP,
    updated_at TIMESTAMP,
    UNIQUE(email, company_id) -- Email unique per company
);
```

### Phase 3: Data Mapping Rules

#### Role Mapping Strategy

```
Legacy Role          →  New Role (IT Company)  →  Permissions
─────────────────────────────────────────────────────────────
admin                →  admin                  →  All IT features
hr                   →  hr_manager             →  HR operations
employee             →  employee               →  Employee features
(none/null)          →  employee               →  Default employee
```

#### Company Assignment for Legacy Users

```
Strategy: Create an "IT Legacy" company container

1. Create company: "IT_LEGACY_COMPANY"
   - company_id: uuid
   - company_name: "Legacy IT Company"
   - company_type: "it"
   - status: "active"
   - is_legacy: true

2. Migrate all legacy users to this company
3. Link legacy user IDs for tracking
4. Preserve all historical data relationships
```

### Phase 4: Migration Script Structure

```
Migration Steps:
1. Backup legacy database → external storage
2. Create new company record for legacy data
3. Transform users:
   - Map roles
   - Create new user records
   - Link legacy_user_id
   - Set legacy_source flag
4. Migrate related data:
   - Employees table
   - Departments
   - Roles and permissions
   - Historical records (attendance, payroll, etc.)
5. Verify data integrity
6. Enable legacy bridge authentication
7. Run parallel systems (optional)
8. Cutover when verified
```

---

## Email Verification Workflow

### Design Principles

```
1. Security First
   - No plaintext email transmission
   - Hash comparison for verification
   - Rate limiting on verification attempts

2. Backward Compatibility
   - Legacy users already verified in old system
   - New system recognizes legacy verification
   - No re-verification required on first login

3. Audit Trail
   - Log all verification attempts
   - Track email changes
   - Maintain historical record
```

### Legacy Email Verification Flow

```
┌─────────────────────────────────────────────────────────┐
│ User Attempts Login with Legacy Email                   │
└──────────────────────┬──────────────────────────────────┘
                       │
                       ▼
┌─────────────────────────────────────────────────────────┐
│ 1. Check if email exists in new system                  │
│    - Look in users table (email, company_id)            │
│    - Query: WHERE email = ? AND company_id = ?          │
└──────────────────────┬──────────────────────────────────┘
                       │
            ┌──────────┴──────────┐
            ▼                     ▼
       YES: Continue         NO: Check Legacy
                               │
                               ▼
                    ┌─────────────────────────┐
                    │ Query legacy_users      │
                    │ WHERE email = ?         │
                    └─────────┬───────────────┘
                              │
                    ┌─────────┴──────────┐
                    ▼                    ▼
                Found             Not Found
                    │                    │
                    ▼                    ▼
            ┌─────────────────┐  ┌──────────────┐
            │ Verify Password │  │ Return Error │
            │ Against Legacy  │  │ Invalid Creds│
            └────────┬────────┘  └──────────────┘
                     │
         ┌───────────┴───────────┐
         ▼                       ▼
    Password OK         Password Invalid
         │                       │
         ▼                       ▼
    ┌──────────────┐     ┌──────────────┐
    │ Migrate User │     │ Return Error │
    │ to New System│     │ Try Again    │
    └────────┬─────┘     └──────────────┘
             │
             ▼
    ┌──────────────────────┐
    │ Verify Email in DB   │
    │ Set email_verified=1 │
    │ Set legacy_source    │
    │ Create JWT token     │
    │ Return Success       │
    └──────────────────────┘
```

### Email Verification Logic

```
Verification Approach:

Option 1: Implicit Verification (Recommended)
├─ Legacy users trusted (already verified in old system)
├─ First login triggers automatic migration
├─ Email marked as verified
└─ No additional email check required

Option 2: Explicit Verification (Extra Secure)
├─ Send verification email to legacy user
├─ User clicks link (same as new users)
├─ Email marked as verified
├─ Access granted
└─ Slightly slower but more secure

Option 3: Hybrid Verification (Best Practice)
├─ For IT Sector: Implicit (trust legacy verification)
├─ For sensitive operations: Re-verify if needed
├─ Option to upgrade security later
└─ Balance security and UX
```

---

## Backend Implementation

### Architecture Overview

```
New Login Request
      │
      ▼
┌─────────────────────────────────────┐
│ Authentication Middleware           │
│ (Check credentials)                 │
└─────────────┬───────────────────────┘
              │
              ▼
┌─────────────────────────────────────┐
│ Legacy User Bridge Service          │
│ (Check if legacy user)              │
└─────────────┬───────────────────────┘
              │
              ▼
┌─────────────────────────────────────┐
│ User Migration Service              │
│ (Migrate legacy → new system)       │
└─────────────┬───────────────────────┘
              │
              ▼
┌─────────────────────────────────────┐
│ Email Verification Service          │
│ (Mark email as verified)            │
└─────────────┬───────────────────────┘
              │
              ▼
┌─────────────────────────────────────┐
│ Session/JWT Generation              │
│ (Create auth token)                 │
└─────────────┬───────────────────────┘
              │
              ▼
┌─────────────────────────────────────┐
│ Dashboard Router                    │
│ (Route to IT Dashboard)             │
└─────────────────────────────────────┘
```

### Key Services to Implement

#### 1. Legacy User Bridge Service
```
Purpose: Detect and handle legacy users

Methods:
- isLegacyUser(email): Check if user exists in legacy system
- migrateLegacyUser(legacyUser): Migrate to new system
- getLegacyUserData(email): Fetch data from legacy DB
- verifyLegacyPassword(email, password): Validate legacy password
```

#### 2. Email Verification Service
```
Purpose: Manage email verification for legacy users

Methods:
- markEmailAsVerified(userId): Mark email verified
- checkEmailVerified(email): Check if email is verified
- getVerificationStatus(userId): Get full verification status
- logVerificationAttempt(email, status): Audit logging
```

#### 3. User Migration Service
```
Purpose: Handle user data migration

Methods:
- migrateLegacyUser(legacyUserId, newCompanyId)
- createNewUserRecord(legacyData, companyId)
- mapLegacyRole(legacyRole): Map old roles to new
- preserveLegacyData(legacyUserId, newUserId)
```

#### 4. Dashboard Router
```
Purpose: Route verified users to correct dashboard

Methods:
- routeByCompanyType(user): Route to IT or Non-IT dashboard
- routeByRole(user): Route to role-based dashboard
- getDefaultDashboard(sector, role): Get dashboard path
```

---

## Code Examples

### Backend Implementation (Node.js + Supabase)

See: [BACKEND_LEGACY_INTEGRATION.md](./BACKEND_LEGACY_INTEGRATION.md)
Contains complete code examples with:
- Authentication middleware
- Legacy user bridge
- Migration logic
- Email verification
- Error handling

### Database Migration Script

See: [DATABASE_MIGRATION_SCRIPT.sql](./DATABASE_MIGRATION_SCRIPT.sql)
Contains complete SQL with:
- Schema creation
- Data transformation
- Role mapping
- Data validation

---

## Testing & Validation

### Pre-Migration Testing

```
1. Unit Tests
   ├─ Legacy user detection
   ├─ Password verification
   ├─ Role mapping
   └─ Email verification

2. Integration Tests
   ├─ End-to-end login flow
   ├─ Data migration accuracy
   ├─ Dashboard routing
   └─ Permission preservation

3. Data Validation Tests
   ├─ Data integrity checks
   ├─ Relationship verification
   ├─ Duplicate detection
   └─ Referential integrity
```

### Migration Validation Checklist

```
☐ All legacy users migrated
☐ All emails verified
☐ All roles correctly mapped
☐ All historical data preserved
☐ Dashboard routing working
☐ Permissions intact
☐ Session management working
☐ Audit logging complete
☐ Performance acceptable
☐ Rollback tested
```

---

## Rollback Plan

### Rollback Strategy

```
Level 1: Application Rollback
├─ Switch traffic back to legacy authentication
├─ Disable new system routes
└─ Restore old API endpoints

Level 2: Database Rollback
├─ Stop new writes
├─ Restore backup
├─ Verify data integrity
└─ Resume legacy system

Level 3: Full Rollback
├─ Stop all services
├─ Restore from complete backup
├─ Verify all systems functional
└─ Communicate with users
```

### Rollback Triggers

```
Critical Issues:
├─ > 5% users unable to login
├─ Data corruption detected
├─ Performance degradation > 50%
├─ Security vulnerabilities found
└─ Major features broken
```

---

## Security Considerations

### Password Handling

```
✅ Hash passwords with bcrypt
✅ Never store plaintext passwords
✅ Use salt for legacy passwords
✅ Rotate passwords on first new login
✅ Implement rate limiting
✅ Log authentication attempts
```

### Data Privacy

```
✅ Encrypt sensitive data in transit
✅ Use HTTPS for all communications
✅ Implement access controls
✅ Log all data access
✅ GDPR compliance
✅ Data retention policies
```

### Audit Trail

```
All activities logged:
├─ Login attempts (success/failure)
├─ User migrations
├─ Email verifications
├─ Dashboard access
├─ Data changes
└─ Error events

Retention: Minimum 1 year
```

---

## Performance Considerations

### Optimization Strategies

```
Database Level:
├─ Index on email column
├─ Index on company_id + email
├─ Composite indexes for joins
└─ Query optimization

Application Level:
├─ Cache legacy user lookup
├─ Connection pooling
├─ Async migration (background)
└─ Rate limiting

Caching Strategy:
├─ User data cache (5 min TTL)
├─ Session cache (1 hour)
├─ Role cache (persistent)
└─ Invalidation on changes
```

### Expected Performance Impact

```
Before Migration: ~200ms per login
After Migration:  ~250-300ms per login
  - Legacy lookup: +30ms
  - Migration check: +20ms
  - Email verification: +20ms
  - Caching benefit: -50ms average

Target: Stabilize at <250ms after cache warmup
```

---

## Monitoring & Alerts

### Key Metrics to Track

```
1. Login Success Rate
   - Target: > 99%
   - Alert if: < 95%

2. Average Login Time
   - Target: < 300ms
   - Alert if: > 500ms

3. Migration Rate
   - Track: X users per minute
   - Alert if: Halts

4. Error Rates
   - Track: By error type
   - Alert if: > 1% total errors

5. Legacy User Logins
   - Track: X per day
   - Monitor: Migration progress
```

---

## Rollout Timeline

```
Phase 1: Development (Week 1-2)
├─ Design finalization
├─ Code development
├─ Unit testing
└─ Integration testing

Phase 2: Staging (Week 3)
├─ Deploy to staging
├─ Full test suite
├─ Performance testing
└─ Security audit

Phase 3: Canary Deployment (Week 4)
├─ Deploy to 10% users
├─ Monitor metrics
├─ Gather feedback
└─ Gradual rollout

Phase 4: Full Production (Week 5)
├─ Deploy to all users
├─ Monitor 24/7
├─ Support team on standby
└─ Log all activities

Phase 5: Stabilization (Week 6)
├─ Monitor stability
├─ Address issues
├─ Optimize performance
└─ Plan Phase 2 improvements
```

---

## Next Steps

1. **Review Architecture** - Get stakeholder approval
2. **Design Database** - Create detailed schema
3. **Develop Services** - Implement backend logic
4. **Write Tests** - Comprehensive test suite
5. **Load Test** - Test with production-like data
6. **Dry Run** - Full migration simulation
7. **Execute Migration** - Live production migration
8. **Validate** - Confirm all data migrated correctly
9. **Monitor** - 24/7 monitoring for issues
10. **Optimize** - Fine-tune based on real usage

---

## Appendices

### A. Database Schema Alignment
See: DATABASE_SCHEMA_ALIGNMENT.md

### B. Backend Implementation
See: BACKEND_LEGACY_INTEGRATION.md

### C. Migration Scripts
See: DATABASE_MIGRATION_SCRIPT.sql

### D. Testing Strategy
See: TESTING_STRATEGY.md

### E. Security Checklist
See: SECURITY_CHECKLIST.md

---

**Document Status:** Ready for Development
**Last Updated:** January 2024
**Next Review:** After design approval
