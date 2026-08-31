/**
 * ============================================================================
 * BACKEND: Multi-Step Signup API Endpoints
 * ============================================================================
 * 
 * Implements complete validation workflows for:
 * 1. Company Admin Registration
 * 2. HR Manager Registration  
 * 3. Employee Registration
 * 
 * Each endpoint validates data, manages state, and ensures multi-tenant isolation
 */

import { Router, Request, Response } from 'express'
import { supabase } from '../lib/supabase'
import { generateCompanyCode } from '../utils/companyCodeGenerator'
import { hashPassword, verifyPassword } from '../utils/passwordUtils'
import { sendVerificationEmail, sendWelcomeEmail } from '../services/emailService'
import { v4 as uuid } from 'uuid'

const router = Router()

/**
 * ============================================================================
 * SHARED UTILITIES
 * ============================================================================
 */

interface SignupSessionData {
  id: string
  email: string
  sector: 'it' | 'non-it'
  role: string
  companyId?: string
  companyCode?: string
  employeeId?: string
  stepCurrent: string
  stepCompleted: string[]
  formData: Record<string, any>
  status: 'active' | 'completed' | 'abandoned' | 'expired'
}

interface ValidationResult {
  success: boolean
  error?: string
  errorCode?: string
  data?: any
}

// Get or create signup session
const getOrCreateSession = async (email: string, sector: string, role: string): Promise<SignupSessionData | null> => {
  const { data: existing, error: findError } = await supabase
    .from('signup_sessions')
    .select('*')
    .eq('email', email.toLowerCase())
    .single()

  if (existing && !findError) {
    return existing as SignupSessionData
  }

  // Create new session
  const sessionId = uuid()
  const { data: newSession, error: createError } = await supabase
    .from('signup_sessions')
    .insert({
      id: sessionId,
      email: email.toLowerCase(),
      sector,
      role,
      step_current: 'initialized',
      step_completed: [],
      form_data: JSON.stringify({}),
      status: 'active'
    })
    .select()
    .single()

  if (createError) {
    console.error('Error creating signup session:', createError)
    return null
  }

  return newSession as SignupSessionData
}

// Update session
const updateSession = async (sessionId: string, updates: any): Promise<boolean> => {
  const { error } = await supabase
    .from('signup_sessions')
    .update({
      ...updates,
      last_activity_at: new Date().toISOString()
    })
    .eq('id', sessionId)

  return !error
}

// Log code usage
const logCodeUsage = async (codeId: string, userId: string | null, action: string, req: Request): Promise<void> => {
  await supabase
    .from('code_usage_audit')
    .insert({
      id: uuid(),
      code_id: codeId,
      user_id: userId,
      action,
      ip_address: req.ip || 'unknown',
      user_agent: req.headers['user-agent'] || null,
      metadata: JSON.stringify({
        timestamp: new Date().toISOString(),
        endpoint: req.path
      })
    })
    .catch(err => console.error('Error logging code usage:', err))
}

/**
 * ============================================================================
 * ENDPOINT 1: Initialize Signup Session
 * ============================================================================
 * POST /api/signup/initialize
 * 
 * Validates sector and role, creates signup session
 */
