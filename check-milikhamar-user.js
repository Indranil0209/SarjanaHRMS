import { createClient } from '@supabase/supabase-js';

const supabaseUrl = 'https://ykcpdolezschqwcueuil.supabase.co';
const supabaseAnonKey = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InlrY3Bkb2xlenNjaHF3Y3VldWlsIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NjI1MTM5NTYsImV4cCI6MjA3ODA4OTk1Nn0.TTu20eDWZRUrgX8AF4KcGsuhoAkL6jwZ-kTo1VjIooM';

const supabase = createClient(supabaseUrl, supabaseAnonKey);

const testPasswords = [
  'password123',
  '123456789',
  'Password@123',
  'password',
  'admin123',
  'test123'
];

async function checkMilikhamar() {
  console.log('🔍 Checking: milikhamar45+company2@gmail.com\n');

  // Check in database
  const { data: dbUser, error: dbError } = await supabase
    .from('users')
    .select('*')
    .eq('email', 'milikhamar45+company2@gmail.com');

  console.log('📊 Database (public.users):');
  if (dbUser && dbUser.length > 0) {
    console.log('✅ User FOUND:');
    dbUser.forEach(user => {
      console.log({
        id: user.id,
        email: user.email,
        role: user.role,
        company_id: user.company_id,
        company_type: user.company_type
      });
    });
  } else {
    console.log('❌ User NOT found in database');
  }

  // Test passwords
  console.log('\n🔐 Testing passwords...');
  console.log('─'.repeat(80));

  let foundPassword = null;

  for (const password of testPasswords) {
    const { data, error } = await supabase.auth.signInWithPassword({
      email: 'milikhamar45+company2@gmail.com',
      password
    });

    if (!error) {
      console.log(`✅ SUCCESS with password: "${password}"`);
      console.log(`   User ID: ${data.user.id}`);
      foundPassword = password;
      break;
    }
  }

  if (!foundPassword) {
    console.log('❌ No working password found in test list');
    console.log('\n💡 Likely password: password123');
  }
}

checkMilikhamar();
