const { createClient } = require('@supabase/supabase-js');
const fs = require('fs');
require('dotenv').config();

const supabaseUrl = process.env.VITE_SUPABASE_URL;
const supabaseKey = process.env.VITE_SUPABASE_ANON_KEY;

if (!supabaseUrl || !supabaseKey) {
  console.log('Missing Supabase credentials');
  process.exit(1);
}

const supabase = createClient(supabaseUrl, supabaseKey);

async function check() {
  console.log('Fetching users...');
  const { data: users, error: uErr } = await supabase.from('users').select('*').limit(1);
  if (uErr) {
    console.error('users error:', uErr);
    return;
  }
  console.log('users:', users);

  if (!users || users.length === 0) return;
  const userProfile = users[0];

  console.log('Testing attendance query...');
  let attendanceQuery = supabase
    .from('attendance')
    .select(`
      *,
      employees (
        user_id,
        first_name,
        last_name,
        company_id,
        users (
          email,
          role,
          company_id
        )
      )
    `)
    .order('date', { ascending: false });
    
  if (userProfile?.company_id) {
    attendanceQuery = attendanceQuery.eq('company_id', userProfile.company_id);
  }
  
  const { data, error } = await attendanceQuery;
  if (error) {
    console.error('attendance error:', error);
  } else {
    console.log('attendance data count:', data.length);
    console.log('first record:', JSON.stringify(data[0], null, 2));
  }
}

check();
