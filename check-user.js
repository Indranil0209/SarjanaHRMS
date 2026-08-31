import { createClient } from '@supabase/supabase-js';
const supabaseUrl = 'https://ykcpdolezschqwcueuil.supabase.co';
const supabaseAnonKey = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InlrY3Bkb2xlenNjaHF3Y3VldWlsIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NjI1MTM5NTYsImV4cCI6MjA3ODA4OTk1Nn0.TTu20eDWZRUrgX8AF4KcGsuhoAkL6jwZ-kTo1VjIooM';

const supabase = createClient(supabaseUrl, supabaseAnonKey);

(async () => {
  try {
    console.log('🔍 Checking for email: mosinbasha080@gmail.com');
    
    const { data, error } = await supabase
      .from('users')
      .select('*')
      .eq('email', 'mosinbasha080@gmail.com');
    
    if (error) {
      console.log('❌ Error:', error);
      console.log('Error Code:', error.code);
    } else {
      console.log('✅ Query successful');
      console.log('📊 Results found:', data?.length || 0);
      if (data && data.length > 0) {
        console.log('📋 User data:');
        data.forEach(user => {
          console.log({
            id: user.id,
            email: user.email,
            role: user.role,
            company_id: user.company_id,
            company_type: user.company_type,
            email_verified: user.email_verified,
            is_active: user.is_active
          });
        });
      } else {
        console.log('⚠️ No users found with this email');
      }
    }
  } catch (err) {
    console.log('💥 Exception:', err.message);
  }
})();
