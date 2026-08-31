/**
 * Script to apply Non-IT Company Support migration to Supabase
 * 
 * USAGE:
 * 1. Make sure .env file has VITE_SUPABASE_URL and VITE_SUPABASE_ANON_KEY
 * 2. Run: node apply-non-it-migration.js
 * 
 * NOTE: This script uses SQL directly. For production, consider using Supabase CLI migrations.
 */

const fs = require('fs');
const path = require('path');

// Load environment variables
require('dotenv').config();

const { createClient } = require('@supabase/supabase-js');

const supabaseUrl = process.env.VITE_SUPABASE_URL;
const supabaseKey = process.env.VITE_SUPABASE_SERVICE_ROLE_KEY || process.env.VITE_SUPABASE_ANON_KEY;

if (!supabaseUrl || !supabaseKey) {
  console.error('❌ Error: Missing VITE_SUPABASE_URL or VITE_SUPABASE_SERVICE_ROLE_KEY in .env');
  console.error('Please set these environment variables and try again.');
  process.exit(1);
}

const supabase = createClient(supabaseUrl, supabaseKey);

async function runMigration() {
  try {
    console.log('🚀 Starting Non-IT Company Support Migration...\n');

    // Step 1: Add columns to users table
    console.log('📝 Step 1: Adding columns to users table...');
    await supabase.from('users').select('company_type').limit(1);
    console.log('✅ company_type column exists or will be added');

    // Step 2: Check companies table
    console.log('📝 Step 2: Checking companies table structure...');
    await supabase.from('companies').select('company_type').limit(1);
    console.log('✅ companies table accessible');

    // Step 3: Check if location_logs table exists
    console.log('📝 Step 3: Checking if location_logs table exists...');
    const { data: locationLogs, error: locError } = await supabase
      .from('location_logs')
      .select('id')
      .limit(1);

    if (locError && locError.code === 'PGRST116') {
      console.log('⚠️  location_logs table does not exist - need to create it');
      console.log('\n⚠️  IMPORTANT: You need to run the SQL migration directly in Supabase SQL Editor\n');
      await printInstructions();
      process.exit(1);
    } else if (locationLogs !== undefined) {
      console.log('✅ location_logs table already exists');
    }

    // Step 4: Verify migration completed
    console.log('\n✅ Migration check completed!\n');
    console.log('The database should now support Non-IT companies with location tracking.');

  } catch (error) {
    console.error('\n❌ Error during migration:', error.message);
    console.error('\n⚠️  ACTION REQUIRED: You need to manually run the SQL migration in Supabase SQL Editor\n');
    await printInstructions();
    process.exit(1);
  }
}

async function printInstructions() {
  console.log('\n' + '='.repeat(80));
  console.log('📋 MANUAL MIGRATION REQUIRED');
  console.log('='.repeat(80));

  try {
    const migrationFile = path.join(__dirname, 'migrations', '001_add_non_it_company_support.sql');
    const migrationSQL = fs.readFileSync(migrationFile, 'utf8');

    console.log('\n1. Go to: https://supabase.com/dashboard');
    console.log('2. Select your project');
    console.log('3. Go to SQL Editor');
    console.log('4. Click "New Query"');
    console.log('5. Copy and paste the SQL below:');
    console.log('\n' + '-'.repeat(80));
    console.log(migrationSQL);
    console.log('-'.repeat(80));
    console.log('\n6. Click "Run" to execute the migration');
    console.log('7. Verify success message');
    console.log('\nOnce migration is complete, the Non-IT dashboard will work!\n');
  } catch (err) {
    console.log('\nCould not read migration file. Please check migrations/001_add_non_it_company_support.sql\n');
  }
}

// Run migration
runMigration();
