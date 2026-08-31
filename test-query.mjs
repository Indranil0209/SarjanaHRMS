import { createClient } from '@supabase/supabase-js';

const supabaseUrl = 'https://tjbycijgnceqnczocayg.supabase.co';
const supabaseKey = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InRqYnljaWpnbmNlcW5jem9jYXlnIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NjA2MDA4NTAsImV4cCI6MjA3NjE3Njg1MH0._QKBbQgUncIVq3W9AhzQBiKQG0N1W_nLBPoHNoFpoPw';

const supabase = createClient(supabaseUrl, supabaseKey);

async function check() {
  console.log('Fetching users...');
  const { data: users, error: uErr } = await supabase.from('users').select('*').limit(1);
  if (uErr) {
    console.error('users error:', uErr);
    return;
  }
  console.log('users:', users.length > 0 ? 'found' : 'not found');

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
    if (data.length > 0) {
      console.log('first record:', JSON.stringify(data[0], null, 2));
    }
  }
}

check();
