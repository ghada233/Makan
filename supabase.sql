-- MAKAN database: paste all of this into Supabase → SQL Editor → Run (once).

-- 1) Tables -------------------------------------------------------------
create table if not exists public.providers (
  id          uuid primary key default gen_random_uuid(),
  name_ar     text default '',
  name_en     text default '',
  cat         text not null default 'adv' check (cat in ('legal','eng','val','adv','pm')),
  city        text not null default 'riyadh' check (city in ('riyadh','jeddah','dammam','makkah','madinah')),
  langs       text default '',
  resp        text default 'd2' check (resp in ('d1','d2','d3')),
  svc_ar      text[] default '{}',
  svc_en      text[] default '{}',
  verified    boolean not null default false,
  created_at  timestamptz not null default now()
);

create table if not exists public.applications (
  user_id     uuid primary key references auth.users(id) on delete cascade,
  name_ar     text default '',
  name_en     text default '',
  cat         text default 'adv',
  city        text default 'riyadh',
  langs       text default '',
  resp        text default 'd2',
  svc_ar      text[] default '{}',
  svc_en      text[] default '{}',
  contact     text default '',
  status      text not null default 'pending' check (status in ('pending','approved','rejected')),
  created_at  timestamptz not null default now()
);

create table if not exists public.passports (
  user_id     uuid primary key references auth.users(id) on delete cascade,
  pp          jsonb,
  tasks       jsonb,
  updated_at  timestamptz default now()
);

create table if not exists public.admins (
  user_id     uuid primary key references auth.users(id) on delete cascade
);

-- 2) Who is an admin ----------------------------------------------------
create or replace function public.is_admin() returns boolean
language sql stable security definer set search_path = public as $$
  select exists (select 1 from public.admins where user_id = auth.uid());
$$;

-- 3) Security rules (row-level security) ---------------------------------
alter table public.providers    enable row level security;
alter table public.applications enable row level security;
alter table public.passports    enable row level security;
alter table public.admins       enable row level security;

-- providers: everyone reads, only admins change
drop policy if exists providers_read  on public.providers;
drop policy if exists providers_admin on public.providers;
create policy providers_read  on public.providers for select using (true);
create policy providers_admin on public.providers for all to authenticated using (public.is_admin()) with check (public.is_admin());

-- applications: each user writes their own (as pending); admins read and decide
drop policy if exists apps_read        on public.applications;
drop policy if exists apps_insert_own  on public.applications;
drop policy if exists apps_update_own  on public.applications;
drop policy if exists apps_admin       on public.applications;
create policy apps_read       on public.applications for select to authenticated using (user_id = auth.uid() or public.is_admin());
create policy apps_insert_own on public.applications for insert to authenticated with check (user_id = auth.uid() and status = 'pending');
create policy apps_update_own on public.applications for update to authenticated using (user_id = auth.uid()) with check (user_id = auth.uid() and status = 'pending');
create policy apps_admin      on public.applications for all to authenticated using (public.is_admin()) with check (public.is_admin());

-- passports: private to their owner
drop policy if exists passports_own on public.passports;
create policy passports_own on public.passports for all to authenticated using (user_id = auth.uid()) with check (user_id = auth.uid());

-- admins: a user can only see whether they themselves are an admin
drop policy if exists admins_self on public.admins;
create policy admins_self on public.admins for select to authenticated using (user_id = auth.uid());

-- 4) Starting providers (sample profiles; edit or delete them from the admin panel)
insert into public.providers (name_ar,name_en,cat,city,langs,resp,svc_ar,svc_en) values
('دار الميثاق للمحاماة','Al Mithaq Law','legal','riyadh','العربية, English','d1',array['الفحص القانوني للعقار','هيكلة تملك غير السعوديين','صياغة عقود البيع والإيجار'],array['Property due diligence','Non-Saudi ownership structuring','Sale and lease contracts']),
('مكتب السدرة القانوني','Al Sidra Legal','legal','jeddah','العربية, English, Français','d2',array['مراجعة العقود التجارية','تسوية النزاعات العقارية'],array['Commercial contract review','Real estate dispute resolution']),
('بيت المشورة للمحاماة','Bayt Al Mashura Law','legal','dammam','العربية, English','d1',array['الفحص القانوني','عقود التطوير والمقاولات'],array['Legal due diligence','Development and construction contracts']),
('مجموعة الركائز الهندسية','Al Rakaez Engineering','eng','riyadh','العربية, English','d3',array['الفحص الفني للمباني','مراجعة التصاميم','الإشراف على التنفيذ'],array['Building inspection','Design review','Construction supervision']),
('المعمار للاستشارات الهندسية','Al Meamar Engineering Consultants','eng','jeddah','العربية, English, اردو','d2',array['تقارير الحالة الإنشائية','التصاريح والاشتراطات'],array['Structural condition reports','Permits and requirements']),
('أفق للتقييم العقاري','Ufuq Valuation','val','riyadh','العربية, English','d1',array['تقييم الأصول التجارية','تقييم المحافظ'],array['Commercial asset valuation','Portfolio valuation']),
('قيمة للتقييم','Qeema Valuation','val','dammam','العربية','d2',array['تقييم سكني وتجاري','تقييم الأراضي'],array['Residential and commercial valuation','Land valuation']),
('مسار للاستشارات الاستثمارية','Masar Investment Advisory','adv','riyadh','العربية, English, 中文','d1',array['دراسات الجدوى','تحليل السوق','هيكلة الصفقات'],array['Feasibility studies','Market analysis','Deal structuring']),
('بوابة الحرمين للاستشارات','Haramain Gate Advisory','adv','makkah','العربية, English, Bahasa','d3',array['فرص الضيافة والفنادق','دراسات الطلب الموسمي'],array['Hospitality opportunities','Seasonal demand studies']),
('نخيل لإدارة الأملاك','Nakheel Property Management','pm','madinah','العربية, English','d1',array['إدارة التأجير والتحصيل','الصيانة الدورية'],array['Leasing and collection','Routine maintenance']),
('مدار لإدارة الأملاك','Madar Property Management','pm','jeddah','العربية, English','d2',array['إدارة المجمعات التجارية','تقارير الأداء الشهرية'],array['Retail centre management','Monthly performance reports']),
('طيبة للتقييم العقاري','Taibah Valuation','val','madinah','العربية, English','d2',array['تقييم أصول الضيافة','تقييم الأراضي'],array['Hospitality asset valuation','Land valuation']);

-- 5) Make yourself an admin: sign in on the site once, then run this line
--    with your own email (remove the two dashes first):
-- insert into public.admins (user_id) select id from auth.users where email = 'you@example.com';
