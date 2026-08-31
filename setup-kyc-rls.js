import { createClient } from '@supabase/supabase-js';

const supabaseUrl = 'https://tjbycijgnceqnczocayg.supabase.co';
const supabaseKey = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InRqYnljaWpnbmNlcW5jem9jYXlnIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NjA2MDA4NTAsImV4cCI6MjA3NjE3Njg1MH0._QKBbQgUncIVq3W9AhzQBiKQG0N1W_nLBPoHNoFpoPw';

const supabase = createClient(supabaseUrl, supabaseKey);

async function applyRLS() {
  const sql = `
    -- Enable RLS
    ALTER TABLE public.kyc_documents ENABLE ROW LEVEL SECURITY;

    -- Drop existing policies if they exist
    DROP POLICY IF EXISTS "Users can view their own KYC documents" ON public.kyc_documents;
    DROP POLICY IF EXISTS "Users can insert their own KYC documents" ON public.kyc_documents;
    DROP POLICY IF EXISTS "Users can update their own KYC documents" ON public.kyc_documents;
    DROP POLICY IF EXISTS "HR and Admins can view all KYC documents" ON public.kyc_documents;

    -- 1. Users can view their own documents
    CREATE POLICY "Users can view their own KYC documents"
    ON public.kyc_documents
    FOR SELECT
    USING (
      auth.uid() IN (
        SELECT user_id FROM public.employees WHERE id = employee_id
      )
    );

    -- 2. Users can insert their own documents
    CREATE POLICY "Users can insert their own KYC documents"
    ON public.kyc_documents
    FOR INSERT
    WITH CHECK (
      auth.uid() IN (
        SELECT user_id FROM public.employees WHERE id = employee_id
      )
    );

    -- 3. Users can update their own documents
    CREATE POLICY "Users can update their own KYC documents"
    ON public.kyc_documents
    FOR UPDATE
    USING (
      auth.uid() IN (
        SELECT user_id FROM public.employees WHERE id = employee_id
      )
    );

    -- 4. HR and Admin can view all documents
    CREATE POLICY "HR and Admins can view all KYC documents"
    ON public.kyc_documents
    FOR SELECT
    USING (
      EXISTS (
        SELECT 1 FROM public.users
        WHERE users.id = auth.uid()
        AND users.role IN ('admin', 'super_admin', 'hr_manager')
      )
    );
    
    -- Setup Storage RLS for employee-docs bucket
    -- Note: Ensure employee-docs bucket exists and is public or has correct policies
  `;

  console.log("Running exec_sql...");
  const { data, error } = await supabase.rpc('exec_sql', { sql_query: sql });
  
  if (error) {
    console.error("Error applying RLS:", error);
  } else {
    console.log("RLS applied successfully!", data);
  }
}

applyRLS();
