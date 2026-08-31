import { createClient } from '@supabase/supabase-js';
const supabaseUrl = 'https://ykcpdolezschqwcueuil.supabase.co';
const supabaseAnonKey = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InlrY3Bkb2xlenNjaHF3Y3VldWlsIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NjI1MTM5NTYsImV4cCI6MjA3ODA4OTk1Nn0.TTu20eDWZRUrgX8AF4KcGsuhoAkL6jwZ-kTo1VjIooM';

const supabase = createClient(supabaseUrl, supabaseAnonKey);

(async () => {
  try {
    console.log('📋 Fetching all users from the database...\n');
    
    const { data, error } = await supabase
      .from('users')
      .select('id, email, role, company_id, company_type, email_verified, is_active')
      .order('email', { ascending: true });
    
    if (error) {
      console.log('❌ Error:', error);
    } else {
      console.log(`✅ Total users found: ${data?.length || 0}\n`);
      if (data && data.length > 0) {
        console.log('📊 User List:');
        console.log('─'.repeat(120));
        data.forEach((user, index) => {
          console.log(`${index + 1}. Email: ${user.email}`);
          console.log(`   ID: ${user.id}`);
          console.log(`   Role: ${user.role}`);
          console.log(`   Company ID: ${user.company_id}`);
          console.log(`   Company Type: ${user.company_type}`);
          console.log(`   Email Verified: ${user.email_verified}`);
          console.log(`   Active: ${user.is_active}`);
          console.log('');
        });
      } else {
        console.log('⚠️ No users found in the database');
      }
    }
  } catch (err) {
    console.log('💥 Exception:', err.message);
  }
})();
