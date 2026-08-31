import { createClient } from '@supabase/supabase-js';

const supabaseUrl = 'https://ykcpdolezschqwcueuil.supabase.co'; // Using URL from .env
const supabaseKey = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InlrY3Bkb2xlenNjaHF3Y3VldWlsIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NjI1MTM5NTYsImV4cCI6MjA3ODA4OTk1Nn0.TTu20eDWZRUrgX8AF4KcGsuhoAkL6jwZ-kTo1VjIooM';

const supabase = createClient(supabaseUrl, supabaseKey);

async function checkSync() {
  const { data: publicUser, error: err1 } = await supabase.rpc('exec_sql', {
    sql: `SELECT id, email, company_type, role FROM public.users WHERE email='giwore2911@dolofan.com';`
  });
  console.log('Public User:', publicUser, err1?.message);

  const { data: authUser, error: err2 } = await supabase.rpc('exec_sql', {
    sql: `SELECT id, email FROM auth.users WHERE email='giwore2911@dolofan.com';`
  });
  console.log('Auth User:', authUser, err2?.message);
}

checkSync();
