import { createClient } from '@supabase/supabase-js'
import dotenv from 'dotenv'
import { fileURLToPath } from 'url'
import { dirname, join } from 'path'
import { existsSync } from 'fs'

// Load environment variables
const __filename = fileURLToPath(import.meta.url)
const __dirname = dirname(__filename)

const envPath = join(__dirname, '.env')
if (existsSync(envPath)) {
  dotenv.config({ path: envPath })
}

const supabaseUrl = process.env.VITE_SUPABASE_URL
const supabaseAnonKey = process.env.VITE_SUPABASE_ANON_KEY

const supabase = createClient(supabaseUrl, supabaseAnonKey)

async function createTable() {
  try {
    console.log('Creating employee_documents table...')
    
    const { error: tableError } = await supabase.rpc('exec_sql', {
      sql: `
        CREATE TABLE IF NOT EXISTS employee_documents (
          id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
          employee_id UUID REFERENCES employees(id) ON DELETE CASCADE,
          document_type VARCHAR(50) NOT NULL CHECK (document_type IN ('aadhaar', 'pan', 'bank', 'employee_id')),
          file_url TEXT NOT NULL,
          created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
          updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
        );
        
        -- Add index for faster lookups
        CREATE INDEX IF NOT EXISTS idx_employee_documents_employee_id ON employee_documents(employee_id);
      `
    })
    
    if (tableError) {
      console.error('Failed to create table via exec_sql:', tableError.message)
      console.log('You might need to run this SQL manually in the Supabase Dashboard.')
    } else {
      console.log('Table employee_documents created successfully!')
    }
  } catch (err) {
    console.error('Error:', err)
  }
}

createTable()