router.post('/initialize', async (req: Request, res: Response) => {
  try {
    const { sector, role, email } = req.body

    // Validation
    if (!sector || !['it', 'non-it'].includes(sector)) {
      return res.status(400).json({ success: false, error: 'Invalid sector' })
    }

    if (!role || !['company_admin', 'hr_manager', 'employee'].includes(role)) {
      return res.status(400).json({ success: false, error: 'Invalid role' })
    }

    if (!email || !/^[^\s@]+@[^\s@]+\.[^\s@]+$/.test(email)) {
      return res.status(400).json({ success: false, error: 'Invalid email' })
    }

    // Check email not already registered
    const { data: existingUser } = await supabase
      .from('users')
      .select('id')
      .eq('email', email.toLowerCase())
      .single()

    if (existingUser) {
      return res.status(400).json({
        success: false,
        error: 'EMAIL_EXISTS',
        message: 'An account with this email already exists'
      })
    }

    // Create or get session
    const session = await getOrCreateSession(email, sector, role)
    if (!session) {
      return res.status(500).json({ success: false, error: 'Failed to create session' })
    }

    // Determine workflow steps based on role
    const stepMap = {
      company_admin: ['company_details', 'admin_credentials', 'verification'],
      hr_manager: ['company_code', 'hr_profile'],
      employee: ['employee_validation', 'employee_account']
    }

    res.json({
      success: true,
      sessionId: session.id,
      flow: {
        sector,
        role,
        steps: stepMap[role as keyof typeof stepMap],
        currentStep: stepMap[role as keyof typeof stepMap][0]
      }
    })
  } catch (error) {
    console.error('Error in /initialize:', error)
    res.status(500).json({ success: false, error: 'Internal server error' })
  }
})

/**
 * ============================================================================
 * ENDPOINT 2: Company Details (Admin Path - Step 1)
 * ============================================================================
 * POST /api/signup/company-details
 */
router.post('/company-details', async (req: Request, res: Response) => {
  try {
    const { sessionId, company_name, company_email, industry, employee_count, domain } = req.body

    // Get session
    const { data: session, error: sessionError } = await supabase
      .from('signup_sessions')
      .select('*')
      .eq('id', sessionId)
      .single()

    if (sessionError || !session) {
      return res.status(400).json({ success: false, error: 'Invalid session' })
    }

    // Validation
    if (!company_name || company_name.length < 2) {
      return res.status(400).json({ success: false, error: 'Invalid company name' })
    }

    if (!company_email || !/^[^\s@]+@[^\s@]+\.[^\s@]+$/.test(company_email)) {
      return res.status(400).json({ success: false, error: 'Invalid company email' })
    }

    // Check company name uniqueness (case-insensitive)
    const { data: existingCompany } = await supabase
      .from('companies')
      .select('id')
      .ilike('company_name', company_name)
      .single()

    if (existingCompany) {
      return res.status(400).json({
        success: false,
        error: 'COMPANY_EXISTS',
        message: 'This company name is already registered'
      })
    }

    // Generate company code
    const companyCode = generateCompanyCode(company_name)

    // Verify code uniqueness
    const { data: existingCode } = await supabase
      .from('companies')
      .select('id')
      .eq('company_code', companyCode)
      .single()

    if (existingCode) {
      // Regenerate if collision (extremely rare)
      const newCode = `${companyCode.split('-')[0]}-${Math.random().toString(36).substring(2, 12).toUpperCase()}`
      const updatedCompanyCode = newCode
    }

    // Update session
    await updateSession(sessionId, {
      step_current: 'admin_credentials',
      step_completed: ['company_details'],
      form_data: JSON.stringify({
        company_name,
        company_email,
        industry,
        employee_count,
        domain
      })
    })

    res.json({
      success: true,
      companyCode,
      message: 'Company details validated'
    })
  } catch (error) {
    console.error('Error in /company-details:', error)
    res.status(500).json({ success: false, error: 'Internal server error' })
  }
})

/**
 * ============================================================================
 * ENDPOINT 3: Validate Company Code (HR & Employee Path - Step 1)
 * ============================================================================
 * POST /api/signup/validate-company-code
 */
