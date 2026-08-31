# Employee Registration Component - Usage Examples

## Quick Start

### 1. Basic Usage (Standalone Page)
The component is already integrated into your routing at `/employee-registration`

Simply navigate to:
```
http://localhost:5173/employee-registration
```

### 2. Import and Use in Another Component

```jsx
import EmployeeRegistration from './components/auth/EmployeeRegistration'

function MyPage() {
  return (
    <div>
      <EmployeeRegistration />
    </div>
  )
}

export default MyPage
```

### 3. Add Navigation Link

Add a link to the Employee Registration page in your navigation:

```jsx
import { Link } from 'react-router-dom'

function NavMenu() {
  return (
    <nav>
      <Link to="/employee-registration">Register Employee</Link>
    </nav>
  )
}
```

## Form Data Flow

### State Updates (Real-time)

As users type, the form updates in real-time:

```javascript
// User types in First Name field
Input: "John"
↓
handleChange() triggered
↓
formData.firstName = "John"
↓
Component re-renders with new value
↓
Error for firstName is cleared (if existed)
```

### Form Submission Flow

```
User clicks "Register Employee"
↓
handleSubmit() preventDefault()
↓
validateForm() runs all validations
↓
If errors exist:
  ├─ Errors set in state
  └─ Component shows error messages
↓
If valid:
  ├─ loading = true (button disabled, spinner shows)
  ├─ Simulated API call (1.5 seconds)
  ├─ Console logs registration data
  ├─ Success alert shown
  ├─ Form resets to empty
  └─ loading = false (button re-enabled)
```

## Console Logging

### Successful Registration Output

When you successfully submit the form, it logs to the browser console:

```javascript
Employee Registration Data: {
  firstName: "John",
  lastName: "Doe",
  dateOfBirth: "1990-05-15",
  phoneNumber: "9876543210",
  employeeCode: "EMP001",
  officialEmail: "john.doe@company.com",
  department: "Engineering",
  designation: "Senior Developer",
  password: "SecurePass123",
  confirmPassword: "SecurePass123",
  timestamp: "2026-06-02T10:15:30.123Z"
}
```

### To View Console:
1. Open your browser's Developer Tools (F12 or Ctrl+Shift+I)
2. Go to the "Console" tab
3. Submit the form
4. Check console output

## Validation Examples

### Example 1: Missing Required Fields
```javascript
// User submits with empty first name
↓
Error: "First name is required"
↓ (Field shows red border and red text error message)
```

### Example 2: Invalid Email Format
```javascript
// User enters: "not-an-email"
↓
Error: "Please enter a valid email address"
↓ (Email field highlighted in red)
```

### Example 3: Password Mismatch
```javascript
// Password: "MyPassword123"
// Confirm: "MyPassword456"
↓
Error: "Passwords do not match"
↓ (Confirm Password field shows error)
```

### Example 4: Short Password
```javascript
// User enters: "abc123"
↓
Error: "Password must be at least 8 characters"
↓ (Password field shows error)
```

### Example 5: Invalid Phone Number
```javascript
// User enters: "123" or "abc1234567"
↓
Error: "Please enter a valid 10-digit phone number"
↓ (Phone field highlighted in red)
```

## Validation Test Cases

### Test Case 1: Valid Form Data
```javascript
Input:
- First Name: "John"
- Last Name: "Doe"
- Phone: "9876543210"
- Employee Code: "EMP001"
- Email: "john@company.com"
- Password: "SecurePass123"
- Confirm: "SecurePass123"

Result: ✅ Form submits successfully
```

### Test Case 2: Missing First Name
```javascript
Input:
- First Name: "" (empty)
- Last Name: "Doe"
- ... other valid fields ...

Result: ❌ Error: "First name is required"
         Form does not submit
```

### Test Case 3: Invalid Phone
```javascript
Input:
- Phone: "12345" (only 5 digits)
- ... other valid fields ...

Result: ❌ Error: "Please enter a valid 10-digit phone number"
         Form does not submit
```

### Test Case 4: Email Format
```javascript
Input:
- Email: "invalid.email" (no @domain)

Result: ❌ Error: "Please enter a valid email address"
         Form does not submit
```

### Test Case 5: Password Too Short
```javascript
Input:
- Password: "Pass1" (5 characters)

Result: ❌ Error: "Password must be at least 8 characters"
         Form does not submit
```

### Test Case 6: Passwords Don't Match
```javascript
Input:
- Password: "ValidPass123"
- Confirm: "ValidPass456"

Result: ❌ Error: "Passwords do not match"
         Form does not submit
```

## Visual Feedback Examples

### Normal State (No Errors)
```
┌─────────────────────┐
│ First Name          │
│ ┌─────────────────┐ │
│ │ (gray border)   │ │
│ └─────────────────┘ │
└─────────────────────┘
```

### Error State
```
┌─────────────────────┐
│ First Name *        │
│ ┌─────────────────┐ │
│ │ (red border)    │ │
│ └─────────────────┘ │
│ 🔴 First name is required
└─────────────────────┘
```

