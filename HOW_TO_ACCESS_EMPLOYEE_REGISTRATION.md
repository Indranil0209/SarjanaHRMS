# How to Access Employee Registration Form

## 🚀 Quick Access

### URL
```
http://localhost:5173/employee-registration
```

### Navigation
1. Make sure dev server is running
2. Open browser (Chrome, Firefox, Safari, Edge)
3. Paste URL in address bar
4. Press Enter

## ✅ Dev Server Status

Your dev server is currently running at:
- **Main Site**: http://localhost:5173
- **Employee Registration**: http://localhost:5173/employee-registration

## 📝 Step-by-Step Testing Guide

### Step 1: Open the Form
```
1. Navigate to: http://localhost:5173/employee-registration
2. You should see the Employee Registration form
3. The form loads with empty fields
```

### Step 2: Fill Out the Form with Valid Data
```
EXAMPLE DATA:
First Name:         John
Last Name:          Doe
Date of Birth:      1990-05-15
Phone Number:       9876543210
Employee Code:      EMP001
Official Email:     john.doe@company.com
Department:         Engineering
Designation:        Senior Developer
Password:           SecurePass123
Confirm Password:   SecurePass123
```

### Step 3: Test Validation (Optional)
```
TEST 1 - Missing First Name:
  • Leave First Name empty
  • Click "Register Employee"
  • See error: "First name is required"

TEST 2 - Invalid Email:
  • Enter "not-an-email" in Official Email
  • Click "Register Employee"
  • See error: "Please enter a valid email address"

TEST 3 - Invalid Phone:
  • Enter "123" in Phone Number
  • Click "Register Employee"
  • See error: "Please enter a valid 10-digit phone number"

TEST 4 - Short Password:
  • Enter "pass1" in Password
  • Click "Register Employee"
  • See error: "Password must be at least 8 characters"

TEST 5 - Password Mismatch:
  • Enter "ValidPass123" in Password
  • Enter "DifferentPass456" in Confirm Password
  • Click "Register Employee"
  • See error: "Passwords do not match"
```

### Step 4: Submit Valid Form
```
1. Fill all fields with valid data (see Step 2 example)
2. Click "Register Employee" button
3. Button shows "Registering..." with spinner
4. Wait 1.5 seconds for simulated API call
5. See success alert
6. Form automatically resets to empty
```