router.post('/validate-company-code', async (req: Request, res: Response) => {
  try {
    const { company_code } = req.body

    if (!company_code) {
      return res.status(400).json({ success: false, error: 'Company code required' })
    }

    // Query active codes
    const { data: codeRecord, error: codeError } = await supabase
      .from('company_registration_codes')
      .select(`
        id,
        code,
        company_id,
        expires_at,
        usage_count,
        max_uses,
        code_status
      `)
      .eq('code', company_code.toUpperCase())
      .single()

    if (codeError || !codeRecord) {
      // Log failed attempt
      await logCodeUsage(null, null, 'validation_failed', req)
      return res.status(400).json({
        success: false,
        error: 'INVALID_CODE',
        message: 'Company code not found'
      })
    }

    // Check expiration
    if (new Date() > new Date(codeRecord.expires_at)) {
      // Mark as expired
      await supabase
        .from('company_registration_codes')
        .update({ code_status: 'expired' })
        .eq('id', codeRecord.id)

      await logCodeUsage(codeRecord.id, null, 'code_expired', req)
      return res.status(400).json({
        success: false,
        error: 'CODE_EXPIRED',
        message: `This code expired on ${new Date(codeRecord.expires_at).toLocaleDateString()}`
      })
    }

    // Check usage limit
    if (codeRecord.max_uses > 0 && codeRecord.usage_count >= codeRecord.max_uses) {
      await logCodeUsage(codeRecord.id, null, 'quota_exceeded', req)
      return res.status(400).json({
        success: false,
        error: 'QUOTA_EXCEEDED',
        message: 'This company code has reached maximum uses'
      })
    }

    // Fetch company details
    const { data: company } = await supabase
      .from('companies')
      .select('id, company_name, sector, industry, logo')
      .eq('id', codeRecord.company_id)
      .single()

    // Check HR manager quota if needed
    if (req.body.role === 'hr_manager') {
      const { data: quota } = await supabase
        .from('company_quotas')
        .select('current_hr_managers, max_hr_managers')
        .eq('company_id', codeRecord.company_id)
        .single()

      if (quota && quota.current_hr_managers >= quota.max_hr_managers) {
        return res.status(400).json({
          success: false,
          error: 'QUOTA_EXCEEDED',
          message: 'This company has reached maximum HR managers'
        })
      }
    }

    // Log successful validation
    await logCodeUsage(codeRecord.id, null, 'code_validated', req)

    res.json({
      success: true,
      company: {
        id: company?.id,
        name: company?.company_name,
        sector: company?.sector,
        industry: company?.industry,
        logo: company?.logo
      },
      companyVerified: true
    })
  } catch (error) {
    console.error('Error in /validate-company-code:', error)
    res.status(500).json({ success: false, error: 'Internal server error' })
  }
})

/**
 * ============================================================================
 * ENDPOINT 4: Validate Employee (Employee Path - Step 1)
 * ============================================================================
 * POST /api/signup/validate-employee
 */
router.post('/validate-employee', async (req: Request, res: Response) => {
  try {
    const { company_code, employee_id } = req.body

    if (!company_code || !employee_id) {
      return res.status(400).json({ success: false, error: 'Code and Employee ID required' })
    }

    // Step 1: Validate company code
    const { data: codeRecord } = await supabase
      .from('company_registration_codes')
      .select('id, company_id, expires_at')
      .eq('code', company_code.toUpperCase())
      .single()

    if (!codeRecord) {
      return res.status(400).json({
        success: false,
        error: 'INVALID_CODE',
        message: 'Company code not found'
      })
    }

    if (new Date() > new Date(codeRecord.expires_at)) {
      return res.status(400).json({
        success: false,
        error: 'CODE_EXPIRED',
        message: 'Company code has expired'
      })
    }

    // Step 2: Validate employee record
    const { data: employee, error: empError } = await supabase
      .from('employees')
      .select('id, employee_id, full_name, department, designation, user_id')
      .eq('employee_id', employee_id.trim())
      .eq('company_id', codeRecord.company_id)
      .single()

    if (empError || !employee) {
      await logCodeUsage(codeRecord.id, null, 'employee_not_found', req)
      return res.status(400).json({
        success: false,
        error: 'EMPLOYEE_NOT_FOUND',
        message: `No employee record found for ID: ${employee_id}`
      })
    }

    // Check if already registered
    if (employee.user_id) {
      return res.status(400).json({
        success: false,
        error: 'EMPLOYEE_ALREADY_REGISTERED',
        message: 'This employee ID is already linked to an account'
      })
    }

    // Log validation
    await logCodeUsage(codeRecord.id, null, 'employee_validated', req)

    res.json({
      success: true,
      employee: {
        id: employee.id,
        employee_id: employee.employee_id,
        name: employee.full_name,
        department: employee.department,
        designation: employee.designation
      }
    })
  } catch (error) {
    console.error('Error in /validate-employee:', error)
    res.status(500).json({ success: false, error: 'Internal server error' })
  }
})

