/**
 * Legacy IT Backend Integration - Complete Backend Implementation
 * 
 * This file contains all backend services, middleware, and logic
 * for integrating legacy users into the new multi-tenant architecture.
 * 
 * Technologies: Node.js, TypeScript, Supabase, PostgreSQL
 */

import { createClient } from '@supabase/supabase-js'
import bcrypt from 'bcrypt'
import jwt from 'jsonwebtoken'
import { Request, Response, NextFunction } from 'express'

// ============================================================================
// 1. CONFIGURATION & SETUP
// ============================================================================

// Supabase client for new system
const supabase = createClient(
  process.env.SUPABASE_URL,
  process.env.SUPABASE_KEY
)

// Legacy database connection
import mysql from 'mysql2/promise'
const legacyPool = mysql.createPool({
  host: process.env.LEGACY_DB_HOST,
  user: process.env.LEGACY_DB_USER,
  password: process.env.LEGACY_DB_PASSWORD,
  database: process.env.LEGACY_DB_NAME,
  waitForConnections: true,
  connectionLimit: 10,
  queueLimit: 0
})

// Constants
const LEGACY_COMPANY_ID = process.env.LEGACY_IT_COMPANY_UUID
const JWT_SECRET = process.env.JWT_SECRET
const PASSWORD_HASH_ROUNDS = 10
const TOKEN_EXPIRY = '7d'

// ============================================================================
// 2. TYPE DEFINITIONS
// ============================================================================

interface LegacyUser {
  id: number
  email: string
  password_hash: string
  first_name: string
  last_name: string
  role: 'admin' | 'hr' | 'employee'
  is_active: boolean
  created_at: string
}

interface NewUser {
  id: string
  email: string
  password_hash: string
  full_name: string
  company_id: string
  role: 'super_admin' | 'admin' | 'hr_manager' | 'employee'
  company_type: 'it' | 'non-it'
  is_active: boolean
  email_verified: boolean
  legacy_user_id: number | null
  legacy_source: 'it_backend' | 'native'
  migration_date: string
}

interface AuthRequest extends Request {
  user?: NewUser
  legacyUser?: LegacyUser
}

// ============================================================================
// 3. LEGACY USER BRIDGE SERVICE
// ============================================================================

/**
 * LegacyUserBridgeService
 * Handles detection and interaction with legacy users
 */
class LegacyUserBridgeService {
  /**
   * Check if user exists in legacy system
   */
  async isLegacyUser(email: string): Promise<boolean> {
    try {
      const connection = await legacyPool.getConnection()
      const [rows] = await connection.execute(
        'SELECT id FROM legacy_users WHERE email = ?',
        [email]
      )
      connection.release()
      return rows.length > 0
    } catch (error) {
      console.error('Error checking legacy user:', error)
      return false
    }
  }

  /**
   * Fetch legacy user data by email
   */
  async getLegacyUserByEmail(email: string): Promise<LegacyUser | null> {
    try {
      const connection = await legacyPool.getConnection()
      const [rows] = await connection.execute(
        `SELECT id, email, password_hash, first_name, last_name, 
                role, is_active, created_at 
         FROM legacy_users WHERE email = ? AND is_active = true`,
        [email]
      )
      connection.release()

      if (rows.length === 0) return null
      return rows[0] as LegacyUser
    } catch (error) {
      console.error('Error fetching legacy user:', error)
      return null
    }
  }

  /**
   * Verify legacy password using bcrypt
   * (assumes legacy system uses bcrypt for hashing)
   */
  async verifyLegacyPassword(password: string, hash: string): Promise<boolean> {
    try {
      return await bcrypt.compare(password, hash)
    } catch (error) {
      console.error('Error verifying legacy password:', error)
      return false
    }
  }

  /**
   * Check if user is already migrated to new system
   */
  async isMigrated(legacyUserId: number): Promise<boolean> {
    try {
      const { data, error } = await supabase
        .from('users')
        .select('id')
        .eq('legacy_user_id', legacyUserId)
        .single()

      if (error && error.code === 'PGRST116') {
        // Not found - not migrated
        return false
      }

      return data !== null
    } catch (error) {
      console.error('Error checking migration status:', error)
      return false
    }
  }

