# Supabase Setup Guide for HR Tech System

This guide will walk you through setting up your Supabase database for the HR Tech system.

## Table of Contents
- [Prerequisites](#prerequisites)
- [Creating a New Supabase Project](#creating-a-new-supabase-project)
- [Database Setup](#database-setup)
- [Row Level Security (RLS) Setup](#row-level-security-rls-setup)
- [Authentication Configuration](#authentication-configuration)
- [Storage Setup](#storage-setup)
- [Environment Variables](#environment-variables)
- [Testing the Setup](#testing-the-setup)

## Prerequisites

1. A Supabase account (sign up at [supabase.com](https://supabase.com))
2. Basic understanding of SQL and PostgreSQL
3. Your project files ready for deployment

## Creating a New Supabase Project

1. **Sign in to Supabase Dashboard**
   - Go to [app.supabase.com](https://app.supabase.com)
   - Sign in with your account

2. **Create a New Project**
   - Click "New Project"
   - Choose your organization
   - Enter project details:
     - **Name**: `hr-tech-system` (or your preferred name)
     - **Database Password**: Choose a strong password (save this!)
     - **Region**: Choose the closest region to your users
     - **Pricing Plan**: Choose based on your needs (Free tier works for development)

3. **Wait for Project Creation**
   - This usually takes 1-2 minutes
   - You'll get a project URL and API keys once ready

## Database Setup

### 1. Run the Database Schema

1. **Navigate to SQL Editor**
   - In your Supabase dashboard, go to "SQL Editor"
   - Click "New Query"

2. **Execute the Schema**
   - Copy the contents of `database/schema.sql`
   - Paste it into the SQL editor
   - Click "Run" to execute

3. **Verify Tables Created**
   - Go to "Database" > "Tables"
   - You should see all the tables: users, employees, departments, etc.

### 2. Insert Sample Data (Optional)

Create a new SQL query with sample data:

```sql
-- Insert sample departments
INSERT INTO departments (name, description) VALUES
('Engineering', 'Software development and technical operations'),
('Human Resources', 'People management and organizational development'),
('Sales', 'Customer acquisition and revenue generation'),
('Marketing', 'Brand promotion and customer engagement'),
('Finance', 'Financial planning and accounting'),
('Operations', 'Business operations and support');

-- Insert sample job positions
INSERT INTO job_positions (title, description, department_id, salary_range_min, salary_range_max) 
SELECT 
  'Software Engineer',
  'Develop and maintain software applications',
  id,
  50000,
  120000
FROM departments WHERE name = 'Engineering';

-- Add more sample data as needed...
```

## Row Level Security (RLS) Setup

### 1. Enable RLS on All Tables

```sql
-- Enable RLS on all tables
ALTER TABLE users ENABLE ROW LEVEL SECURITY;
ALTER TABLE employees ENABLE ROW LEVEL SECURITY;
ALTER TABLE departments ENABLE ROW LEVEL SECURITY;
ALTER TABLE job_positions ENABLE ROW LEVEL SECURITY;
ALTER TABLE attendance ENABLE ROW LEVEL SECURITY;
ALTER TABLE leave_requests ENABLE ROW LEVEL SECURITY;
ALTER TABLE leave_balances ENABLE ROW LEVEL SECURITY;
ALTER TABLE payroll ENABLE ROW LEVEL SECURITY;
ALTER TABLE performance_reviews ENABLE ROW LEVEL SECURITY;
ALTER TABLE training_records ENABLE ROW LEVEL SECURITY;
ALTER TABLE announcements ENABLE ROW LEVEL SECURITY;
ALTER TABLE audit_logs ENABLE ROW LEVEL SECURITY;
```

### 2. Create RLS Policies

```sql
-- Users table policies
CREATE POLICY "Users can view own profile" ON users
  FOR SELECT USING (auth.uid() = id);

CREATE POLICY "Users can update own profile" ON users
  FOR UPDATE USING (auth.uid() = id);

-- Employees table policies
CREATE POLICY "Employees can view own data" ON employees
  FOR SELECT USING (auth.uid() = user_id);

CREATE POLICY "HR and Admin can view all employees" ON employees
  FOR SELECT USING (
    EXISTS (
      SELECT 1 FROM users 
      WHERE users.id = auth.uid() 
      AND users.role IN ('hr_manager', 'admin', 'super_admin')
    )
  );

CREATE POLICY "HR and Admin can manage employees" ON employees
  FOR ALL USING (
    EXISTS (
      SELECT 1 FROM users 
      WHERE users.id = auth.uid() 
      AND users.role IN ('hr_manager', 'admin', 'super_admin')
    )
  );

-- Attendance policies
CREATE POLICY "Employees can view own attendance" ON attendance
  FOR SELECT USING (
    EXISTS (
      SELECT 1 FROM employees 
      WHERE employees.id = attendance.employee_id 
      AND employees.user_id = auth.uid()
    )
  );

CREATE POLICY "HR can view all attendance" ON attendance
  FOR SELECT USING (
    EXISTS (
      SELECT 1 FROM users 
      WHERE users.id = auth.uid() 
      AND users.role IN ('hr_manager', 'admin', 'super_admin')
    )
  );

-- Leave requests policies
CREATE POLICY "Employees can view own leave requests" ON leave_requests
  FOR SELECT USING (
    EXISTS (
      SELECT 1 FROM employees 
      WHERE employees.id = leave_requests.employee_id 
      AND employees.user_id = auth.uid()
    )
  );

CREATE POLICY "Employees can create own leave requests" ON leave_requests
  FOR INSERT WITH CHECK (
    EXISTS (
      SELECT 1 FROM employees 
      WHERE employees.id = leave_requests.employee_id 
      AND employees.user_id = auth.uid()
    )
  );

CREATE POLICY "HR can manage all leave requests" ON leave_requests
  FOR ALL USING (
    EXISTS (
      SELECT 1 FROM users 
      WHERE users.id = auth.uid() 
      AND users.role IN ('hr_manager', 'admin', 'super_admin')
    )
  );

-- Payroll policies (sensitive data)
CREATE POLICY "Employees can view own payroll" ON payroll
  FOR SELECT USING (
    EXISTS (
      SELECT 1 FROM employees 
      WHERE employees.id = payroll.employee_id 
      AND employees.user_id = auth.uid()
    )
  );

CREATE POLICY "Only HR and Admin can manage payroll" ON payroll
  FOR ALL USING (
    EXISTS (
      SELECT 1 FROM users 
      WHERE users.id = auth.uid() 
      AND users.role IN ('hr_manager', 'admin', 'super_admin')
    )
  );

-- Add similar policies for other tables...
```

## Authentication Configuration

### 1. Configure Auth Settings

1. **Go to Authentication > Settings**
2. **Site URL**: Set to your domain (e.g., `https://your-hr-app.vercel.app`)
3. **Redirect URLs**: Add your callback URLs:
   - `http://localhost:5173/auth/callback` (for development)
   - `https://your-domain.com/auth/callback` (for production)

### 2. Enable Auth Providers (Optional)

- **Email**: Already enabled by default
- **Google**: Configure if you want Google OAuth
- **GitHub**: Configure if you want GitHub OAuth

### 3. Customize Email Templates

Go to Authentication > Templates and customize:
- Confirmation email
- Password recovery email
- Magic link email

## Storage Setup

### 1. Create Storage Buckets

```sql
-- Create buckets for file storage
INSERT INTO storage.buckets (id, name, public, file_size_limit, allowed_mime_types)
VALUES 
  ('employee-documents', 'Employee Documents', false, 52428800, ARRAY['application/pdf', 'image/jpeg', 'image/png', 'application/msword', 'application/vnd.openxmlformats-officedocument.wordprocessingml.document']),
  ('profile-pictures', 'Profile Pictures', true, 5242880, ARRAY['image/jpeg', 'image/png', 'image/webp']),
  ('company-assets', 'Company Assets', true, 10485760, ARRAY['image/jpeg', 'image/png', 'image/webp', 'image/svg+xml']);
```

### 2. Set Storage Policies

```sql
-- Profile pictures policies
CREATE POLICY "Users can upload own profile picture" ON storage.objects
  FOR INSERT WITH CHECK (
    bucket_id = 'profile-pictures' AND
    auth.uid()::text = (storage.foldername(name))[1]
  );

CREATE POLICY "Users can view profile pictures" ON storage.objects
  FOR SELECT USING (bucket_id = 'profile-pictures');

CREATE POLICY "Users can update own profile picture" ON storage.objects
  FOR UPDATE USING (
    bucket_id = 'profile-pictures' AND
    auth.uid()::text = (storage.foldername(name))[1]
  );

-- Employee documents policies
CREATE POLICY "Employees can access own documents" ON storage.objects
  FOR SELECT USING (
    bucket_id = 'employee-documents' AND
    auth.uid()::text = (storage.foldername(name))[1]
  );

CREATE POLICY "HR can access all employee documents" ON storage.objects
  FOR SELECT USING (
    bucket_id = 'employee-documents' AND
    EXISTS (
      SELECT 1 FROM users 
      WHERE users.id = auth.uid() 
      AND users.role IN ('hr_manager', 'admin', 'super_admin')
    )
  );
```

## Environment Variables

Create a `.env` file in your project root:

```env
# Supabase Configuration
VITE_SUPABASE_URL=https://your-project-ref.supabase.co
VITE_SUPABASE_ANON_KEY=your-anon-key-here

# Optional: For server-side operations
SUPABASE_SERVICE_ROLE_KEY=your-service-role-key-here

# App Configuration
VITE_APP_NAME=HR Tech System
VITE_APP_URL=http://localhost:5173
```

**Where to find these values:**
1. Go to your Supabase project dashboard
2. Click "Settings" > "API"
3. Copy the Project URL and anon public key

## Testing the Setup

### 1. Test Database Connection

Create a test file `test-connection.js`:

```javascript
import { createClient } from '@supabase/supabase-js'

const supabaseUrl = 'your-supabase-url'
const supabaseKey = 'your-supabase-anon-key'
const supabase = createClient(supabaseUrl, supabaseKey)

async function testConnection() {
  try {
    const { data, error } = await supabase.from('departments').select('*').limit(1)
    
    if (error) {
      console.error('Connection failed:', error)
    } else {
      console.log('Connection successful:', data)
    }
  } catch (err) {
    console.error('Error:', err)
  }
}

testConnection()
```

### 2. Test Authentication

```javascript
async function testAuth() {
  try {
    // Test sign up
    const { data, error } = await supabase.auth.signUp({
      email: 'test@example.com',
      password: 'testpassword123'
    })
    
    if (error) {
      console.error('Auth test failed:', error)
    } else {
      console.log('Auth test successful:', data)
    }
  } catch (err) {
    console.error('Error:', err)
  }
}
```

## Advanced Configuration

### 1. Database Functions

Create useful database functions:

```sql
-- Function to calculate employee age
CREATE OR REPLACE FUNCTION calculate_age(birth_date DATE)
RETURNS INTEGER AS $$
BEGIN
  RETURN EXTRACT(YEAR FROM AGE(birth_date));
END;
$$ LANGUAGE plpgsql;

-- Function to get employee's current leave balance
CREATE OR REPLACE FUNCTION get_leave_balance(emp_id UUID, leave_type_param leave_type, year_param INTEGER)
RETURNS INTEGER AS $$
DECLARE
  balance INTEGER;
BEGIN
  SELECT remaining_days INTO balance
  FROM leave_balances
  WHERE employee_id = emp_id AND leave_type = leave_type_param AND year = year_param;
  
  RETURN COALESCE(balance, 0);
END;
$$ LANGUAGE plpgsql;
```

### 2. Database Triggers

```sql
-- Trigger to update leave balance when leave is approved
CREATE OR REPLACE FUNCTION update_leave_balance_on_approval()
RETURNS TRIGGER AS $$
BEGIN
  IF NEW.status = 'approved' AND OLD.status != 'approved' THEN
    UPDATE leave_balances
    SET 
      used_days = used_days + NEW.total_days,
      remaining_days = remaining_days - NEW.total_days,
      updated_at = NOW()
    WHERE employee_id = NEW.employee_id 
      AND leave_type = NEW.leave_type 
      AND year = EXTRACT(YEAR FROM NEW.start_date);
  END IF;
  
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trigger_update_leave_balance_on_approval
  AFTER UPDATE ON leave_requests
  FOR EACH ROW
  EXECUTE FUNCTION update_leave_balance_on_approval();
```

## Troubleshooting

### Common Issues

1. **RLS Blocking Queries**
   - Check if RLS policies are correctly configured
   - Ensure the user has the right permissions
   - Test with service role key for debugging

2. **Connection Issues**
   - Verify your Supabase URL and keys
   - Check if your domain is in the allowed origins
   - Ensure your network allows connections to Supabase

3. **Authentication Problems**
   - Check email templates and SMTP configuration
   - Verify redirect URLs are correct
   - Ensure user roles are properly set

### Monitoring and Maintenance

1. **Set up Monitoring**
   - Use Supabase dashboard to monitor performance
   - Set up alerts for high usage or errors
   - Regular backup of your database

2. **Regular Maintenance**
   - Review and update RLS policies
   - Monitor storage usage
   - Clean up old audit logs periodically

## Security Best Practices

1. **Never expose service role keys** in client-side code
2. **Use environment variables** for all sensitive data
3. **Implement proper RLS policies** for all tables
4. **Regular security audits** of your database
5. **Keep Supabase and dependencies updated**

## Next Steps

After completing this setup:

1. Deploy your application
2. Set up CI/CD pipeline
3. Configure monitoring and logging
4. Implement regular backups
5. Set up staging environment

For production deployment, consider:
- Custom domain setup
- SSL certificate configuration
- Performance optimization
- Scaling considerations

## Support

- [Supabase Documentation](https://supabase.com/docs)
- [Supabase Community](https://github.com/supabase/supabase/discussions)
- [PostgreSQL Documentation](https://www.postgresql.org/docs/)

---

*This guide should be regularly updated as your application grows and requirements change.*