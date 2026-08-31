import { createClient } from '@supabase/supabase-js'

const supabaseUrl = 'https://ykcpdolezschqwcueuil.supabase.co';
const supabaseAnonKey = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InlrY3Bkb2xlenNjaHF3Y3VldWlsIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NjI1MTM5NTYsImV4cCI6MjA3ODA4OTk1Nn0.TTu20eDWZRUrgX8AF4KcGsuhoAkL6jwZ-kTo1VjIooM';

const supabase = createClient(supabaseUrl, supabaseAnonKey)

async function listBuckets() {
  try {
    const { data: buckets, error } = await supabase.storage.listBuckets()
    if (error) {
      console.error('Failed to list buckets:', error)
      return
    }
    console.log('Buckets:', buckets.map(b => b.name))
  } catch (err) {
    console.error('Error:', err)
  }
}

listBuckets()