/**
 * ============================================================================
 * ENDPOINT 5: Create Admin User (Admin Path - Final)
 * ============================================================================
 * POST /api/signup/create-admin
 */
router.post('/create-admin', async (req: Request, res: Response) => {
  try {
    const { sessionId, email, password, full_name, phone } = req.body
    const { data: session } = await supabase
      .from('signup_sessions')
      .select('*')
      .eq('id', sessionId)
      .single()

    if (!session) {
      return res.status(400).json({ success: false, error: 'Invalid session' })
    }

    // Parse stored form data
    const formData = JSON.parse(session.form_data)

    // Create company first
    const companyCode = generateCompanyCode(formData.company_name)
    const { data: company, error: companyError } = await supabase
      .from('companies')
      .insert({
        id: uuid(),
        company_name: formData.company_name,
        company_name_lower: formData.company_name.toLowerCase(),
        company_email: formData.company_email,
        company_code: companyCode,
        sector: session.sector,
        industry: formData.industry,
        status: 'active',
        registration_status: 'active'
      })
      .select()
      .single()

    if (companyError || !company) {
      return res.status(500).json({ success: false, error: 'Failed to create company' })
    }

    // Create user in Supabase Auth
    const { data: authData, error: authError } = await supabase.auth.signUp({
      email: email.toLowerCase(),
      password: password,
      options: {
        data: {
          full_name,
          role: 'admin',
          company_id: company.id
        }
      }
    })

    if (authError || !authData.user) {
      // Rollback company creation
      await supabase.from('companies').delete().eq('id', company.id)
      return res.status(400).json({ success: false, error: authError?.message || 'Auth signup failed' })
    }

    // Create user profile
    const { error: profileError } = await supabase
      .from('users')
      .insert({
        id: authData.user.id,
        email: email.toLowerCase(),
        full_name,
        phone_number: phone,
        role: 'admin',
        company_id: company.id,
        sector: session.sector,
        is_active: true,
        email_verified: false
      })

    if (profileError) {
      return res.status(500).json({ success: false, error: 'Failed to create user profile' })
    }

    // Create company quotas
    await supabase
      .from('company_quotas')
      .insert({
        id: uuid(),
        company_id: company.id,
        current_admins: 1
      })

    // Send verification email
    await sendVerificationEmail(email, authData.user.id, company.company_code)

    // Update session
    await updateSession(sessionId, {
      status: 'completed',
      step_current: 'verification',
      created_user_id: authData.user.id
    })

    res.json({
      success: true,
      message: 'Admin account created! Check email for verification link.',
      companyCode: company.company_code
    })
  } catch (error) {
    console.error('Error in /create-admin:', error)
    res.status(500).json({ success: false, error: 'Internal server error' })
  }
})

/**
 * ============================================================================
 * ENDPOINT 6: Create HR Manager (HR Path - Final)
 * ============================================================================
 * POST /api/signup/create-hr-manager
 */
