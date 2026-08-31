// Script to set up payroll data for the HR system
// This script generates realistic payroll data for demo purposes

// Sample employee data
const employees = [
  {
    id: 'emp-001',
    name: 'John Doe',
    email: 'john.doe@company.com',
    department: 'Engineering',
    position: 'Senior Software Engineer',
    baseSalary: 120000,
    role: 'employee'
  },
  {
    id: 'emp-002',
    name: 'Jane Smith',
    email: 'jane.smith@company.com',
    department: 'Marketing',
    position: 'Marketing Manager',
    baseSalary: 95000,
    role: 'employee'
  },
  {
    id: 'emp-003',
    name: 'Mike Johnson',
    email: 'mike.johnson@company.com',
    department: 'Sales',
    position: 'Sales Executive',
    baseSalary: 75000,
    role: 'employee'
  },
  {
    id: 'emp-004',
    name: 'Sarah Williams',
    email: 'sarah.williams@company.com',
    department: 'HR',
    position: 'HR Specialist',
    baseSalary: 65000,
    role: 'hr_manager'
  },
  {
    id: 'emp-005',
    name: 'David Brown',
    email: 'david.brown@company.com',
    department: 'Finance',
    position: 'Financial Analyst',
    baseSalary: 70000,
    role: 'employee'
  },
  {
    id: 'emp-006',
    name: 'Lisa Davis',
    email: 'lisa.davis@company.com',
    department: 'Engineering',
    position: 'DevOps Engineer',
    baseSalary: 110000,
    role: 'employee'
  },
  {
    id: 'emp-007',
    name: 'Robert Wilson',
    email: 'robert.wilson@company.com',
    department: 'Operations',
    position: 'Operations Manager',
    baseSalary: 85000,
    role: 'employee'
  },
  {
    id: 'emp-008',
    name: 'Emma Taylor',
    email: 'emma.taylor@company.com',
    department: 'Marketing',
    position: 'Content Creator',
    baseSalary: 55000,
    role: 'employee'
  },
  {
    id: 'emp-009',
    name: 'James Miller',
    email: 'james.miller@company.com',
    department: 'Sales',
    position: 'Sales Manager',
    baseSalary: 90000,
    role: 'employee'
  },
  {
    id: 'emp-010',
    name: 'Maria Garcia',
    email: 'maria.garcia@company.com',
    department: 'Finance',
    position: 'Accountant',
    baseSalary: 60000,
    role: 'employee'
  }
];

// Generate payroll records for multiple months
const months = ['2024-07', '2024-08', '2024-09', '2024-10'];

// Function to generate payroll data for an employee and month
function generatePayrollRecord(employee, period) {
  // Parse period (YYYY-MM)
  const [year, month] = period.split('-').map(Number);
  const periodDate = new Date(year, month - 1, 1);
  
  // Generate random variations for realism
  const attendanceRate = 0.95 + Math.random() * 0.05; // 95-100% attendance
  const overtimeHours = Math.floor(Math.random() * 10); // 0-10 overtime hours
  const bonusChance = Math.random();
  const bonus = bonusChance > 0.7 ? Math.floor(Math.random() * 2000) + 500 : 0; // 20% chance of bonus
  
  // Calculate monthly salary
  const monthlyBaseSalary = employee.baseSalary / 12;
  
  // Calculate overtime pay (1.5x hourly rate)
  const hourlyRate = monthlyBaseSalary / 160; // Assuming 160 working hours per month
  const overtimePay = overtimeHours * hourlyRate * 1.5;
  
  // Calculate deductions
  const taxRate = 0.22; // 22% tax
  const insuranceRate = 0.05; // 5% insurance
  const pfRate = 0.12; // 12% provident fund
  
  const grossSalary = monthlyBaseSalary + overtimePay + bonus;
  const taxDeduction = monthlyBaseSalary * taxRate;
  const insuranceDeduction = monthlyBaseSalary * insuranceRate;
  const pfDeduction = monthlyBaseSalary * pfRate;
  const otherDeductions = Math.floor(Math.random() * 100); // Random small deductions
  
  const totalDeductions = taxDeduction + insuranceDeduction + pfDeduction + otherDeductions;
  const netSalary = grossSalary - totalDeductions;
  
  return {
    id: `pay-${employee.id}-${period}`,
    employeeId: employee.id,
    employeeName: employee.name,
    employeeCode: `EMP${employee.id.split('-')[1]}`,
    department: employee.department,
    designation: employee.position,
    period: period,
    salary: {
      basic: monthlyBaseSalary,
      hra: monthlyBaseSalary * 0.4, // 40% HRA
      allowances: monthlyBaseSalary * 0.2, // 20% allowances
      bonus: bonus
    },
    deductions: {
      pf: pfDeduction,
      esi: insuranceDeduction,
      tax: taxDeduction,
      other: otherDeductions
    },
    status: 'processed',
    generatedOn: new Date(year, month - 1, 28).toISOString().split('T')[0], // End of month
    paidOn: new Date(year, month - 1, 30).toISOString().split('T')[0]
  };
}

// Generate all payroll records
const allPayrollRecords = [];
months.forEach(month => {
  employees.forEach(employee => {
    const record = generatePayrollRecord(employee, month);
    allPayrollRecords.push(record);
  });
});

// Create the payroll data script content
const payrollDataScript = `// Payroll data setup script
(function() {
  // Payroll records
  const payrollRecords = ${JSON.stringify(allPayrollRecords, null, 2)};
  
  // Save to localStorage
  localStorage.setItem('payrollRecords', JSON.stringify(payrollRecords));
  
  console.log('Payroll data has been set up with ' + payrollRecords.length + ' records');
  console.log('Records cover ' + ${JSON.stringify(months)} + ' periods');
  console.log('For employees: ' + ${JSON.stringify(employees.map(e => e.name))});
})();`;

// Write the script to a file using fs.writeFileSync with a callback
import { writeFileSync } from 'fs';

try {
  // Write the script file
  writeFileSync('public/payroll-setup.js', payrollDataScript);
  
  console.log('Payroll data setup script created successfully!');
  console.log('File: public/payroll-setup.js');
  console.log('Records generated: ' + allPayrollRecords.length);
  console.log('Periods covered: ' + months.join(', '));
  console.log('');
  console.log('To use this data:');
  console.log('1. Include the script in your HTML: <script src="payroll-setup.js"></script>');
  console.log('2. Or run it in the browser console to populate localStorage');

  // Also create a JSON file with the raw data
  writeFileSync('public/payroll-data.json', JSON.stringify(allPayrollRecords, null, 2));

  console.log('');
  console.log('Raw payroll data saved to: public/payroll-data.json');
} catch (error) {
  console.error('Error writing files:', error);
}