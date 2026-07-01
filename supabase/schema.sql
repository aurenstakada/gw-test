-- ============================================================
--  GroupWare - Supabase スキーマ定義
--  Supabase ダッシュボード > SQL Editor で実行してください
-- ============================================================

-- ユーザープロフィール（auth.users の拡張）
CREATE TABLE IF NOT EXISTS profiles (
  id          UUID PRIMARY KEY REFERENCES auth.users(id) ON DELETE CASCADE,
  full_name   TEXT,
  department  TEXT,
  position    TEXT,
  phone       TEXT,
  avatar_url  TEXT,
  created_at  TIMESTAMPTZ DEFAULT NOW(),
  updated_at  TIMESTAMPTZ DEFAULT NOW()
);

-- ユーザー登録時に自動でプロフィールを作成するトリガー
CREATE OR REPLACE FUNCTION public.handle_new_user()
RETURNS TRIGGER AS $$
BEGIN
  INSERT INTO public.profiles (id, full_name)
  VALUES (NEW.id, NEW.raw_user_meta_data->>'full_name');
  RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

DROP TRIGGER IF EXISTS on_auth_user_created ON auth.users;
CREATE TRIGGER on_auth_user_created
  AFTER INSERT ON auth.users
  FOR EACH ROW EXECUTE FUNCTION public.handle_new_user();

-- 未読件数テーブル
CREATE TABLE IF NOT EXISTS unread_counts (
  id         BIGSERIAL PRIMARY KEY,
  user_id    UUID REFERENCES auth.users(id) ON DELETE CASCADE,
  feature    TEXT NOT NULL,  -- message / board / workflow / mail / phone / schedule
  count      INT  NOT NULL DEFAULT 0,
  updated_at TIMESTAMPTZ DEFAULT NOW(),
  UNIQUE (user_id, feature)
);

-- 掲示板
CREATE TABLE IF NOT EXISTS board_posts (
  id          BIGSERIAL PRIMARY KEY,
  title       TEXT NOT NULL,
  body        TEXT NOT NULL,
  author_id   UUID REFERENCES auth.users(id),
  category    TEXT DEFAULT 'general',
  is_pinned   BOOLEAN DEFAULT FALSE,
  created_at  TIMESTAMPTZ DEFAULT NOW(),
  updated_at  TIMESTAMPTZ DEFAULT NOW()
);

-- スケジュール
CREATE TABLE IF NOT EXISTS schedules (
  id          BIGSERIAL PRIMARY KEY,
  title       TEXT NOT NULL,
  body        TEXT,
  owner_id    UUID REFERENCES auth.users(id),
  start_at    TIMESTAMPTZ NOT NULL,
  end_at      TIMESTAMPTZ NOT NULL,
  all_day     BOOLEAN DEFAULT FALSE,
  location    TEXT,
  color       TEXT DEFAULT '#1a73e8',
  created_at  TIMESTAMPTZ DEFAULT NOW()
);

-- メッセージ（チャット）
CREATE TABLE IF NOT EXISTS messages (
  id          BIGSERIAL PRIMARY KEY,
  room_id     UUID NOT NULL,
  sender_id   UUID REFERENCES auth.users(id),
  body        TEXT NOT NULL,
  is_read     BOOLEAN DEFAULT FALSE,
  created_at  TIMESTAMPTZ DEFAULT NOW()
);

-- ============================================================
--  Row Level Security (RLS) の有効化
-- ============================================================

ALTER TABLE profiles      ENABLE ROW LEVEL SECURITY;
ALTER TABLE unread_counts ENABLE ROW LEVEL SECURITY;
ALTER TABLE board_posts   ENABLE ROW LEVEL SECURITY;
ALTER TABLE schedules     ENABLE ROW LEVEL SECURITY;
ALTER TABLE messages      ENABLE ROW LEVEL SECURITY;

-- profiles: 自分のみ更新可、全員参照可
CREATE POLICY "profiles_select" ON profiles FOR SELECT USING (TRUE);
CREATE POLICY "profiles_update" ON profiles FOR UPDATE USING (auth.uid() = id);

-- unread_counts: 自分のみ
CREATE POLICY "unread_own" ON unread_counts
  USING (auth.uid() = user_id);

-- board_posts: 全員参照、ログイン済みが投稿
CREATE POLICY "board_select" ON board_posts FOR SELECT USING (TRUE);
CREATE POLICY "board_insert" ON board_posts FOR INSERT WITH CHECK (auth.uid() = author_id);
CREATE POLICY "board_update" ON board_posts FOR UPDATE USING (auth.uid() = author_id);
CREATE POLICY "board_delete" ON board_posts FOR DELETE USING (auth.uid() = author_id);

-- schedules: 自分のみ
CREATE POLICY "sched_own" ON schedules
  USING (auth.uid() = owner_id);
CREATE POLICY "sched_insert" ON schedules FOR INSERT WITH CHECK (auth.uid() = owner_id);

-- messages: ルーム参加者のみ（簡易版: ログイン済み全員）
CREATE POLICY "msg_select" ON messages FOR SELECT USING (auth.uid() IS NOT NULL);
CREATE POLICY "msg_insert" ON messages FOR INSERT WITH CHECK (auth.uid() = sender_id);
