// Payroll data setup script
(function() {
  // Payroll records
  const payrollRecords = [
  {
    "id": "pay-emp-001-2024-07",
    "employeeId": "emp-001",
    "employeeName": "John Doe",
    "employeeCode": "EMP001",
    "department": "Engineering",
    "designation": "Senior Software Engineer",
    "period": "2024-07",
    "salary": {
      "basic": 10000,
      "hra": 4000,
      "allowances": 2000,
      "bonus": 0
    },
    "deductions": {
      "pf": 1200,
      "esi": 500,
      "tax": 2200,
      "other": 60
    },
    "status": "processed",
    "generatedOn": "2024-07-27",
    "paidOn": "2024-07-29"
  },
  {
    "id": "pay-emp-002-2024-07",
    "employeeId": "emp-002",
    "employeeName": "Jane Smith",
    "employeeCode": "EMP002",
    "department": "Marketing",
    "designation": "Marketing Manager",
    "period": "2024-07",
    "salary": {
      "basic": 7916.666666666667,
      "hra": 3166.666666666667,
      "allowances": 1583.3333333333335,
      "bonus": 1302
    },
    "deductions": {
      "pf": 950,
      "esi": 395.83333333333337,
      "tax": 1741.6666666666667,
      "other": 47
    },
    "status": "processed",
    "generatedOn": "2024-07-27",
    "paidOn": "2024-07-29"
  },
  {
    "id": "pay-emp-003-2024-07",
    "employeeId": "emp-003",
    "employeeName": "Mike Johnson",
    "employeeCode": "EMP003",
    "department": "Sales",
    "designation": "Sales Executive",
    "period": "2024-07",
    "salary": {
      "basic": 6250,
      "hra": 2500,
      "allowances": 1250,
      "bonus": 0
    },
    "deductions": {
      "pf": 750,
      "esi": 312.5,
      "tax": 1375,
      "other": 64
    },
    "status": "processed",
    "generatedOn": "2024-07-27",
    "paidOn": "2024-07-29"
  },
  {
    "id": "pay-emp-004-2024-07",
    "employeeId": "emp-004",
    "employeeName": "Sarah Williams",
    "employeeCode": "EMP004",
    "department": "HR",
    "designation": "HR Specialist",
    "period": "2024-07",
    "salary": {
      "basic": 5416.666666666667,
      "hra": 2166.666666666667,
      "allowances": 1083.3333333333335,
      "bonus": 0
    },
    "deductions": {
      "pf": 650,
      "esi": 270.83333333333337,
      "tax": 1191.6666666666667,
      "other": 93
    },
    "status": "processed",
    "generatedOn": "2024-07-27",
    "paidOn": "2024-07-29"
  },
  {
    "id": "pay-emp-005-2024-07",
    "employeeId": "emp-005",
    "employeeName": "David Brown",
    "employeeCode": "EMP005",
    "department": "Finance",
    "designation": "Financial Analyst",
    "period": "2024-07",
    "salary": {
      "basic": 5833.333333333333,
      "hra": 2333.3333333333335,
      "allowances": 1166.6666666666667,
      "bonus": 0
    },
    "deductions": {
      "pf": 699.9999999999999,
      "esi": 291.6666666666667,
      "tax": 1283.3333333333333,
      "other": 64
    },
    "status": "processed",
    "generatedOn": "2024-07-27",
    "paidOn": "2024-07-29"
  },
  {
    "id": "pay-emp-006-2024-07",
    "employeeId": "emp-006",
    "employeeName": "Lisa Davis",
    "employeeCode": "EMP006",
    "department": "Engineering",
    "designation": "DevOps Engineer",
    "period": "2024-07",
    "salary": {
      "basic": 9166.666666666666,
      "hra": 3666.6666666666665,
      "allowances": 1833.3333333333333,
      "bonus": 0
    },
    "deductions": {
      "pf": 1100,
      "esi": 458.3333333333333,
      "tax": 2016.6666666666665,
      "other": 2
    },
    "status": "processed",
    "generatedOn": "2024-07-27",
    "paidOn": "2024-07-29"
  },
  {
    "id": "pay-emp-007-2024-07",
    "employeeId": "emp-007",
    "employeeName": "Robert Wilson",
    "employeeCode": "EMP007",
    "department": "Operations",
    "designation": "Operations Manager",
    "period": "2024-07",
    "salary": {
      "basic": 7083.333333333333,
      "hra": 2833.3333333333335,
      "allowances": 1416.6666666666667,
      "bonus": 1677
    },
    "deductions": {
      "pf": 849.9999999999999,
      "esi": 354.1666666666667,
      "tax": 1558.3333333333333,
      "other": 94
    },
    "status": "processed",
    "generatedOn": "2024-07-27",
    "paidOn": "2024-07-29"
  },
  {
    "id": "pay-emp-008-2024-07",
    "employeeId": "emp-008",
    "employeeName": "Emma Taylor",
    "employeeCode": "EMP008",
    "department": "Marketing",
    "designation": "Content Creator",
    "period": "2024-07",
    "salary": {
      "basic": 4583.333333333333,
      "hra": 1833.3333333333333,
      "allowances": 916.6666666666666,
      "bonus": 0
    },
    "deductions": {
      "pf": 550,
      "esi": 229.16666666666666,
      "tax": 1008.3333333333333,
      "other": 64
    },
    "status": "processed",
    "generatedOn": "2024-07-27",
    "paidOn": "2024-07-29"
  },
  {
    "id": "pay-emp-009-2024-07",
    "employeeId": "emp-009",
    "employeeName": "James Miller",
    "employeeCode": "EMP009",
    "department": "Sales",
    "designation": "Sales Manager",
    "period": "2024-07",
    "salary": {
      "basic": 7500,
      "hra": 3000,
      "allowances": 1500,
      "bonus": 2098
    },
    "deductions": {
      "pf": 900,
      "esi": 375,
      "tax": 1650,
      "other": 74
    },
    "status": "processed",
    "generatedOn": "2024-07-27",
    "paidOn": "2024-07-29"
  },
  {
    "id": "pay-emp-010-2024-07",
    "employeeId": "emp-010",
    "employeeName": "Maria Garcia",
    "employeeCode": "EMP010",
    "department": "Finance",
    "designation": "Accountant",
    "period": "2024-07",
    "salary": {
      "basic": 5000,
      "hra": 2000,
      "allowances": 1000,
      "bonus": 533
    },
    "deductions": {
      "pf": 600,
      "esi": 250,
      "tax": 1100,
      "other": 43
    },
    "status": "processed",
    "generatedOn": "2024-07-27",
    "paidOn": "2024-07-29"
  },
  {
    "id": "pay-emp-001-2024-08",
    "employeeId": "emp-001",
    "employeeName": "John Doe",
    "employeeCode": "EMP001",
    "department": "Engineering",
    "designation": "Senior Software Engineer",
    "period": "2024-08",
    "salary": {
      "basic": 10000,
      "hra": 4000,
      "allowances": 2000,
      "bonus": 2255
    },
    "deductions": {
      "pf": 1200,
      "esi": 500,
      "tax": 2200,
      "other": 28
    },
    "status": "processed",
    "generatedOn": "2024-08-27",
    "paidOn": "2024-08-29"
  },
  {
    "id": "pay-emp-002-2024-08",
    "employeeId": "emp-002",
    "employeeName": "Jane Smith",
    "employeeCode": "EMP002",
    "department": "Marketing",
    "designation": "Marketing Manager",
    "period": "2024-08",
    "salary": {
      "basic": 7916.666666666667,
      "hra": 3166.666666666667,
      "allowances": 1583.3333333333335,
      "bonus": 0
    },
    "deductions": {
      "pf": 950,
      "esi": 395.83333333333337,
      "tax": 1741.6666666666667,
      "other": 41
    },
    "status": "processed",
    "generatedOn": "2024-08-27",
    "paidOn": "2024-08-29"
  },
  {
    "id": "pay-emp-003-2024-08",
    "employeeId": "emp-003",
    "employeeName": "Mike Johnson",
    "employeeCode": "EMP003",
    "department": "Sales",
    "designation": "Sales Executive",
    "period": "2024-08",
    "salary": {
      "basic": 6250,
      "hra": 2500,
      "allowances": 1250,
      "bonus": 0
    },
    "deductions": {
      "pf": 750,
      "esi": 312.5,
      "tax": 1375,
      "other": 12
    },
    "status": "processed",
    "generatedOn": "2024-08-27",
    "paidOn": "2024-08-29"
  },
  {
    "id": "pay-emp-004-2024-08",
    "employeeId": "emp-004",
    "employeeName": "Sarah Williams",
    "employeeCode": "EMP004",
    "department": "HR",
    "designation": "HR Specialist",
    "period": "2024-08",
    "salary": {
      "basic": 5416.666666666667,
      "hra": 2166.666666666667,
      "allowances": 1083.3333333333335,
      "bonus": 1834
    },
    "deductions": {
      "pf": 650,
      "esi": 270.83333333333337,
      "tax": 1191.6666666666667,
      "other": 2
    },
    "status": "processed",
    "generatedOn": "2024-08-27",
    "paidOn": "2024-08-29"
  },
  {
    "id": "pay-emp-005-2024-08",
    "employeeId": "emp-005",
    "employeeName": "David Brown",
    "employeeCode": "EMP005",
    "department": "Finance",
    "designation": "Financial Analyst",
    "period": "2024-08",
    "salary": {
      "basic": 5833.333333333333,
      "hra": 2333.3333333333335,
      "allowances": 1166.6666666666667,
      "bonus": 2161
    },
    "deductions": {
      "pf": 699.9999999999999,
      "esi": 291.6666666666667,
      "tax": 1283.3333333333333,
      "other": 22
    },
    "status": "processed",
    "generatedOn": "2024-08-27",
    "paidOn": "2024-08-29"
  },
  {
    "id": "pay-emp-006-2024-08",
    "employeeId": "emp-006",
    "employeeName": "Lisa Davis",
    "employeeCode": "EMP006",
    "department": "Engineering",
    "designation": "DevOps Engineer",
    "period": "2024-08",
    "salary": {
      "basic": 9166.666666666666,
      "hra": 3666.6666666666665,
      "allowances": 1833.3333333333333,
      "bonus": 2232
    },
    "deductions": {
      "pf": 1100,
      "esi": 458.3333333333333,
      "tax": 2016.6666666666665,
      "other": 34
    },
    "status": "processed",
    "generatedOn": "2024-08-27",
    "paidOn": "2024-08-29"
  },
  {
    "id": "pay-emp-007-2024-08",
    "employeeId": "emp-007",
    "employeeName": "Robert Wilson",
    "employeeCode": "EMP007",
    "department": "Operations",
    "designation": "Operations Manager",
    "period": "2024-08",
    "salary": {
      "basic": 7083.333333333333,
      "hra": 2833.3333333333335,
      "allowances": 1416.6666666666667,
      "bonus": 671
    },
    "deductions": {
      "pf": 849.9999999999999,
      "esi": 354.1666666666667,
      "tax": 1558.3333333333333,
      "other": 56
    },
    "status": "processed",
    "generatedOn": "2024-08-27",
    "paidOn": "2024-08-29"
  },
  {
    "id": "pay-emp-008-2024-08",
    "employeeId": "emp-008",
    "employeeName": "Emma Taylor",
    "employeeCode": "EMP008",
    "department": "Marketing",
    "designation": "Content Creator",
    "period": "2024-08",
    "salary": {
      "basic": 4583.333333333333,
      "hra": 1833.3333333333333,
      "allowances": 916.6666666666666,
      "bonus": 0
    },
    "deductions": {
      "pf": 550,
      "esi": 229.16666666666666,
      "tax": 1008.3333333333333,
      "other": 97
    },
    "status": "processed",
    "generatedOn": "2024-08-27",
    "paidOn": "2024-08-29"
  },
  {
    "id": "pay-emp-009-2024-08",
    "employeeId": "emp-009",
    "employeeName": "James Miller",
    "employeeCode": "EMP009",
    "department": "Sales",
    "designation": "Sales Manager",
    "period": "2024-08",
    "salary": {
      "basic": 7500,
      "hra": 3000,
      "allowances": 1500,
      "bonus": 0
    },
    "deductions": {
      "pf": 900,
      "esi": 375,
      "tax": 1650,
      "other": 87
    },
    "status": "processed",
    "generatedOn": "2024-08-27",
    "paidOn": "2024-08-29"
  },
  {
    "id": "pay-emp-010-2024-08",
    "employeeId": "emp-010",
    "employeeName": "Maria Garcia",
    "employeeCode": "EMP010",
    "department": "Finance",
    "designation": "Accountant",
    "period": "2024-08",
    "salary": {
      "basic": 5000,
      "hra": 2000,
      "allowances": 1000,
      "bonus": 0
    },
    "deductions": {
      "pf": 600,
      "esi": 250,
      "tax": 1100,
      "other": 62
    },
    "status": "processed",
    "generatedOn": "2024-08-27",
    "paidOn": "2024-08-29"
  },
  {
    "id": "pay-emp-001-2024-09",
    "employeeId": "emp-001",
    "employeeName": "John Doe",
    "employeeCode": "EMP001",
    "department": "Engineering",
    "designation": "Senior Software Engineer",
    "period": "2024-09",
    "salary": {
      "basic": 10000,
      "hra": 4000,
      "allowances": 2000,
      "bonus": 952
    },
    "deductions": {
      "pf": 1200,
      "esi": 500,
      "tax": 2200,
      "other": 55
    },
    "status": "processed",
    "generatedOn": "2024-09-27",
    "paidOn": "2024-09-29"
  },
  {
    "id": "pay-emp-002-2024-09",
    "employeeId": "emp-002",
    "employeeName": "Jane Smith",
    "employeeCode": "EMP002",
    "department": "Marketing",
    "designation": "Marketing Manager",
    "period": "2024-09",
    "salary": {
      "basic": 7916.666666666667,
      "hra": 3166.666666666667,
      "allowances": 1583.3333333333335,
      "bonus": 2013
    },
    "deductions": {
      "pf": 950,
      "esi": 395.83333333333337,
      "tax": 1741.6666666666667,
      "other": 96
    },
    "status": "processed",
    "generatedOn": "2024-09-27",
    "paidOn": "2024-09-29"
  },
  {
    "id": "pay-emp-003-2024-09",
    "employeeId": "emp-003",
    "employeeName": "Mike Johnson",
    "employeeCode": "EMP003",
    "department": "Sales",
    "designation": "Sales Executive",
    "period": "2024-09",
    "salary": {
      "basic": 6250,
      "hra": 2500,
      "allowances": 1250,
      "bonus": 666
    },
    "deductions": {
      "pf": 750,
      "esi": 312.5,
      "tax": 1375,
      "other": 80
    },
    "status": "processed",
    "generatedOn": "2024-09-27",
    "paidOn": "2024-09-29"
  },
  {
    "id": "pay-emp-004-2024-09",
    "employeeId": "emp-004",
    "employeeName": "Sarah Williams",
    "employeeCode": "EMP004",
    "department": "HR",
    "designation": "HR Specialist",
    "period": "2024-09",
    "salary": {
      "basic": 5416.666666666667,
      "hra": 2166.666666666667,
      "allowances": 1083.3333333333335,
      "bonus": 0
    },
    "deductions": {
      "pf": 650,
      "esi": 270.83333333333337,
      "tax": 1191.6666666666667,
      "other": 99
    },
    "status": "processed",
    "generatedOn": "2024-09-27",
    "paidOn": "2024-09-29"
  },
  {
    "id": "pay-emp-005-2024-09",
    "employeeId": "emp-005",
    "employeeName": "David Brown",
    "employeeCode": "EMP005",
    "department": "Finance",
    "designation": "Financial Analyst",
    "period": "2024-09",
    "salary": {
      "basic": 5833.333333333333,
      "hra": 2333.3333333333335,
      "allowances": 1166.6666666666667,
      "bonus": 0
    },
    "deductions": {
      "pf": 699.9999999999999,
      "esi": 291.6666666666667,
      "tax": 1283.3333333333333,
      "other": 77
    },
    "status": "processed",
    "generatedOn": "2024-09-27",
    "paidOn": "2024-09-29"
  },
  {
    "id": "pay-emp-006-2024-09",
    "employeeId": "emp-006",
    "employeeName": "Lisa Davis",
    "employeeCode": "EMP006",
    "department": "Engineering",
    "designation": "DevOps Engineer",
    "period": "2024-09",
    "salary": {
      "basic": 9166.666666666666,
      "hra": 3666.6666666666665,
      "allowances": 1833.3333333333333,
      "bonus": 1810
    },
    "deductions": {
      "pf": 1100,
      "esi": 458.3333333333333,
      "tax": 2016.6666666666665,
      "other": 1
    },
    "status": "processed",
    "generatedOn": "2024-09-27",
    "paidOn": "2024-09-29"
  },
  {
    "id": "pay-emp-007-2024-09",
    "employeeId": "emp-007",
    "employeeName": "Robert Wilson",
    "employeeCode": "EMP007",
    "department": "Operations",
    "designation": "Operations Manager",
    "period": "2024-09",
    "salary": {
      "basic": 7083.333333333333,
      "hra": 2833.3333333333335,
      "allowances": 1416.6666666666667,
      "bonus": 0
    },
    "deductions": {
      "pf": 849.9999999999999,
      "esi": 354.1666666666667,
      "tax": 1558.3333333333333,
      "other": 31
    },
    "status": "processed",
    "generatedOn": "2024-09-27",
    "paidOn": "2024-09-29"
  },
  {
    "id": "pay-emp-008-2024-09",
    "employeeId": "emp-008",
    "employeeName": "Emma Taylor",
    "employeeCode": "EMP008",
    "department": "Marketing",
    "designation": "Content Creator",
    "period": "2024-09",
    "salary": {
      "basic": 4583.333333333333,
      "hra": 1833.3333333333333,
      "allowances": 916.6666666666666,
      "bonus": 1218
    },
    "deductions": {
      "pf": 550,
      "esi": 229.16666666666666,
      "tax": 1008.3333333333333,
      "other": 35
    },
    "status": "processed",
    "generatedOn": "2024-09-27",
    "paidOn": "2024-09-29"
  },
  {
    "id": "pay-emp-009-2024-09",
    "employeeId": "emp-009",
    "employeeName": "James Miller",
    "employeeCode": "EMP009",
    "department": "Sales",
    "designation": "Sales Manager",
    "period": "2024-09",
    "salary": {
      "basic": 7500,
      "hra": 3000,
      "allowances": 1500,
      "bonus": 664
    },
    "deductions": {
      "pf": 900,
      "esi": 375,
      "tax": 1650,
      "other": 89
    },
    "status": "processed",
    "generatedOn": "2024-09-27",
    "paidOn": "2024-09-29"
  },
  {
    "id": "pay-emp-010-2024-09",
    "employeeId": "emp-010",
    "employeeName": "Maria Garcia",
    "employeeCode": "EMP010",
    "department": "Finance",
    "designation": "Accountant",
    "period": "2024-09",
    "salary": {
      "basic": 5000,
      "hra": 2000,
      "allowances": 1000,
      "bonus": 0
    },
    "deductions": {
      "pf": 600,
      "esi": 250,
      "tax": 1100,
      "other": 43
    },
    "status": "processed",
    "generatedOn": "2024-09-27",
    "paidOn": "2024-09-29"
  },
  {
    "id": "pay-emp-001-2024-10",
    "employeeId": "emp-001",
    "employeeName": "John Doe",
    "employeeCode": "EMP001",
    "department": "Engineering",
    "designation": "Senior Software Engineer",
    "period": "2024-10",
    "salary": {
      "basic": 10000,
      "hra": 4000,
      "allowances": 2000,
      "bonus": 1982
    },
    "deductions": {
      "pf": 1200,
      "esi": 500,
      "tax": 2200,
      "other": 39
    },
    "status": "processed",
    "generatedOn": "2024-10-27",
    "paidOn": "2024-10-29"
  },
  {
    "id": "pay-emp-002-2024-10",
    "employeeId": "emp-002",
    "employeeName": "Jane Smith",
    "employeeCode": "EMP002",
    "department": "Marketing",
    "designation": "Marketing Manager",
    "period": "2024-10",
    "salary": {
      "basic": 7916.666666666667,
      "hra": 3166.666666666667,
      "allowances": 1583.3333333333335,
      "bonus": 0
    },
    "deductions": {
      "pf": 950,
      "esi": 395.83333333333337,
      "tax": 1741.6666666666667,
      "other": 49
    },
    "status": "processed",
    "generatedOn": "2024-10-27",
    "paidOn": "2024-10-29"
  },
  {
    "id": "pay-emp-003-2024-10",
    "employeeId": "emp-003",
    "employeeName": "Mike Johnson",
    "employeeCode": "EMP003",
    "department": "Sales",
    "designation": "Sales Executive",
    "period": "2024-10",
    "salary": {
      "basic": 6250,
      "hra": 2500,
      "allowances": 1250,
      "bonus": 0
    },
    "deductions": {
      "pf": 750,
      "esi": 312.5,
      "tax": 1375,
      "other": 71
    },
    "status": "processed",
    "generatedOn": "2024-10-27",
    "paidOn": "2024-10-29"
  },
  {
    "id": "pay-emp-004-2024-10",
    "employeeId": "emp-004",
    "employeeName": "Sarah Williams",
    "employeeCode": "EMP004",
    "department": "HR",
    "designation": "HR Specialist",
    "period": "2024-10",
    "salary": {
      "basic": 5416.666666666667,
      "hra": 2166.666666666667,
      "allowances": 1083.3333333333335,
      "bonus": 0
    },
    "deductions": {
      "pf": 650,
      "esi": 270.83333333333337,
      "tax": 1191.6666666666667,
      "other": 56
    },
    "status": "processed",
    "generatedOn": "2024-10-27",
    "paidOn": "2024-10-29"
  },
  {
    "id": "pay-emp-005-2024-10",
    "employeeId": "emp-005",
    "employeeName": "David Brown",
    "employeeCode": "EMP005",
    "department": "Finance",
    "designation": "Financial Analyst",
    "period": "2024-10",
    "salary": {
      "basic": 5833.333333333333,
      "hra": 2333.3333333333335,
      "allowances": 1166.6666666666667,
      "bonus": 942
    },
    "deductions": {
      "pf": 699.9999999999999,
      "esi": 291.6666666666667,
      "tax": 1283.3333333333333,
      "other": 68
    },
    "status": "processed",
    "generatedOn": "2024-10-27",
    "paidOn": "2024-10-29"
  },
  {
    "id": "pay-emp-006-2024-10",
    "employeeId": "emp-006",
    "employeeName": "Lisa Davis",
    "employeeCode": "EMP006",
    "department": "Engineering",
    "designation": "DevOps Engineer",
    "period": "2024-10",
    "salary": {
      "basic": 9166.666666666666,
      "hra": 3666.6666666666665,
      "allowances": 1833.3333333333333,
      "bonus": 0
    },
    "deductions": {
      "pf": 1100,
      "esi": 458.3333333333333,
      "tax": 2016.6666666666665,
      "other": 62
    },
    "status": "processed",
    "generatedOn": "2024-10-27",
    "paidOn": "2024-10-29"
  },
  {
    "id": "pay-emp-007-2024-10",
    "employeeId": "emp-007",
    "employeeName": "Robert Wilson",
    "employeeCode": "EMP007",
    "department": "Operations",
    "designation": "Operations Manager",
    "period": "2024-10",
    "salary": {
      "basic": 7083.333333333333,
      "hra": 2833.3333333333335,
      "allowances": 1416.6666666666667,
      "bonus": 0
    },
    "deductions": {
      "pf": 849.9999999999999,
      "esi": 354.1666666666667,
      "tax": 1558.3333333333333,
      "other": 13
    },
    "status": "processed",
    "generatedOn": "2024-10-27",
    "paidOn": "2024-10-29"
  },
  {
    "id": "pay-emp-008-2024-10",
    "employeeId": "emp-008",
    "employeeName": "Emma Taylor",
    "employeeCode": "EMP008",
    "department": "Marketing",
    "designation": "Content Creator",
    "period": "2024-10",
    "salary": {
      "basic": 4583.333333333333,
      "hra": 1833.3333333333333,
      "allowances": 916.6666666666666,
      "bonus": 0
    },
    "deductions": {
      "pf": 550,
      "esi": 229.16666666666666,
      "tax": 1008.3333333333333,
      "other": 47
    },
    "status": "processed",
    "generatedOn": "2024-10-27",
    "paidOn": "2024-10-29"
  },
  {
    "id": "pay-emp-009-2024-10",
    "employeeId": "emp-009",
    "employeeName": "James Miller",
    "employeeCode": "EMP009",
    "department": "Sales",
    "designation": "Sales Manager",
    "period": "2024-10",
    "salary": {
      "basic": 7500,
      "hra": 3000,
      "allowances": 1500,
      "bonus": 1333
    },
    "deductions": {
      "pf": 900,
      "esi": 375,
      "tax": 1650,
      "other": 17
    },
    "status": "processed",
    "generatedOn": "2024-10-27",
    "paidOn": "2024-10-29"
  },
  {
    "id": "pay-emp-010-2024-10",
    "employeeId": "emp-010",
    "employeeName": "Maria Garcia",
    "employeeCode": "EMP010",
    "department": "Finance",
    "designation": "Accountant",
    "period": "2024-10",
    "salary": {
      "basic": 5000,
      "hra": 2000,
      "allowances": 1000,
      "bonus": 0
    },
    "deductions": {
      "pf": 600,
      "esi": 250,
      "tax": 1100,
      "other": 35
    },
    "status": "processed",
    "generatedOn": "2024-10-27",
    "paidOn": "2024-10-29"
  }
];
  
  // Save to localStorage
  localStorage.setItem('payrollRecords', JSON.stringify(payrollRecords));
  
  console.log('Payroll data has been set up with ' + payrollRecords.length + ' records');
  console.log('Records cover ' + ["2024-07","2024-08","2024-09","2024-10"] + ' periods');
  console.log('For employees: ' + ["John Doe","Jane Smith","Mike Johnson","Sarah Williams","David Brown","Lisa Davis","Robert Wilson","Emma Taylor","James Miller","Maria Garcia"]);
})();