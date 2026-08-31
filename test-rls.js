import { createClient } from '@supabase/supabase-js';
import dotenv from 'dotenv';
import { fileURLToPath } from 'url';
import { dirname, resolve } from 'path';

const __dirname = dirname(fileURLToPath(import.meta.url));
dotenv.config({ path: resolve(__dirname, '.env') });

const supabaseUrl = process.env.VITE_SUPABASE_URL;
const supabaseServiceKey = process.env.VITE_SUPABASE_ANON_KEY; // Actually we need service key to run exec_sql safely or anon if exec_sql is public

const supabase = createClient(supabaseUrl, supabaseServiceKey);

async function checkTable() {
  const { data, error } = await supabase.from('kyc_documents').select('*').limit(1);
  if (error) {
    console.error('Error querying kyc_documents:', error.message);
  } else {
    console.log('kyc_documents table exists and is accessible!');
  }
}

checkTable();
