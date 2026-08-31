import { createClient } from '@supabase/supabase-js';

const supabaseUrl = 'https://ykcpdolezschqwcueuil.supabase.co';
const supabaseAnonKey = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InlrY3Bkb2xlenNjaHF3Y3VldWlsIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NjI1MTM5NTYsImV4cCI6MjA3ODA4OTk1Nn0.TTu20eDWZRUrgX8AF4KcGsuhoAkL6jwZ-kTo1VjIooM';

const supabase = createClient(supabaseUrl, supabaseAnonKey);

// List of passwords to try for each user
const testPasswords = [
  'password123',
  '123456789',
  'Password@123',
  'password',
  'admin123',
  'test123',
  'SuperAdmin@2026',
  'Admin@2026',
  'HRManager@2026',
  'Employee@2026'
];

const testUsers = [
  'bashamohassin@gmail.com',
  'giwore2911@dolofan.com',
  'hef8q@dollicons.com',
  'zds0i@dollicons.com'
];

async function tryTestPasswords() {
  console.log('🔐 Testing user passwords...\n');

  for (const email of testUsers) {
    console.log(`\n📧 Testing: ${email}`);
    console.log('─'.repeat(80));

    let foundPassword = null;

    for (const password of testPasswords) {
      try {
        const { data, error } = await supabase.auth.signInWithPassword({
          email,
          password
        });

        if (!error) {
          console.log(`   ✅ SUCCESS with password: "${password}"`);
          console.log(`      User ID: ${data.user.id}`);
          foundPassword = password;
          break;
        } else if (error.message !== 'Invalid login credentials') {
          console.log(`   ⚠️  Different error: ${error.message}`);
        }
      } catch (err) {
        console.log(`   💥 Exception: ${err.message}`);
      }
    }

    if (!foundPassword) {
      console.log(`   ❌ No working password found in test list`);
    }
  }

  console.log('\n\n' + '='.repeat(80));
  console.log('💡 SUGGESTION: If no passwords work, the accounts were likely');
  console.log('   created without passwords. We need to reset them.');
  console.log('='.repeat(80));
}

tryTestPasswords();
