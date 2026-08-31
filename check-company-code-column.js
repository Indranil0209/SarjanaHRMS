import { createClient } from '@supabase/supabase-js';

const supabaseUrl = 'https://ykcpdolezschqwcueuil.supabase.co';
const supabaseServiceKey = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InlrY3Bkb2xlenNjaHF3Y3VldWlsIiwicm9sZSI6InNlcnZpY2Vfcm9sZSIsImlhdCI6MTc2MjUxMzk1NiwiZXhwIjoyMDc4MDg5OTU2fQ.ctxa44srFxJsa-TcJ0IZAEDrGa1T6ER72080DQrSG8c';

const supabase = createClient(supabaseUrl, supabaseServiceKey);

(async () => {
  try {
    console.log('🔍 Checking if company_code column exists...\n');

    // Try to query the column
    const { data, error } = await supabase
      .from('companies')
      .select('company_code')
      .limit(1);

    if (error) {
      console.log('❌ ERROR: company_code column does NOT exist!');
      console.log('Error:', error.message);
      console.log('\n📋 You need to run this SQL in Supabase:');
      console.log('─'.repeat(80));
      console.log(`
ALTER TABLE companies ADD COLUMN IF NOT EXISTS company_code VARCHAR(20) UNIQUE;
CREATE INDEX IF NOT EXISTS idx_companies_code ON companies(company_code);
      `.trim());
      console.log('─'.repeat(80));
    } else {
      console.log('✅ company_code column EXISTS!');
      console.log('📊 Sample data:', data);
    }
  } catch (err) {
    console.log('💥 Exception:', err.message);
  }
})();
