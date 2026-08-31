import { createClient } from '@supabase/supabase-js';

const supabaseUrl = 'https://ykcpdolezschqwcueuil.supabase.co';
const supabaseAnonKey = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InlrY3Bkb2xlenNjaHF3Y3VldWlsIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NjI1MTM5NTYsImV4cCI6MjA3ODA4OTk1Nn0.TTu20eDWZRUrgX8AF4KcGsuhoAkL6jwZ-kTo1VjIooM';

const supabase = createClient(supabaseUrl, supabaseAnonKey);

(async () => {
  try {
    console.log('📋 Fetching all companies...\n');

    const { data, error } = await supabase
      .from('companies')
      .select('id, company_name, company_code, domain, industry, status, created_at')
      .order('created_at', { ascending: false });

    if (error) {
      console.log('❌ Error:', error);
    } else {
      console.log(`✅ Total companies: ${data?.length || 0}\n`);
      if (data && data.length > 0) {
        console.log('🏢 Company List:');
        console.log('─'.repeat(120));
        data.forEach((company, index) => {
          console.log(`${index + 1}. ${company.company_name}`);
          console.log(`   ID: ${company.id}`);
          console.log(`   Code: ${company.company_code}`);
          console.log(`   Domain: ${company.domain || 'N/A'}`);
          console.log(`   Industry: ${company.industry || 'N/A'}`);
          console.log(`   Status: ${company.status}`);
          console.log(`   Created: ${new Date(company.created_at).toLocaleDateString()}`);
          console.log('');
        });
      }
    }
  } catch (err) {
    console.log('💥 Exception:', err.message);
  }
})();
