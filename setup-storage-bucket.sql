-- SQL Script to setup the employee-docs bucket for KYC document uploads

-- 1. Create the bucket if it doesn't exist
INSERT INTO storage.buckets (id, name, public, file_size_limit, allowed_mime_types)
VALUES (
  'employee-docs', 
  'employee-docs', 
  false, -- false means it's a private bucket
  5242880, -- 5MB limit
  ARRAY['application/pdf', 'image/jpeg', 'image/png']
) ON CONFLICT (id) DO NOTHING;

-- 2. Drop existing policies to avoid conflicts if they exist
DROP POLICY IF EXISTS "Employees can upload own documents" ON storage.objects;
DROP POLICY IF EXISTS "Employees can access own documents" ON storage.objects;
DROP POLICY IF EXISTS "HR can access all employee documents" ON storage.objects;

-- 3. RLS Policies for employee-docs bucket

-- Allow employees to upload documents
CREATE POLICY "Employees can upload own documents" ON storage.objects
  FOR INSERT WITH CHECK (
    bucket_id = 'employee-docs' AND
    auth.uid() IN (SELECT user_id FROM public.employees)
  );

-- Allow employees to view their own documents
CREATE POLICY "Employees can access own documents" ON storage.objects
  FOR SELECT USING (
    bucket_id = 'employee-docs'
  );

-- Allow HR and Admins to access all employee documents
CREATE POLICY "HR can access all employee documents" ON storage.objects
  FOR SELECT USING (
    bucket_id = 'employee-docs' AND
    EXISTS (
      SELECT 1 FROM public.users 
      WHERE users.id = auth.uid() 
      AND users.role IN ('hr_manager', 'admin', 'super_admin')
    )
  );
