# Fixed: Department Column Shows Actual Departments

## Changes Made

### Problem
The DEPARTMENT column was showing "General" for all employees because:
1. Department dropdowns were using hardcoded array values (strings)
2. We were saving department name instead of department_id
3. ManageUsers wasn't fetching actual department names from database

### Solution

Updated 3 key areas:

## 1. AddEmployee Form - Fetch Real Departments

**File:** `src/pages/dashboard/AddEmployee.jsx`

**Added:**
```javascript
const [departments, setDepartments] = useState([])
const [positions, setPositions] = useState([])

useEffect(() => {
  const fetchDropdownData = async () => {
    // Fetch departments from database
    const { data: deptData } = await supabase
      .from('departments')
      .select('id, name')
      .order('name')
    
    setDepartments(deptData)
    
    // Fetch job positions from database
    const { data: posData } = await supabase
      .from('job_positions')
      .select('id, title')
      .order('title')
    
    setPositions(posData)
  }
  
  fetchDropdownData()
}, [])
```

**Updated Dropdowns:**
```javascript
// Department dropdown now uses ID as value
<select name="department" value={formData.department}>
  <option value="">Select Department</option>
  {departments.map(dept => (
    <option key={dept.id} value={dept.id}>{dept.name}</option>
  ))}
</select>

// Position dropdown now uses ID as value
<select name="position" value={formData.position}>
  <option value="">Select Position</option>
  {positions.map(pos => (
    <option key={pos.id} value={pos.id}>{pos.title}</option>
  ))}
</select>
```

## 2. Save Department ID

**Updated handleSubmit:**
```javascript
const { data: employeeData } = await supabase
  .from('employees')
  .insert({
    company_id: companyId,
    employee_id: formData.employeeId,
    first_name: formData.firstName,
    last_name: formData.lastName,
    department_id: formData.department, // ✅ Now saves department ID
    job_position_id: formData.position, // ✅ Now saves position ID
    // ... other fields
  })
```

## 3. Display Department Name

**File:** `src/pages/hr/ManageUsers.jsx`

**Updated Query with Join:**
```javascript
const { data: employeesData } = await supabase
  .from('employees')
  .select(`
    *,
    departments (
      name
    )
  `)
  .is('user_id', null)
```

**Updated Display:**
```javascript
const unregisteredEmployees = employeesData.map(emp => ({
  // ... other fields
  department: emp.departments?.name || 'General', // ✅ Shows actual department
}))
```

## How to Test

### Step 1: Refresh Browser
Press `F5` or `Ctrl+R`

### Step 2: Add New Employee

1. Go to: http://localhost:8000/dashboard/hr/users
2. Click "Add User"
3. Fill form:
   ```
   First Name:    John
   Last Name:     Smith
   Employee ID:   JS001
   Phone:         555-1234
   Department:    Engineering  ← Select from dropdown
   Position:      Software Engineer  ← Select from dropdown
   Salary:        75000
   Start Date:    2024-08-20
   ```
4. Click "Add Employee"

### Step 3: Check User List

The new employee should show:
```
Name: John Smith
Department: Engineering  ← Shows actual department! ✅
Status: Inactive
Type: Pending
```

### Step 4: Verify in Database

```sql
SELECT 
    e.employee_id,
    e.first_name,
    e.last_name,
    e.department_id,
    d.name as department_name,
    e.job_position_id,
    j.title as position_title
FROM employees e
LEFT JOIN departments d ON e.department_id = d.id
LEFT JOIN job_positions j ON e.job_position_id = j.id
WHERE e.employee_id = 'JS001';
```

Should return:
```
employee_id | first_name | department_name | position_title
------------|------------|-----------------|------------------
JS001       | John       | Engineering     | Software Engineer
```

## Data Flow

### Before Fix:
```
Add Employee Form
├── Department: "Engineering" (string)
└── Saves: department_id = NULL

Database:
├── employees table: department_id = NULL
└── departments table: [not used]

ManageUsers Display:
└── Department: "General" (default)
```

### After Fix:
```
Add Employee Form
├── Fetches departments from database
├── Shows: "Engineering" (name)
├── Stores: department_id = UUID
└── Saves: department_id = actual ID

Database:
├── employees table: department_id = [UUID]
└── departments table: links via foreign key

ManageUsers Display:
├── Joins with departments table
└── Department: "Engineering" (actual name) ✅
```

## Available Departments

If you don't have departments in your database, create them:

```sql
-- Check existing departments
SELECT id, name FROM departments;

-- If no departments exist, create some
INSERT INTO departments (company_id, name, description) VALUES
((SELECT id FROM companies LIMIT 1), 'Engineering', 'Software Development'),
((SELECT id FROM companies LIMIT 1), 'Human Resources', 'HR Department'),
((SELECT id FROM companies LIMIT 1), 'Sales', 'Sales Department'),
((SELECT id FROM companies LIMIT 1), 'Marketing', 'Marketing Department'),
((SELECT id FROM companies LIMIT 1), 'Finance', 'Finance Department'),
((SELECT id FROM companies LIMIT 1), 'Operations', 'Operations Department');
```

## Available Job Positions

```sql
-- Check existing positions
SELECT id, title FROM job_positions;

-- If no positions exist, create some
INSERT INTO job_positions (company_id, title, description) VALUES
((SELECT id FROM companies LIMIT 1), 'Software Engineer', 'Develops software'),
((SELECT id FROM companies LIMIT 1), 'Senior Software Engineer', 'Senior developer'),
((SELECT id FROM companies LIMIT 1), 'HR Manager', 'Manages HR'),
((SELECT id FROM companies LIMIT 1), 'Sales Manager', 'Manages sales team'),
((SELECT id FROM companies LIMIT 1), 'Marketing Manager', 'Manages marketing'),
((SELECT id FROM companies LIMIT 1), 'Accountant', 'Manages finances');
```

## Verification Steps

### 1. Check Dropdowns Populate
- Open Add Employee form
- Department dropdown should show actual departments from database
- Position dropdown should show actual positions from database

### 2. Check Save Works
- Add employee with selected department
- No errors should occur
- Employee saves successfully

### 3. Check Display Works
- View user list
- Employee shows actual department name
- Not just "General"

### 4. Check Database
```sql
-- Verify employee has department_id
SELECT employee_id, first_name, department_id, job_position_id
FROM employees
WHERE department_id IS NOT NULL;

-- Verify join works
SELECT 
    e.employee_id,
    d.name as department,
    j.title as position
FROM employees e
LEFT JOIN departments d ON e.department_id = d.id
LEFT JOIN job_positions j ON e.job_position_id = j.id;
```

## Summary

✅ **Dropdowns fetch from database** (not hardcoded)
✅ **Saves department_id** (foreign key reference)
✅ **Displays actual department name** (via join)
✅ **Supports dynamic departments** (add new ones to database)

**Result:** DEPARTMENT column now shows actual department names from your database!

## Files Modified

1. ✅ `src/pages/dashboard/AddEmployee.jsx`
   - Added useEffect to fetch departments and positions
   - Updated dropdowns to use database data
   - Saves department_id and job_position_id

2. ✅ `src/pages/hr/ManageUsers.jsx`
   - Updated query to join with departments table
   - Displays actual department name

## Next Steps

If dropdowns are empty:
1. Add departments to database (see SQL above)
2. Add job positions to database (see SQL above)
3. Refresh the form
4. Dropdowns should now show options

**Try it now! Refresh and add a new employee with a real department!** 🎉