  /**
   * Get migrated user if exists
   */
  async getMigratedUser(legacyUserId: number): Promise<NewUser | null> {
    try {
      const { data, error } = await supabase
        .from('users')
        .select('*')
        .eq('legacy_user_id', legacyUserId)
        .single()

      if (error || !data) return null
      return data as NewUser
    } catch (error) {
      console.error('Error fetching migrated user:', error)
      return null
    }
  }
}

// ============================================================================
// 4. USER MIGRATION SERVICE
// ============================================================================

/**
 * UserMigrationService
 * Handles migration of legacy users to new system
 */
class UserMigrationService {
  /**
   * Map legacy role to new role
   */
  mapLegacyRole(legacyRole: string): 'admin' | 'hr_manager' | 'employee' {
    const roleMap = {
      admin: 'admin',
      hr: 'hr_manager',
      employee: 'employee'
    }
    return roleMap[legacyRole] || 'employee'
  }

  /**
   * Create password hash for new system
   */
  async hashPassword(password: string): Promise<string> {
    return bcrypt.hash(password, PASSWORD_HASH_ROUNDS)
  }

  /**
   * Migrate legacy user to new system
   */
  async migrateLegacyUser(legacyUser: LegacyUser, password: string): Promise<NewUser | null> {
    try {
      const newRole = this.mapLegacyRole(legacyUser.role)

      // Create new user record
      const { data: newUser, error: insertError } = await supabase
        .from('users')
        .insert([
          {
            email: legacyUser.email,
            password_hash: legacyUser.password_hash, // Use legacy hash initially
            full_name: `${legacyUser.first_name} ${legacyUser.last_name}`.trim(),
            company_id: LEGACY_COMPANY_ID,
            role: newRole,
            company_type: 'it',
            is_active: legacyUser.is_active,
            email_verified: true, // Trust legacy verification
            legacy_user_id: legacyUser.id,
            legacy_source: 'it_backend',
            migration_date: new Date().toISOString()
          }
        ])
        .select()
        .single()

      if (insertError) {
        console.error('Error creating user in new system:', insertError)
        return null
      }

      // Log migration
      await this.logMigration(legacyUser.id, newUser.id, 'SUCCESS')

      return newUser as NewUser
    } catch (error) {
      console.error('Error migrating legacy user:', error)
      await this.logMigration(legacyUser.id, null, 'FAILED', error.message)
      return null
    }
  }

  /**
   * Log migration attempt
   */
  private async logMigration(
    legacyUserId: number,
    newUserId: string | null,
    status: 'SUCCESS' | 'FAILED',
    errorMessage?: string
  ) {
    try {
      await supabase
        .from('migration_logs')
        .insert([
          {
            legacy_user_id: legacyUserId,
            new_user_id: newUserId,
            status,
            error_message: errorMessage,
            migrated_at: new Date().toISOString()
          }
        ])
    } catch (error) {
      console.error('Error logging migration:', error)
    }
  }

  /**
   * Verify legacy user data integrity
   */
  async verifyUserData(legacyUser: LegacyUser, newUser: NewUser): Promise<boolean> {
    const checks = {
      emailMatch: legacyUser.email === newUser.email,
      roleMatch: this.mapLegacyRole(legacyUser.role) === newUser.role,
      nameMatch: `${legacyUser.first_name} ${legacyUser.last_name}`.trim() === newUser.full_name,
      legacyLinked: newUser.legacy_user_id === legacyUser.id,
      companyMatch: newUser.company_id === LEGACY_COMPANY_ID,
      companyType: newUser.company_type === 'it'
    }

    const allChecks = Object.values(checks).every(check => check === true)
    
    if (!allChecks) {
      console.warn('Data integrity check failed:', checks)
    }

    return allChecks
  }
}

// ============================================================================
// 5. EMAIL VERIFICATION SERVICE
// ============================================================================

/**
 * EmailVerificationService
 * Manages email verification for legacy and new users
 */
