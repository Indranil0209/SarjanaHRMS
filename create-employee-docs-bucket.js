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

const supabaseUrl = 'https://ykcpdolezschqwcueuil.supabase.co';
const supabaseAnonKey = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InlrY3Bkb2xlenNjaHF3Y3VldWlsIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NjI1MTM5NTYsImV4cCI6MjA3ODA4OTk1Nn0.TTu20eDWZRUrgX8AF4KcGsuhoAkL6jwZ-kTo1VjIooM';

if (!supabaseUrl || !supabaseAnonKey) {
  console.error('Missing Supabase URL or Anon Key in environment variables.')
  process.exit(1)
}

const supabase = createClient(supabaseUrl, supabaseAnonKey)

async function createBucket() {
  try {
    console.log('Creating employee-docs bucket via SQL...')
    
    const { error } = await supabase.rpc('exec_sql', {
      sql: `
        INSERT INTO storage.buckets (id, name, public) 
        VALUES ('employee-docs', 'employee-docs', false) 
        ON CONFLICT (id) DO NOTHING;
      `
    })

    if (error) {
      console.error('Failed to create bucket:', error)
    } else {
      console.log('Bucket "employee-docs" created successfully!')
    }
  } catch (err) {
    console.error('Error:', err)
  }
}

createBucket()
