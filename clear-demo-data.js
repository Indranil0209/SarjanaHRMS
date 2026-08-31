/**
 * Clear All Demo Data Script
 * 
 * This script removes:
 * 1. All demo data from localStorage
 * 2. All demo users from Supabase database
 * 
 * Run this in browser console OR as a Node.js script
 */

// Clear localStorage demo data
const clearLocalStorage = () => {
  const demoKeys = [
    'attendanceRecords',
    'taskRecords',
    'leaveRecords',
    'payrollRecords',
    'eventRecords',
    'notificationRecords'
  ];

  console.log('🧹 Clearing localStorage demo data...');
  
  demoKeys.forEach(key => {
    if (localStorage.getItem(key)) {
      localStorage.removeItem(key);
      console.log(`✅ Removed: ${key}`);
    }
  });

  // Also clear any other HRMS-related keys
  Object.keys(localStorage).forEach(key => {
    if (key.startsWith('hrms') || key.startsWith('sarjana')) {
      localStorage.removeItem(key);
      console.log(`✅ Removed: ${key}`);
    }
  });

  console.log('✅ All localStorage demo data cleared!');
};

// Clear demo users from Supabase (run this in browser console when logged in as admin)
const clearDemoUsersFromSupabase = async () => {
  const demoEmails = [
    'john.doe@company.com',
    'jane.smith@company.com',
    'mike.johnson@company.com',
    'sarah.hr@company.com',
    'admin@company.com',
    'emma.davis@company.com',
    'john.smith@company.com',
    'emily.johnson@company.com',
    'michael.chen@company.com',
    'sarah.williams@company.com',
    'david.brown@company.com',
    'lisa.garcia@company.com'
  ];

  console.log('🗑️ Removing demo users from Supabase...');

  try {
    // You'll need to import supabase client first
    // This assumes you're running in the browser console on your app
    const { supabase } = window;
    
    if (!supabase) {
      console.error('❌ Supabase client not found. Run this from your app\'s browser console.');
      return;
    }

    for (const email of demoEmails) {
      const { data, error } = await supabase
        .from('users')
        .delete()
        .eq('email', email);

      if (error) {
        console.error(`❌ Error deleting ${email}:`, error.message);
      } else {
        console.log(`✅ Deleted demo user: ${email}`);
      }
    }

    console.log('✅ All demo users removed from Supabase!');
  } catch (error) {
    console.error('❌ Error clearing demo users:', error);
  }
};

// Run both functions
console.log('=== Clearing All Demo Data ===\n');
clearLocalStorage();
console.log('\n📝 To clear demo users from Supabase, run: clearDemoUsersFromSupabase()');
console.log('(Make sure you\'re logged in as admin first)\n');

// Export for use
if (typeof window !== 'undefined') {
  window.clearDemoUsersFromSupabase = clearDemoUsersFromSupabase;
  window.clearAllDemoData = () => {
    clearLocalStorage();
    clearDemoUsersFromSupabase();
  };
}
