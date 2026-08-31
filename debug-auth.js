// Debug script for testing authentication and role-based routing
// Run this in browser console to test the current auth state

console.log('🔍 Auth Debug Script')

// Function to check current auth state
function checkAuthState() {
  console.log('👤 Current User State:')
  
  // Check if we're in a React app with AuthContext
  if (window.React && window.React.useContext) {
    console.log('React context detected - check components')
  }
  
  // Check localStorage for Supabase session
  const supabaseSession = localStorage.getItem('sb-' + window.location.hostname + '-auth-token')
  if (supabaseSession) {
    console.log('📱 Supabase session found in localStorage:', JSON.parse(supabaseSession))
  } else {
    console.log('❌ No Supabase session found')
  }
  
  // Check for user profile data
  const profileKeys = Object.keys(localStorage).filter(key => key.includes('profile') || key.includes('user'))
  console.log('👤 Profile-related localStorage keys:', profileKeys)
  
  profileKeys.forEach(key => {
    console.log(`${key}:`, localStorage.getItem(key))
  })
}

// Function to test role assignment for demo users
function testDemoRoles() {
  console.log('\n🧪 Testing Demo User Roles:')
  
  const demoUsers = [
    { email: 'admin@company.com', expectedRole: 'super_admin' },
    { email: 'sarah.hr@company.com', expectedRole: 'hr_manager' },
    { email: 'mike.johnson@company.com', expectedRole: 'employee' }
  ]
  
  demoUsers.forEach(user => {
    console.log(`${user.email} should have role: ${user.expectedRole}`)
  })
}

// Function to simulate profile creation for demo users
function simulateProfileCreation(email) {
  console.log(`\n🔧 Simulating profile creation for ${email}`)
  
  let role = 'employee' // default
  
  if (email === 'admin@company.com') {
    role = 'super_admin'
  } else if (email === 'sarah.hr@company.com') {
    role = 'hr_manager'
  } else if (email === 'mike.johnson@company.com') {
    role = 'employee'
  }
  
  const mockProfile = {
    id: 'mock-id-' + Date.now(),
    email: email,
    role: role,
    full_name: email.split('@')[0],
    is_active: true,
    email_verified: true
  }
  
  console.log('📝 Would create profile:', mockProfile)
  return mockProfile
}

// Run diagnostics
checkAuthState()
testDemoRoles()

// Export functions for manual testing
window.authDebug = {
  checkAuthState,
  testDemoRoles,
  simulateProfileCreation
}

console.log('\n✅ Debug functions available on window.authDebug')
console.log('Usage: window.authDebug.checkAuthState()')