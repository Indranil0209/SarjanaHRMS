import { createClient } from '@supabase/supabase-js'
import dotenv from 'dotenv'
import { fileURLToPath } from 'url'
import { dirname, join } from 'path'
import { existsSync } from 'fs'

// Load environment variables
const __filename = fileURLToPath(import.meta.url)
const __dirname = dirname(__filename)

// Try to load .env file from project root
const envPath = join(__dirname, '.env')
if (existsSync(envPath)) {
  dotenv.config({ path: envPath })
} else {
  const rootEnvPath = join(__dirname, '..', '.env')
  if (existsSync(rootEnvPath)) {
    dotenv.config({ path: rootEnvPath })
  }
}

// Load environment variables
const supabaseUrl = process.env.VITE_SUPABASE_URL || 'https://your-project.supabase.co'
const supabaseAnonKey = process.env.VITE_SUPABASE_ANON_KEY || 'your-anon-key'

console.log(' Supabase URL:', supabaseUrl)

const supabase = createClient(supabaseUrl, supabaseAnonKey)

async function createCompaniesTable() {
  try {
    console.log(' Creating companies table...')
    
    // First, enable necessary extensions
    console.log(' Enabling extensions...')
    const { error: extensionError } = await supabase.rpc('exec_sql', {
      sql: `
        CREATE EXTENSION IF NOT EXISTS "uuid-ossp";
        CREATE EXTENSION IF NOT EXISTS "pgcrypto";
      `
    })
    
    if (extensionError) {
      console.log(' Warning: Could not enable extensions:', extensionError.message)
    }
    
    // Create custom types
    console.log(' Creating custom types...')
    const { error: typesError } = await supabase.rpc('exec_sql', {
      sql: `
        CREATE TYPE user_role AS ENUM ('super_admin', 'admin', 'hr_manager', 'employee');
        CREATE TYPE employment_status AS ENUM ('active', 'inactive', 'terminated', 'on_leave');
        CREATE TYPE leave_status AS ENUM ('pending', 'approved', 'rejected', 'cancelled');
        CREATE TYPE leave_type AS ENUM ('annual', 'sick', 'maternity', 'paternity', 'emergency', 'unpaid');
        CREATE TYPE attendance_status AS ENUM ('present', 'absent', 'late', 'half_day', 'work_from_home');
        CREATE TYPE payroll_status AS ENUM ('draft', 'processed', 'paid');
        CREATE TYPE company_status AS ENUM ('active', 'suspended', 'inactive');
      `
    })
    
    if (typesError) {
      console.log(' Warning: Could not create custom types:', typesError.message)
    }
    
    // Create companies table
    console.log(' Creating companies table...')
    const { error: tableError } = await supabase.rpc('exec_sql', {
      sql: `
        CREATE TABLE IF NOT EXISTS companies (
          id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
          company_name VARCHAR(255) UNIQUE NOT NULL,
          company_name_lower VARCHAR(255) UNIQUE NOT NULL,
          domain VARCHAR(255),
          industry VARCHAR(100),
          size VARCHAR(50),
          address TEXT,
          logo TEXT,
          status company_status DEFAULT 'active',
          settings JSONB DEFAULT '{}',
          created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
          updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
        );
      `
    })
    
    if (tableError) {
      console.error('❌ Failed to create companies table:', tableError.message)
      return
    }
    
    console.log('✅ Companies table created successfully!')
    
    // Test inserting a company
    console.log(' Testing company insertion...')
    const { data, error } = await supabase
      .from('companies')
      .insert({
        company_name: 'Test Company',
        company_name_lower: 'test company',
        industry: 'Technology',
        size: '11-50',
        status: 'active'
      })
      .select()
    
    if (error) {
      console.error('❌ Failed to insert test company:', error.message)
      return
    }
    
    console.log('✅ Test company inserted successfully!')
    console.log(' Company ID:', data[0].id)
    
    // Clean up test company
    console.log(' Cleaning up test company...')
    const { error: deleteError } = await supabase
      .from('companies')
      .delete()
      .eq('id', data[0].id)
    
    if (deleteError) {
      console.log(' Warning: Could not clean up test company:', deleteError.message)
    } else {
      console.log('✅ Test company cleaned up successfully!')
    }
    
  } catch (error) {
    console.error('💥 Error:', error)
  }
}

createCompaniesTable()