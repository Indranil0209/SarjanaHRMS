import { createClient } from '@supabase/supabase-js';
import dotenv from 'dotenv';
import { fileURLToPath } from 'url';
import { dirname, join } from 'path';
import { existsSync } from 'fs';

// Load environment variables
const __filename = fileURLToPath(import.meta.url);
const __dirname = dirname(__filename);

// 1. Prioritize .env.backend for safe service key loading, then fallback to .env
let envLoaded = false;
const backendEnvPath = join(__dirname, '.env.backend');
if (existsSync(backendEnvPath)) {
  dotenv.config({ path: backendEnvPath });
  console.log('✅ Loaded environment from .env.backend');
  envLoaded = true;
} else {
  const envPath = join(__dirname, '.env');
  if (existsSync(envPath)) {
    dotenv.config({ path: envPath });
    console.log('⚠️ Loaded environment from .env (Recommend using .env.backend for backend scripts)');
    envLoaded = true;
  }
}

// 2. Setup Supabase Client
const supabaseUrl = process.env.VITE_SUPABASE_URL;
const serviceRoleKey = process.env.SUPABASE_SERVICE_ROLE_KEY;

if (!supabaseUrl || !serviceRoleKey) {
  console.error("\n❌ Missing Supabase URL or SERVICE ROLE KEY.");
  console.error("Please run the script with your service role key like this:");
  console.error("Windows PowerShell:");
  console.error("$env:SUPABASE_SERVICE_ROLE_KEY='your_service_role_key'");
  console.error("node setup-demo-accounts.js\n");
  process.exit(1);
}

const supabaseAdmin = createClient(supabaseUrl, serviceRoleKey, {
  auth: {
    autoRefreshToken: false,
    persistSession: false
  }
});

const demoAccounts = [
  {
    email: 'admin.demo@sarjanahrtech.com',
    password: 'DemoPassword123!',
    role: 'admin',
    company_type: 'it'
  },
  {
    email: 'hr.demo@sarjanahrtech.com',
    password: 'DemoPassword123!',
    role: 'hr',
    company_type: 'it'
  },
  {
    email: 'employee.demo@sarjanahrtech.com',
    password: 'DemoPassword123!',
    role: 'employee',
    company_type: 'it'
  }
];

async function setupDemoAccounts() {
  console.log('🚀 Setting up permanent demo accounts...\n');

  // 3. Create or Fetch Demo Company
  const companyName = 'Sarjana Demo Company';
  console.log(`Checking for demo company: "${companyName}"...`);
  
  let { data: company, error: companyErr } = await supabaseAdmin
    .from('companies')
    .select('id')
    .eq('company_name', companyName)
    .single();

  if (companyErr && companyErr.code !== 'PGRST116') { // PGRST116 is "Row not found"
    console.error('❌ Error fetching company:', companyErr.message);
    process.exit(1);
  }

  let demoCompanyId;

  if (!company) {
    console.log(`Creating demo company "${companyName}"...`);
    // 'id' will be generated automatically as UUID by the database
    const { data: newCompany, error: createErr } = await supabaseAdmin
      .from('companies')
      .insert({
        company_name: companyName,
        company_name_lower: companyName.toLowerCase(),
        industry: 'Software (Demo)',
        size: '1-10',
        status: 'active',
        company_type: 'it', // matches demo accounts
        is_verified: true
      })
      .select()
      .single();

    if (createErr) {
      console.error('❌ Error creating demo company:', createErr.message);
      process.exit(1);
    }
    demoCompanyId = newCompany.id;
    console.log(`✅ Demo company created with ID: ${demoCompanyId}`);
  } else {
    demoCompanyId = company.id;
    console.log(`✅ Demo company already exists with ID: ${demoCompanyId}`);
  }

  // 4. Create Users and Sync to public.users
  for (const account of demoAccounts) {
    console.log(`\nProcessing ${account.email}...`);
    
    // Create in auth.users
    const { data: authData, error: authError } = await supabaseAdmin.auth.admin.createUser({
      email: account.email,
      password: account.password,
      email_confirm: true
    });

    if (authError) {
      if (authError.message.includes('already registered') || authError.message.includes('already exists')) {
        console.log(`⚠️ User ${account.email} already exists in auth.users.`);
      } else {
        console.error(`❌ Error creating auth user for ${account.email}:`, authError.message);
        continue;
      }
    } else {
      console.log(`✅ Created auth.users record for ${account.email}. ID: ${authData.user.id}`);
    }

    // Fetch the auth ID to ensure we sync it correctly
    const { data: usersList, error: listError } = await supabaseAdmin.auth.admin.listUsers();
    if (listError) {
      console.error(`❌ Could not fetch users to find ID for ${account.email}`);
      continue;
    }
    
    const targetUser = usersList.users.find(u => u.email === account.email);
    if (!targetUser) {
      console.error(`❌ Could not find ${account.email} in auth.users after creation.`);
      continue;
    }

    // Upsert into public.users
    const { error: publicError } = await supabaseAdmin
      .from('users')
      .upsert({
        id: targetUser.id, 
        email: account.email,
        role: account.role,
        company_type: account.company_type,
        company_id: demoCompanyId, // Attach to Demo Company
        first_name: account.role.toUpperCase(),
        last_name: 'Demo',
        status: 'active',
        is_active: true,
        email_verified: true
      });

    if (publicError) {
      console.error(`❌ Error syncing public.users for ${account.email}:`, publicError.message);
    } else {
      console.log(`✅ Synced public.users record for ${account.email}`);
    }
  }

  console.log('\n🎉 Demo accounts setup complete!');
}

setupDemoAccounts();
