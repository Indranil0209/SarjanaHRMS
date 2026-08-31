-- Update Non-IT company_type for all Non-IT users
-- This ensures the dashboard routing correctly identifies Non-IT HR Managers

UPDATE users 
SET company_type = 'non-it' 
WHERE email IN (
  'nonitadmin@company.com',
  'nonithr@company.com',
  'nonitemployee1@company.com',
  'nonitemployee2@company.com',
  'nonitemployee3@company.com'
);

-- Verify the update
SELECT email, role, company_type FROM users 
WHERE email IN (
  'nonitadmin@company.com',
  'nonithr@company.com',
  'nonitemployee1@company.com',
  'nonitemployee2@company.com',
  'nonitemployee3@company.com'
)
ORDER BY email;
