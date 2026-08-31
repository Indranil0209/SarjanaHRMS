import { createClient } from '@supabase/supabase-js';
import { generateCompanyCode } from './SarjanaHRMS-main/src/utils/companyCodeGenerator.js';

const supabaseUrl = 'https://ykcpdolezschqwcueuil.supabase.co';
const supabaseAnonKey = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InlrY3Bkb2xlenNjaHF3Y3VldWlsIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NjI1MTM5NTYsImV4cCI6MjA3ODA4OTk1Nn0.TTu20eDWZRUrgX8AF4KcGsuhoAkL6jwZ-kTo1VjIooM';

const supabase = createClient(supabaseUrl, supabaseAnonKey);

(async () => {
  try {
    console.log('🧪 Testing company creation with code generation...\n');

    const testCompanyName = `Test Company ${Date.now()}`;
    const companyCode = generateCompanyCode(testCompanyName);

    console.log(`📝 Creating company: "${testCompanyName}"`);
    console.log(`🔑 Generated code: ${companyCode}\n`);

    const { data, error } = await supabase
      .from('companies')
      .insert({
        company_name: testCompanyName,
        company_name_lower: testCompanyName.toLowerCase(),
        company_code: companyCode,
        domain: 'test.com',
        industry: 'Technology',
        size: 'small',
        status: 'active'
      })
      .select()
      .single();

    if (error) {
      console.log('❌ ERROR creating company:');
      console.log(error);
    } else {
      console.log('✅ Company created successfully!');
      console.log('📊 Company Data:');
      console.log({
        id: data.id,
        company_name: data.company_name,
        company_code: data.company_code,
        status: data.status,
        created_at: data.created_at
      });

      console.log('\n🎯 Code generation is working! Companies now will have codes.');
    }
  } catch (err) {
    console.log('💥 Exception:', err.message);
  }
})();
