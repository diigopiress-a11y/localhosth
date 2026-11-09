-- Execute no SQL Editor do Supabase. Não habilite SELECT público.
create extension if not exists pgcrypto;
create table if not exists public.admin_users (
  user_id uuid primary key references auth.users(id) on delete cascade,
  created_at timestamptz not null default now()
);
create table if not exists public.visits (
  id uuid primary key default gen_random_uuid(),
  visitor_id uuid not null,
  created_at timestamptz not null default now(),
  campaign text not null default 'direto' check (char_length(campaign) <= 120),
  location_consent boolean not null default false,
  latitude double precision,
  longitude double precision,
  phone text,
  marketing_consent boolean not null default false,
  analytics_consent boolean not null default false,
  user_agent text,
  constraint location_requires_consent check (
    (location_consent and latitude between -90 and 90 and longitude between -180 and 180)
    or (not location_consent and latitude is null and longitude is null)
  ),
  constraint phone_requires_marketing_consent check (
    (marketing_consent and phone is not null and char_length(phone) between 10 and 13)
    or (not marketing_consent and phone is null)
  )
);
create index if not exists visits_created_at_idx on public.visits(created_at desc);
create index if not exists visits_campaign_idx on public.visits(campaign);
alter table public.visits enable row level security;
alter table public.admin_users enable row level security;
revoke all on public.visits from anon, authenticated;
grant insert on public.visits to anon, authenticated;
grant select on public.visits to authenticated;
revoke all on public.admin_users from anon, authenticated;
grant select on public.admin_users to authenticated;
drop policy if exists "public can submit consented visit" on public.visits;
create policy "public can submit consented visit" on public.visits
for insert to anon, authenticated
with check (
  (not location_consent and latitude is null and longitude is null)
  or (location_consent and latitude between -90 and 90 and longitude between -180 and 180)
);
drop policy if exists "admins can read visits" on public.visits;
create policy "admins can read visits" on public.visits
for select to authenticated
using (exists (select 1 from public.admin_users a where a.user_id = auth.uid()));
drop policy if exists "admins can read own admin row" on public.admin_users;
create policy "admins can read own admin row" on public.admin_users
for select to authenticated
using (user_id = auth.uid());
-- Depois de criar seu usuário em Authentication > Users, execute:
-- insert into public.admin_users(user_id) values ('UUID_DO_SEU_USUARIO');