class EmailVerificationService {
  /**
   * Mark email as verified for user
   */
  async markEmailAsVerified(userId: string): Promise<boolean> {
    try {
      const { error } = await supabase
        .from('users')
        .update({ email_verified: true })
        .eq('id', userId)

      if (error) {
        console.error('Error marking email as verified:', error)
        return false
      }

      // Log verification event
      await this.logVerificationEvent(userId, 'VERIFIED', 'Legacy user auto-verified')
      return true
    } catch (error) {
      console.error('Error in markEmailAsVerified:', error)
      return false
    }
  }

  /**
   * Check if email is verified
   */
  async isEmailVerified(email: string, companyId: string): Promise<boolean> {
    try {
      const { data, error } = await supabase
        .from('users')
        .select('email_verified')
        .eq('email', email)
        .eq('company_id', companyId)
        .single()

      if (error) return false
      return data?.email_verified === true
    } catch (error) {
      console.error('Error checking email verification:', error)
      return false
    }
  }

  /**
   * Get verification status
   */
  async getVerificationStatus(userId: string): Promise<{
    verified: boolean
    verifiedAt?: string
    verificationMethod?: string
  }> {
    try {
      const { data, error } = await supabase
        .from('users')
        .select('email_verified, created_at')
        .eq('id', userId)
        .single()

      if (error) {
        return { verified: false }
      }

      return {
        verified: data?.email_verified === true,
        verifiedAt: data?.created_at,
        verificationMethod: 'legacy_system'
      }
    } catch (error) {
      console.error('Error getting verification status:', error)
      return { verified: false }
    }
  }

  /**
   * Log verification event for audit trail
   */
  private async logVerificationEvent(
    userId: string,
    status: string,
    reason: string
  ) {
    try {
      await supabase
        .from('email_verification_logs')
        .insert([
          {
            user_id: userId,
            status,
            reason,
            verified_at: new Date().toISOString()
          }
        ])
    } catch (error) {
      console.error('Error logging verification event:', error)
    }
  }
}

// ============================================================================
// 6. AUTHENTICATION SERVICE
// ============================================================================

/**
 * AuthenticationService
 * Main authentication logic with legacy support
 */
class AuthenticationService {
  private legacyBridge: LegacyUserBridgeService
  private migration: UserMigrationService
  private verification: EmailVerificationService

  constructor() {
    this.legacyBridge = new LegacyUserBridgeService()
    this.migration = new UserMigrationService()
    this.verification = new EmailVerificationService()
  }

  /**
   * Authenticate user (legacy or new)
   * This is the main entry point for login
   */
  async authenticate(email: string, password: string): Promise<{
    success: boolean
    user?: NewUser
    token?: string
    error?: string
  }> {
    try {
      email = email.toLowerCase().trim()

      // STEP 1: Check if user exists in new system
      console.log(`[AUTH] Step 1: Checking new system for ${email}`)
      let newUser = await this.getNewSystemUser(email)

      if (newUser) {
        // User already migrated, proceed with normal auth
        console.log(`[AUTH] Step 2: User exists in new system`)
        const isPasswordValid = await this.verifyPassword(password, newUser.password_hash)
        
        if (!isPasswordValid) {
          return {
            success: false,
            error: 'Invalid credentials'
          }
        }

        // Ensure email is verified
        if (!newUser.email_verified) {
          await this.verification.markEmailAsVerified(newUser.id)
          newUser = { ...newUser, email_verified: true }
        }

        // Generate token and return
        const token = this.generateJWT(newUser)
        return { success: true, user: newUser, token }
      }

      // STEP 2: Check if user is legacy
      console.log(`[AUTH] Step 2: Checking legacy system for ${email}`)
      const isLegacy = await this.legacyBridge.isLegacyUser(email)

      if (!isLegacy) {
        return {
          success: false,
          error: 'User not found'
        }
      }

      // STEP 3: Fetch legacy user
      console.log(`[AUTH] Step 3: Fetching legacy user data`)
      const legacyUser = await this.legacyBridge.getLegacyUserByEmail(email)

      if (!legacyUser) {
        return {
          success: false,
          error: 'User not found'
        }
      }

      // STEP 4: Verify legacy password
      console.log(`[AUTH] Step 4: Verifying legacy password`)
      const isPasswordValid = await this.legacyBridge.verifyLegacyPassword(
        password,
        legacyUser.password_hash
      )

      if (!isPasswordValid) {
        return {
          success: false,
          error: 'Invalid credentials'
        }
      }

      // STEP 5: Migrate legacy user to new system
      console.log(`[AUTH] Step 5: Migrating legacy user`)
      const migratedUser = await this.migration.migrateLegacyUser(legacyUser, password)

      if (!migratedUser) {
        return {
          success: false,
          error: 'Migration failed. Please try again.'
        }
      }

      // STEP 6: Verify data integrity
      console.log(`[AUTH] Step 6: Verifying data integrity`)
      const isIntegrityOK = await this.migration.verifyUserData(legacyUser, migratedUser)

      if (!isIntegrityOK) {
        console.warn(`[AUTH] Data integrity check failed for ${email}`)
        // Log but allow login
      }

      // STEP 7: Mark email as verified
      console.log(`[AUTH] Step 7: Marking email as verified`)
      await this.verification.markEmailAsVerified(migratedUser.id)

      // STEP 8: Generate JWT token
      console.log(`[AUTH] Step 8: Generating JWT token`)
      const token = this.generateJWT(migratedUser)

      console.log(`[AUTH] ✅ Authentication successful for ${email}`)
      return { success: true, user: migratedUser, token }
    } catch (error) {
      console.error('[AUTH] Authentication error:', error)
      return {
        success: false,
        error: 'Authentication error. Please try again.'
      }
    }
  }