router.post('/create-hr-manager', async (req: Request, res: Response) => {
  try {
    const { company_code, email, password, full_name, phone } = req.body

    // Validate company code and get company
    const { data: codeRecord } = await supabase
      .from('company_registration_codes')
      .select('company_id, id')
      .eq('code', company_code.toUpperCase())
      .single()

    if (!codeRecord) {
      return res.status(400).json({ success: false, error: 'Invalid company code' })
    }

    // Create user in Supabase Auth
    const { data: authData, error: authError } = await supabase.auth.signUp({
      email: email.toLowerCase(),
      password: password,
      options: {
        data: {
          full_name,
          role: 'hr_manager'
        }
      }
    })

    if (authError || !authData.user) {
      return res.status(400).json({ success: false, error: authError?.message || 'Auth signup failed' })
    }

    // Create user profile
    const { data: company } = await supabase
      .from('companies')
      .select('sector')
      .eq('id', codeRecord.company_id)
      .single()

    const { error: profileError } = await supabase
      .from('users')
      .insert({
        id: authData.user.id,
        email: email.toLowerCase(),
        full_name,
        phone_number: phone,
        role: 'hr_manager',
        company_id: codeRecord.company_id,
        sector: company?.sector,
        is_active: true,
        email_verified: false
      })

    if (profileError) {
      return res.status(500).json({ success: false, error: 'Failed to create user profile' })
    }

    // Update quota
    await supabase
      .from('company_quotas')
      .update({
        current_hr_managers: supabase.rpc('increment', {
          x: 'current_hr_managers',
          table_name: 'company_quotas'
        })
      })
      .eq('company_id', codeRecord.company_id)

    // Log code usage
    await logCodeUsage(codeRecord.id, authData.user.id, 'code_used_hr', req)

    // Send welcome email
    await sendWelcomeEmail(email, full_name, 'hr_manager')

    res.json({
      success: true,
      message: 'HR Manager account created! Welcome to Sarjana HR Tech.'
    })
  } catch (error) {
    console.error('Error in /create-hr-manager:', error)
    res.status(500).json({ success: false, error: 'Internal server error' })
  }
})

/**
 * ============================================================================
 * ENDPOINT 7: Create Employee Account (Employee Path - Final)
 * ============================================================================
 * POST /api/signup/create-employee
 */
router.post('/create-employee', async (req: Request, res: Response) => {
  try {
    const { company_code, employee_id, email, password, phone } = req.body

    // Re-validate both code and employee
    const { data: codeRecord } = await supabase
      .from('company_registration_codes')
      .select('company_id, id')
      .eq('code', company_code.toUpperCase())
      .single()

    if (!codeRecord) {
      return res.status(400).json({ success: false, error: 'Invalid company code' })
    }

    const { data: employee } = await supabase
      .from('employees')
      .select('id, full_name, user_id')
      .eq('employee_id', employee_id.trim())
      .eq('company_id', codeRecord.company_id)
      .single()

    if (!employee || employee.user_id) {
      return res.status(400).json({ success: false, error: 'Invalid employee record' })
    }

    // Create user in Supabase Auth
    const { data: authData, error: authError } = await supabase.auth.signUp({
      email: email.toLowerCase(),
      password: password,
      options: {
        data: {
          full_name: employee.full_name,
          role: 'employee'
        }
      }
    })

    if (authError || !authData.user) {
      return res.status(400).json({ success: false, error: 'Auth signup failed' })
    }

    // Create user profile
    const { data: company } = await supabase
      .from('companies')
      .select('sector')
      .eq('id', codeRecord.company_id)
      .single()

    const { error: profileError } = await supabase
      .from('users')
      .insert({
        id: authData.user.id,
        email: email.toLowerCase(),
        full_name: employee.full_name,
        phone_number: phone,
        role: 'employee',
        company_id: codeRecord.company_id,
        sector: company?.sector,
        is_active: true,
        email_verified: false,
        must_change_password: true
      })

    if (profileError) {
      return res.status(500).json({ success: false, error: 'Failed to create user profile' })
    }

    // Link employee to user
    const { error: linkError } = await supabase
      .from('employees')
      .update({ user_id: authData.user.id })
      .eq('id', employee.id)

    if (linkError) {
      return res.status(500).json({ success: false, error: 'Failed to link employee' })
    }

    // Log code usage
    await logCodeUsage(codeRecord.id, authData.user.id, 'code_used_employee', req)

    // Send welcome email
    await sendWelcomeEmail(email, employee.full_name, 'employee')

    res.json({
      success: true,
      message: 'Employee account created! Welcome to Sarjana HR Tech.'
    })
  } catch (error) {
    console.error('Error in /create-employee:', error)
    res.status(500).json({ success: false, error: 'Internal server error' })
  }
})

export default router
