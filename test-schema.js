import { createClient } from '@supabase/supabase-js';

const supabaseUrl = 'https://tjbycijgnceqnczocayg.supabase.co';
const supabaseKey = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InRqYnljaWpnbmNlcW5jem9jYXlnIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NjA2MDA4NTAsImV4cCI6MjA3NjE3Njg1MH0._QKBbQgUncIVq3W9AhzQBiKQG0N1W_nLBPoHNoFpoPw';

const supabase = createClient(supabaseUrl, supabaseKey);

async function createTable() {
  const { error: tableError } = await supabase.rpc('exec_sql', {
    sql: `
      CREATE TABLE IF NOT EXISTS kyc_documents_new (
        id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
        employee_id UUID REFERENCES employees(id) ON DELETE CASCADE,
        document_type VARCHAR(50) NOT NULL CHECK (document_type IN ('aadhaar', 'pan', 'bank', 'employee_id')),
        file_url TEXT NOT NULL,
        created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
      );
      
      CREATE INDEX IF NOT EXISTS idx_kyc_documents_new_employee_id ON kyc_documents_new(employee_id);
    `
  });
  if (tableError) {
    console.error('tableError:', tableError.message);
  } else {
    console.log('table created successfully');
  }
}

createTable();