  /**
   * Get user from new system
   */
  private async getNewSystemUser(email: string): Promise<NewUser | null> {
    try {
      const { data, error } = await supabase
        .from('users')
        .select('*')
        .eq('email', email)
        .eq('company_id', LEGACY_COMPANY_ID)
        .single()

      if (error) return null
      return data as NewUser
    } catch (error) {
      console.error('Error fetching new system user:', error)
      return null
    }
  }

  /**
   * Verify password (handles both legacy and new hashes)
   */
  private async verifyPassword(password: string, hash: string): Promise<boolean> {
    try {
      return await bcrypt.compare(password, hash)
    } catch (error) {
      console.error('Error verifying password:', error)
      return false
    }
  }

  /**
   * Generate JWT token
   */
  private generateJWT(user: NewUser): string {
    return jwt.sign(
      {
        userId: user.id,
        email: user.email,
        companyId: user.company_id,
        role: user.role,
        companyType: user.company_type,
        isLegacy: user.legacy_source === 'it_backend'
      },
      JWT_SECRET,
      { expiresIn: TOKEN_EXPIRY }
    )
  }
}

// ============================================================================
// 7. DASHBOARD ROUTER SERVICE
// ============================================================================

/**
 * DashboardRouterService
 * Routes authenticated users to appropriate dashboard
 */
class DashboardRouterService {
  /**
   * Get dashboard path based on user profile
   */
  getDashboardPath(user: NewUser): string {
    // Route by company type
    if (user.company_type === 'non-it') {
      return '/dashboard/non-it'
    }

    // IT company routing by role
    switch (user.role) {
      case 'admin':
      case 'super_admin':
        return '/dashboard/admin'
      case 'hr_manager':
        return '/dashboard/hr'
      case 'employee':
      default:
        return '/dashboard/employee'
    }
  }

  /**
   * Get role-based sidebar items
   */
  getSidebarItems(user: NewUser): MenuItem[] {
    const baseItems = [
      { label: 'Dashboard', path: '/dashboard', icon: 'grid' },
      { label: 'Profile', path: '/dashboard/profile', icon: 'user' }
    ]

    if (user.company_type === 'it') {
      if (user.role === 'admin' || user.role === 'super_admin') {
        return [
          ...baseItems,
          { label: 'Users', path: '/dashboard/admin/users', icon: 'users' },
          { label: 'Settings', path: '/dashboard/admin/settings', icon: 'settings' }
        ]
      }

      if (user.role === 'hr_manager') {
        return [
          ...baseItems,
          { label: 'Employees', path: '/dashboard/employees', icon: 'users' },
          { label: 'Payroll', path: '/dashboard/payroll', icon: 'dollar' }
        ]
      }
    }

    return baseItems
  }
}

