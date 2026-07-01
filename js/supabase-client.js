// ============================================================
//  Supabase クライアント初期化
//  .env.local または vercel の環境変数から読み込む
//  SUPABASE_URL / SUPABASE_ANON_KEY を設定してください
// ============================================================

import { createClient } from "https://cdn.jsdelivr.net/npm/@supabase/supabase-js/+esm";

const SUPABASE_URL  = "https://ecrgwubxjicjxjihjpkb.supabase.co";
const SUPABASE_ANON = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImVjcmd3dWJ4amljanhqaWhqcGtiIiwicm9sZSI6ImFub24iLCJpYXQiOjE3ODI3OTk4NTEsImV4cCI6MjA5ODM3NTg1MX0.tUDFsfg32rbgKqaLek8S9jYLvDbbweb9dFXfOUzxNIQ";

export const supabase = createClient(SUPABASE_URL, SUPABASE_ANON);
