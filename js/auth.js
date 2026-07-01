// ============================================================
//  認証ユーティリティ
// ============================================================
import { supabase } from "./supabase-client.js";

/** セッション取得。未ログインなら login.html へ飛ばす */
export async function requireAuth() {
  const { data: { session } } = await supabase.auth.getSession();
  if (!session) {
    location.href = "/login.html";
    return null;
  }
  return session;
}

/** ログアウト */
export async function signOut() {
  await supabase.auth.signOut();
  location.href = "/login.html";
}

/** ヘッダーにユーザー名を表示 */
export function renderUserInfo(session, selector = "#user-name") {
  const el = document.querySelector(selector);
  if (el && session?.user) {
    const meta = session.user.user_metadata;
    el.textContent = meta?.full_name || session.user.email;
  }
}
