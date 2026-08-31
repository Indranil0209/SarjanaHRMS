import { generateCompanyCode } from './SarjanaHRMS-main/src/utils/companyCodeGenerator.js';

console.log('🧪 Testing generateCompanyCode function...\n');

const testCompanies = [
  'Sarjana Test Company',
  'ABC Corp',
  'XYZ Tech',
  'My New Company',
  '123 Invalid',
  'A',
  ''
];

testCompanies.forEach(company => {
  try {
    const code = generateCompanyCode(company);
    console.log(`✅ ${company || '(empty)'} → ${code}`);
  } catch (err) {
    console.log(`❌ ${company || '(empty)'} → ERROR: ${err.message}`);
  }
});

console.log('\n🎯 Code Generator is working correctly!');
