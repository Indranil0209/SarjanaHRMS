import { createClient } from '@supabase/supabase-js';

const supabaseUrl = 'https://ykcpdolezschqwcueuil.supabase.co';
const supabaseServiceKey = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InlrY3Bkb2xlenNjaHF3Y3VldWlsIiwicm9sZSI6InNlcnZpY2Vfcm9sZSIsImlhdCI6MTc2MjUxMzk1NiwiZXhwIjoyMDc4MDg5OTU2fQ.ctxa44srFxJsa-TcJ0IZAEDrGa1T6ER72080DQrSG8c';

// Create admin client with service role key
const supabase = createClient(supabaseUrl, supabaseServiceKey, {
  auth: {
    autoRefreshToken: false,
    persistSession: false,
  }
});

// Default passwords for each role
const defaultPasswords = {
  super_admin: 'SuperAdmin@2026',
  admin: 'Admin@2026',
  hr_manager: 'HRManager@2026',
  employee: 'Employee@2026'
};

async function createAuthUsers() {
  try {
    console.log('🔑 Creating Supabase Auth accounts...\n');

    // Fetch all users from public.users table
    const { data: users, error: fetchError } = await supabase
      .from('users')
      .select('id, email, role')
      .order('email', { ascending: true });

    if (fetchError) {
      console.error('❌ Error fetching users:', fetchError);
      return;
    }

    console.log(`📊 Found ${users.length} users to migrate\n`);

    let successCount = 0;
    let failCount = 0;
    const results = [];

    for (const user of users) {
      try {
        const password = defaultPasswords[user.role] || 'DefaultPass@2026';

        console.log(`⏳ Creating auth for: ${user.email} (${user.role})`);

        // Create auth user using admin API
        const { data: authUser, error: authError } = await supabase.auth.admin.createUser({
          email: user.email,
          password: password,
          email_confirm: true, // Auto-confirm email
          user_metadata: {
            role: user.role,
            user_id: user.id
          }
        });

        if (authError) {
          // Check if user already exists
          if (authError.message.includes('already exists')) {
            console.log(`   ⚠️  Already exists in Auth`);
            results.push({
              email: user.email,
              role: user.role,
              status: 'already_exists',
              message: 'User already has auth account'
            });
            successCount++;
          } else {
            console.error(`   ❌ Error: ${authError.message}`);
            results.push({
              email: user.email,
              role: user.role,
              status: 'failed',
              message: authError.message
            });
            failCount++;
          }
        } else {
          console.log(`   ✅ Created successfully`);
          console.log(`      Auth ID: ${authUser.user.id}`);
          console.log(`      Password: ${password}`);
          results.push({
            email: user.email,
            role: user.role,
            status: 'created',
            authId: authUser.user.id,
            password: password
          });
          successCount++;
        }
      } catch (err) {
        console.error(`   💥 Exception: ${err.message}`);
        failCount++;
      }
    }

    console.log('\n' + '='.repeat(80));
    console.log('📋 MIGRATION SUMMARY');
    console.log('='.repeat(80));
    console.log(`✅ Successful: ${successCount}`);
    console.log(`❌ Failed: ${failCount}`);
    console.log(`📊 Total: ${users.length}\n`);

    // Group by status
    const created = results.filter(r => r.status === 'created');
    const alreadyExists = results.filter(r => r.status === 'already_exists');
    const failed = results.filter(r => r.status === 'failed');

    if (created.length > 0) {
      console.log('🆕 NEWLY CREATED USERS:');
      console.log('─'.repeat(80));
      created.forEach(r => {
        console.log(`📧 ${r.email}`);
        console.log(`   Role: ${r.role}`);
        console.log(`   Password: ${r.password}`);
        console.log('');
      });
    }

    if (alreadyExists.length > 0) {
      console.log('\n⚠️  ALREADY EXISTING:');
      console.log('─'.repeat(80));
      alreadyExists.forEach(r => {
        console.log(`📧 ${r.email} (${r.role})`);
      });
    }

    if (failed.length > 0) {
      console.log('\n❌ FAILED:');
      console.log('─'.repeat(80));
      failed.forEach(r => {
        console.log(`📧 ${r.email} (${r.role})`);
        console.log(`   Error: ${r.message}`);
      });
    }

    console.log('\n' + '='.repeat(80));
    console.log('✅ AUTH MIGRATION COMPLETE!');
    console.log('='.repeat(80));

  } catch (err) {
    console.error('💥 Fatal error:', err.message);
  }
}

// Run the migration
createAuthUsers();
