import { Buffer } from 'node:buffer';

async function testSupabaseFunction() {
  try {
    const response = await fetch("https://ykcpdolezschqwcueuil.supabase.co/functions/v1/send-email", {
      method: "POST",
      headers: {
        "Authorization": "Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InlrY3Bkb2xlenNjaHF3Y3VldWlsIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NjI1MTM5NTYsImV4cCI6MjA3ODA4OTk1Nn0.TTu20eDWZRUrgX8AF4KcGsuhoAkL6jwZ-kTo1VjIooM",
        "Content-Type": "application/json"
      },
      body: JSON.stringify({
        to: "sarjanahrtech@gmail.com",
        subject: "Test Invocation",
        html: "<p>Test</p>"
      })
    });
    
    const status = response.status;
    const text = await response.text();
    console.log("Status:", status);
    console.log("Response:", text);
  } catch (error) {
    console.error("Error:", error);
  }
}

testSupabaseFunction();