### Focus State
```
┌─────────────────────┐
│ First Name *        │
│ ┌─────────────────┐ │
│ │ (blue ring)     │ │ ← Blue focus ring
│ │ (blue border)   │ │ ← Blue border
│ └─────────────────┘ │
└─────────────────────┘
```

## Real-World Usage Scenarios

### Scenario 1: New Employee Onboarding
**Flow:**
1. HR Manager sends registration link to new employee
2. Employee navigates to `/employee-registration`
3. Employee fills all required fields
4. System validates and stores data
5. Employee receives confirmation

**Key Fields Used:**
- Employee Code (assigned by HR)
- Official Email (company email)
- Department (HR provides)
- Phone (for emergency contact)

### Scenario 2: Self-Service Registration
**Flow:**
1. New hire accesses registration page independently
2. Enters personal information
3. Creates secure password
4. Submits registration
5. System sends confirmation email

**Key Fields Used:**
- Personal Details (name, DOB, phone)
- Security Details (password)
- Contact Email

### Scenario 3: Bulk Employee Setup
**Flow:**
1. HR exports employee list with codes
2. Each employee registers with their unique code
3. System validates against employee database
4. Registration completes successfully

**Key Fields Used:**
- Employee Code (verification)
- Official Email (from HR records)

## Customization Examples

### Example 1: Add Custom Validation
```jsx
// Modify validateForm() function
if (!formData.phoneNumber.match(/^\+?1?\d{9,15}$/)) {
  newErrors.phoneNumber = 'Invalid phone format'
}
```

### Example 2: Add Loading Message
```jsx
// In handleSubmit(), replace setTimeout with:
setLoading(true)
try {
  const response = await registerEmployee(formData)
  console.log('Employee registered:', response)
} catch (error) {
  setErrors({ submit: error.message })
} finally {
  setLoading(false)
}
```

### Example 3: Add Toast Notification
```jsx
import { useNotification } from './context/NotificationContext'

// In component:
const { showSuccess, showError } = useNotification()

// In handleSubmit():
if (!validateForm()) {
  showError('Please fix the errors above')
  return
}

// On success:
showSuccess('Employee registered successfully!')
```

### Example 4: Change Button Text
```jsx
// Replace button text in JSX:
{loading ? 'Setting Up Account...' : 'Complete Registration'}
```

### Example 5: Add Department Dropdown
```jsx
// Instead of text input:
<select name="department" value={formData.department} onChange={handleChange}>
  <option value="">Select Department</option>
  <option value="Engineering">Engineering</option>
  <option value="HR">Human Resources</option>
  <option value="Finance">Finance</option>
</select>
```

## API Integration Example

### Replace Mock with Real API

```jsx
const handleSubmit = async (e) => {
  e.preventDefault()

  if (!validateForm()) return

  setLoading(true)

  try {
    // Call actual API endpoint
    const response = await fetch('/api/employees/register', {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json'
      },
      body: JSON.stringify(formData)
    })

    if (!response.ok) {
      throw new Error('Registration failed')
    }

    const result = await response.json()
    
    // Reset form
    setFormData({...initialFormData})
    setErrors({})
    
    // Show success
    alert('Employee registered successfully!')
    
  } catch (error) {
    setErrors({ submit: error.message })
  } finally {
    setLoading(false)
  }
}
```

## Troubleshooting

### Issue: Form won't submit
**Solution:** Check browser console for error messages. Ensure all required fields are filled.

### Issue: Validation not working
**Solution:** Clear browser cache and reload the page.

### Issue: Password visibility toggle not working
**Solution:** Ensure lucide-react icons are properly imported.

### Issue: Styling looks incorrect
**Solution:** Verify Tailwind CSS is properly configured in your project.

## Performance Optimization

### Current Performance
- **Bundle Size**: Minimal (single component file)
- **Render Performance**: Optimized (local state only)
- **Validation**: Client-side (instant feedback)

### Future Optimizations
```jsx
// Use React.memo to prevent unnecessary re-renders
export default React.memo(EmployeeRegistration)

// Use useCallback for event handlers
const handleChange = useCallback((e) => {
  // handler logic
}, [])

// Use useMemo for validation
const validationErrors = useMemo(() => {
  return validateForm()
}, [formData])
```

## Accessibility Features

✅ **Already Implemented:**
- Proper `<label>` elements
- `htmlFor` attributes on labels
- `id` attributes on inputs
- Required field indicators (*)
- Error message associations
- Password toggle buttons with icons
- Semantic HTML form structure

✅ **To Add:**
- `aria-required` on required fields
- `aria-invalid` on error states
- `aria-describedby` for error messages
- ARIA labels for icon buttons

---

**Need Help?**
- Check the `EMPLOYEE_REGISTRATION_GUIDE.md` for detailed documentation
- Review browser console for validation messages
- Inspect network tab if integrating with backend API