interface MenuItem {
  label: string
  path: string
  icon: string
}

// ============================================================================
// 8. MIDDLEWARE
// ============================================================================

/**
 * Authentication Middleware
 * Validates JWT token and sets user context
 */
export const authMiddleware = (req: AuthRequest, res: Response, next: NextFunction) => {
  try {
    const token = req.headers.authorization?.split(' ')[1]

    if (!token) {
      return res.status(401).json({ error: 'No token provided' })
    }

    const decoded = jwt.verify(token, JWT_SECRET)
    req.user = decoded as any
    next()
  } catch (error) {
    return res.status(401).json({ error: 'Invalid token' })
  }
}

/**
 * Legacy User Check Middleware
 * Adds legacy user info to request if applicable
 */
export const legacyUserCheckMiddleware = async (
  req: AuthRequest,
  res: Response,
  next: NextFunction
) => {
  if (req.user && req.user.isLegacy) {
    const legacyBridge = new LegacyUserBridgeService()
    const legacyUser = await legacyBridge.getLegacyUserByEmail(req.user.email)
    req.legacyUser = legacyUser
  }
  next()
}

/**
 * Role-Based Access Control Middleware
 */
export const roleMiddleware = (allowedRoles: string[]) => {
  return (req: AuthRequest, res: Response, next: NextFunction) => {
    if (!req.user) {
      return res.status(401).json({ error: 'Unauthorized' })
    }

    if (!allowedRoles.includes(req.user.role)) {
      return res.status(403).json({ error: 'Insufficient permissions' })
    }

    next()
  }
}

// ============================================================================
// 9. API ENDPOINTS
// ============================================================================

import express from 'express'
const router = express.Router()

/**
 * Login Endpoint
 * POST /auth/login
 */
router.post('/auth/login', async (req: AuthRequest, res: Response) => {
  const { email, password } = req.body

  if (!email || !password) {
    return res.status(400).json({ error: 'Email and password required' })
  }

  const authService = new AuthenticationService()
  const result = await authService.authenticate(email, password)

  if (!result.success) {
    return res.status(401).json({ error: result.error })
  }

  // Log successful login
  console.log(`[LOGIN] Successful login for ${email}`)

  return res.json({
    success: true,
    user: result.user,
    token: result.token,
    dashboard: new DashboardRouterService().getDashboardPath(result.user)
  })
})

/**
 * Get Dashboard Config
 * GET /auth/dashboard-config
 */
router.get(
  '/auth/dashboard-config',
  authMiddleware,
  async (req: AuthRequest, res: Response) => {
    if (!req.user) {
      return res.status(401).json({ error: 'Unauthorized' })
    }

    const router = new DashboardRouterService()
    const dashPath = router.getDashboardPath(req.user as NewUser)
    const sidebarItems = router.getSidebarItems(req.user as NewUser)

    return res.json({
      dashboardPath: dashPath,
      sidebarItems: sidebarItems,
      isLegacyUser: req.user.isLegacy || false
    })
  }
)

/**
 * Refresh Token
 * POST /auth/refresh
 */
router.post('/auth/refresh', authMiddleware, (req: AuthRequest, res: Response) => {
  if (!req.user) {
    return res.status(401).json({ error: 'Unauthorized' })
  }

  const authService = new AuthenticationService()
  const newToken = jwt.sign(
    {
      userId: req.user.userId,
      email: req.user.email,
      companyId: req.user.companyId,
      role: req.user.role,
      companyType: req.user.companyType,
      isLegacy: req.user.isLegacy
    },
    JWT_SECRET,
    { expiresIn: TOKEN_EXPIRY }
  )

  return res.json({ token: newToken })
})

// ============================================================================
// 10. EXPORT SERVICES
// ============================================================================

export {
  LegacyUserBridgeService,
  UserMigrationService,
  EmailVerificationService,
  AuthenticationService,
  DashboardRouterService
}

export default router
