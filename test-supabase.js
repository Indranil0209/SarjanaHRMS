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
const supabaseUrl = process.env.VITE_SUPABASE_URL || 'https://tjbycijgnceqnczocayg.supabase.co'
const supabaseAnonKey = process.env.VITE_SUPABASE_ANON_KEY || 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InRqYnljaWpnbmNlcW5jem9jYXlnIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NjA2MDA4NTAsImV4cCI6MjA3NjE3Njg1MH0._QKBbQgUncIVq3W9AhzQBiKQG0N1W_nLBPoHNoFpoPw'

console.log(' Supabase URL:', supabaseUrl)
console.log(' Supabase Key Length:', supabaseAnonKey ? `${supabaseAnonKey.substring(0, 10)}...` : 'Not set')

const supabase = createClient(supabaseUrl, supabaseAnonKey)

async function testSupabase() {
  try {
    console.log(' Testing Supabase connection...')
    
    // Test connection by fetching companies
    const { data, error } = await supabase
      .from('companies')
      .select('id, company_name')
      .limit(5)
    
    if (error) {
      console.error('❌ Supabase connection failed:', error.message)
      return
    }
    
    console.log('✅ Supabase connection successful!')
    console.log(' Found companies:', data?.length || 0)
    
    if (data && data.length > 0) {
      console.log(' Sample companies:')
      data.slice(0, 3).forEach(company => {
        console.log(`  - ${company.company_name} (${company.id})`)
      })
    }
    
    // Test users table
    console.log(' Testing users table...')
    const { data: users, error: usersError } = await supabase
      .from('users')
      .select('id, email, company_id')
      .limit(5)
    
    if (usersError) {
      console.error('❌ Users table access failed:', usersError.message)
      return
    }
    
    console.log('✅ Users table access successful!')
    console.log(' Found users:', users?.length || 0)
    
    if (users && users.length > 0) {
      console.log(' Sample users:')
      users.forEach(user => {
        console.log(`  - ${user.email} (Company ID: ${user.company_id || 'None'})`)
      })
    }
    
  } catch (error) {
    console.error('💥 Test failed:', error)
  }
}

testSupabase()