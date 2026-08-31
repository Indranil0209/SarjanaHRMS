import { createClient } from '@supabase/supabase-js';
const supabaseUrl = 'https://ykcpdolezschqwcueuil.supabase.co';
const supabaseAnonKey = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InlrY3Bkb2xlenNjaHF3Y3VldWlsIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NjI1MTM5NTYsImV4cCI6MjA3ODA4OTk1Nn0.TTu20eDWZRUrgX8AF4KcGsuhoAkL6jwZ-kTo1VjIooM';

const supabase = createClient(supabaseUrl, supabaseAnonKey);

(async () => {
  try {
    console.log('🔍 Checking: bashamohassin@gmail.com\n');
    
    // Check in public.users table
    const { data: dbUser, error: dbError } = await supabase
      .from('users')
      .select('*')
      .eq('email', 'bashamohassin@gmail.com');
    
    console.log('📊 Database (public.users):');
    if (dbError) {
      console.log('❌ Error:', dbError);
    } else if (dbUser && dbUser.length > 0) {
      console.log('✅ User FOUND:');
      dbUser.forEach(user => {
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
      console.log('❌ User NOT found in public.users');
    }

    // Try to sign in
    console.log('\n\n🔐 Attempting to sign in...');
    const { data: authData, error: authError } = await supabase.auth.signInWithPassword({
      email: 'bashamohassin@gmail.com',
      password: '123456789'
    });
    
    if (authError) {
      console.log('❌ Sign in FAILED:');
      console.log('   Error:', authError.message);
      console.log('   Status:', authError.status);
    } else {
      console.log('✅ Sign in SUCCESSFUL!');
      console.log('   User ID:', authData.user?.id);
      console.log('   Email:', authData.user?.email);
    }

  } catch (err) {
    console.log('💥 Exception:', err.message);
  }
})();
