# GroupWare セットアップ手順

## 構成
```
GitHub (ソース管理)
  └─ Vercel (ホスティング・自動デプロイ)
        └─ Supabase (DB・認証)
```

---

## 1. Supabase セットアップ

1. https://supabase.com でプロジェクト作成
2. **SQL Editor** で `supabase/schema.sql` を実行
3. **Project Settings > API** から以下を控える
   - `Project URL` → `SUPABASE_URL`
   - `anon public` キー → `SUPABASE_ANON_KEY`
4. **Authentication > URL Configuration** に Vercel の URL を追加
   ```
   https://your-app.vercel.app
   ```

---

## 2. GitHub リポジトリ作成

```bash
cd gw-system
git init
git add .
git commit -m "initial commit"
git branch -M main
git remote add origin https://github.com/YOUR_NAME/gw-system.git
git push -u origin main
```

---

## 3. Vercel デプロイ

1. https://vercel.com で「New Project」
2. GitHub リポジトリを選択してインポート
3. **Environment Variables** に以下を設定
   | 変数名 | 値 |
   |---|---|
   | `SUPABASE_URL` | `https://xxxx.supabase.co` |
   | `SUPABASE_ANON_KEY` | `eyJxxxxxxx...` |
4. Deploy ボタンを押す → 完了

---

## 4. 環境変数を HTML から参照する方法

`vercel.json` の `headers` または Vercel の Edge Config を使って
`window.__ENV` にインジェクトするか、
ビルドステップなしで使う場合は `js/supabase-client.js` に
直接値を書き込んでください（`.gitignore` に注意）。

**推奨（Vercel Rewrites を使う方法）:**
`public/_env.js` を Vercel の「Serverless Function」で動的生成し
HTML で読み込む。または **Vite** などのバンドラーに移行する。

---

## ファイル構成

```
gw-system/
├─ index.html          # 機能メニュー（要ログイン）
├─ login.html          # ログイン画面
├─ vercel.json         # Vercel 設定
├─ .gitignore
├─ .env.example        # 環境変数サンプル
├─ css/
│   └─ common.css      # 共通スタイル
├─ js/
│   ├─ supabase-client.js  # Supabase 初期化
│   └─ auth.js             # 認証ユーティリティ
├─ pages/              # 各機能ページ（今後追加）
└─ supabase/
    └─ schema.sql      # DB スキーマ
```