### Step 5: Check Console Output
```
1. Press F12 or Ctrl+Shift+I to open Developer Tools
2. Click on "Console" tab
3. Scroll up to see logged data
4. You should see output like:

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

## 🔍 Detailed Testing Scenarios

### Scenario 1: Valid Submission
**Objective**: Test successful form submission

**Steps**:
1. Navigate to employee registration page
2. Enter all valid data:
   - First Name: John
   - Last Name: Doe
   - Phone: 9876543210
   - Employee Code: EMP001
   - Email: john@company.com
   - Password: ValidPass123
   - Confirm: ValidPass123
3. Click "Register Employee"

**Expected Result**:
- Button shows loading state
- Success alert appears
- Form resets to empty
- Data logged to console

**Status**: ✅ Pass if all above occur

---

### Scenario 2: Field Validation
**Objective**: Test individual field validation

**Field: First Name**
```
Input: (empty)
Click: Register Employee
Expected: "First name is required"
Status: ✅ Pass if error appears
```

**Field: Email**
```
Input: "invalid.email"
Click: Register Employee
Expected: "Please enter a valid email address"
Status: ✅ Pass if error appears
```

**Field: Phone**
```
Input: "12345"
Click: Register Employee
Expected: "Please enter a valid 10-digit phone number"
Status: ✅ Pass if error appears
```

**Field: Password**
```
Input: "abc1" (4 chars)
Click: Register Employee
Expected: "Password must be at least 8 characters"
Status: ✅ Pass if error appears
```

**Field: Confirm Password**
```
Password: "ValidPass123"
Confirm: "DifferentPass456"
Click: Register Employee
Expected: "Passwords do not match"
Status: ✅ Pass if error appears
```

---

### Scenario 3: Error Clearing
**Objective**: Test that errors disappear when user corrects field

**Steps**:
1. Leave First Name empty
2. Click Register Employee
3. See error: "First name is required"
4. Type "John" in First Name field
5. Error should disappear

**Expected Result**:
- Error message appears initially
- Disappears when user types
- Field returns to normal styling

**Status**: ✅ Pass if error clears

---

### Scenario 4: Responsive Design
**Objective**: Test form on different screen sizes

**Desktop (>1024px)**:
- 2-column grid layout
- Multiple fields side-by-side

**Tablet (768px - 1024px)**:
- 2-column grid
- Adjusted spacing

**Mobile (<768px)**:
- 1-column layout
- Full-width inputs
- Stacked sections

**Status**: ✅ Pass if layout adjusts properly

---

### Scenario 5: Password Visibility Toggle
**Objective**: Test password show/hide functionality

**Steps**:
1. Enter password in Password field
2. Click eye icon next to password
3. Password should show as text
4. Click eye icon again
5. Password should be hidden as dots

**Expected Result**:
- Eye icon toggles password visibility
- Works for both password fields
- Smooth state transitions

**Status**: ✅ Pass if toggle works

---

## 🛠️ Browser Developer Tools Usage

### Open Developer Tools
```
Chrome/Edge: F12 or Ctrl+Shift+I
Firefox: F12
Safari: Cmd+Option+I
```

### Check Console Logs
```
1. Open DevTools
2. Click "Console" tab
3. Submit the form
4. Scroll to find the logged data
5. Click to expand and view all fields
```

### Check for Errors
```
1. Open DevTools
2. Look for any red error messages
3. Fix accordingly
4. Reload page to clear errors
```

### Device Responsiveness Testing
```
Chrome/Edge/Firefox:
1. Open DevTools (F12)
2. Click "Toggle device toolbar" button
3. Select different devices to test
4. Observe form layout changes
```

## 📱 Mobile Testing

### On Your Phone
```
1. Find your computer's IP address
2. On phone, navigate to: http://YOUR_IP:5173/employee-registration
3. Test form on mobile device
4. Verify touch interactions work
5. Check responsive layout
```

### Using Browser DevTools
```
1. Open Chrome DevTools
2. Click device toggle (Ctrl+Shift+M)
3. Select iPhone or Android device
4. Test form in device view
5. Adjust window size to test breakpoints
```

## ⚠️ Common Issues & Solutions

### Issue 1: Page shows blank
**Solution**: 
- Check URL is correct: http://localhost:5173/employee-registration
- Verify dev server is running
- Check browser console for errors
- Refresh page (F5)

### Issue 2: Styling looks wrong
**Solution**:
- Clear browser cache (Ctrl+Shift+Delete)
- Reload page (F5 or Ctrl+R)
- Check if Tailwind CSS is loaded
- Inspect element with DevTools

### Issue 3: Validation not working
**Solution**:
- Check all required fields are filled
- Verify phone number is 10 digits
- Check email format is correct
- Password must be 8+ characters
- Passwords must match exactly

### Issue 4: Console doesn't show logs
**Solution**:
- Open DevTools (F12)
- Go to Console tab
- Submit form with valid data
- Scroll up to see logs
- Check timestamp for latest entry

### Issue 5: Form won't submit
**Solution**:
- Check for error messages under fields
- Verify all required fields are filled
- Click on fields to see if validation errors appear
- Try with the example data provided
- Refresh page and try again

## ✅ Full Testing Checklist

- [ ] Page loads at /employee-registration URL
- [ ] Form displays all 10 fields
- [ ] Text inputs accept input
- [ ] Date picker works
- [ ] Password toggle works
- [ ] First Name validation works
- [ ] Last Name validation works
- [ ] Phone validation works (10-digit)
- [ ] Email validation works
- [ ] Password length validation works (8 chars)
- [ ] Password match validation works
- [ ] Employee Code validation works
- [ ] All errors display correctly
- [ ] Errors clear when typing
- [ ] Valid submission works
- [ ] Data logs to console
- [ ] Form resets after submission
- [ ] Button shows loading state
- [ ] Form is responsive on mobile
- [ ] Password visibility toggle works
- [ ] Success alert appears

**Mark Complete When**: All checkboxes are checked ✅

## 📊 Form Field Reference

When testing, use these field names:

```
formData Keys:
- firstName
- lastName
- dateOfBirth
- phoneNumber
- employeeCode
- officialEmail
- department
- designation
- password
- confirmPassword

Error Keys (same as field names):
- firstName (error message)
- lastName (error message)
- phoneNumber (error message)
- etc...
```

## 🔗 Related Information

- See EMPLOYEE_REGISTRATION_GUIDE.md for technical details
- See EMPLOYEE_REGISTRATION_EXAMPLES.md for more test cases
- See EMPLOYEE_REGISTRATION_QUICK_REFERENCE.md for quick lookup

## 📞 Need Help?

1. **Check Documentation**: Read the guide files
2. **Check Console**: Open DevTools to see errors
3. **Verify URL**: Ensure you're at correct route
4. **Restart Server**: Stop and restart dev server
5. **Clear Cache**: Clear browser cache and reload
6. **Review Code**: Check component source code

---

**Access URL**: http://localhost:5173/employee-registration
**Status**: ✅ Ready to Test
**Last Updated**: June 2, 2026
