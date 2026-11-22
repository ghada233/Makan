# مكان MAKAN — النسخة الكاملة على Vercel

الملفات:
- `index.html` الموقع
- `api/chat.js` المساعد الذكي (يحفظ مفتاح Claude سرًّا على السيرفر)
- `api/config.js` يعطي الصفحة إعدادات Supabase
- `supabase.sql` قاعدة البيانات وقواعد الحماية و12 مزودًا للبداية

## 1) Supabase (الحسابات وقاعدة البيانات) — مجاني
1. supabase.com ← New project (اختاري منطقة قريبة، مثل Frankfurt).
2. SQL Editor ← New query ← الصقي محتوى `supabase.sql` ← Run.
3. Project Settings ← API: انسخي **Project URL** و **anon public key**.

## 2) مفتاح Claude (للمساعد الذكي) — مدفوع حسب الاستخدام
1. console.anthropic.com ← أضيفي رصيدًا في Billing.
2. API Keys ← Create Key ← انسخيه (يظهر مرة واحدة).

## 3) GitHub + Vercel
1. github.com ← New repository باسم `makan` ← ارفعي الملفات مع مجلد `api` كما هو.
2. vercel.com ← Add New ← Project ← Import `makan`.
3. قبل Deploy افتحي **Environment Variables** وأضيفي:
   - `SUPABASE_URL` = Project URL
   - `SUPABASE_ANON_KEY` = anon public key
   - `ANTHROPIC_API_KEY` = مفتاح Claude
4. Deploy ← يعطيك رابطًا مثل `makan-xxxx.vercel.app`.

## 4) ربط تسجيل الدخول بالرابط
Supabase ← Authentication ← URL Configuration:
- **Site URL** = رابط Vercel
- **Redirect URLs** = رابط Vercel نفسه

## 5) اجعلي نفسك مشرفة
1. افتحي الموقع ← «تسجيل الدخول» ← اكتبي بريدك ← افتحي الرابط من بريدك.
2. Supabase ← SQL Editor ← شغّلي (ببريدك):
   `insert into public.admins (user_id) select id from auth.users where email = 'you@example.com';`
3. حدّثي الصفحة: تظهر «لوحة الإدارة».

## ملاحظات
- أي تعديل ترفعينه على GitHub ينشره Vercel تلقائيًا.
- بريد الدخول المجاني في Supabase محدود بعدد قليل من الرسائل في الساعة؛ للاستخدام الفعلي اربطي SMTP خاصًا من Authentication ← Emails.
- لتغيير نموذج Claude أضيفي متغيرًا `ANTHROPIC_MODEL` (الافتراضي `claude-sonnet-5-5`).
- لا تضعي مفتاح Claude داخل `index.html` أبدًا؛ مكانه متغيرات Vercel فقط.
