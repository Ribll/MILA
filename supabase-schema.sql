-- ============================================================
--  MILA · Schema del database (Supabase / PostgreSQL)
--  Copia TUTTO e incollalo in Supabase → SQL Editor → Run.
--  È sicuro rieseguirlo: non cancella dati già presenti.
-- ============================================================

-- Impostazioni della famiglia (una riga per famiglia)
create table if not exists public.settings (
  family_id     text primary key,
  child         text    default 'Mila',
  p1            text    default 'Mamma',
  p2            text    default 'Papà',
  default_inps  numeric default 0,
  overrides     jsonb   default '{}'::jsonb,
  updated_at    timestamptz default now()
);

-- Spese
create table if not exists public.expenses (
  id           uuid primary key default gen_random_uuid(),
  family_id    text not null,
  amount       numeric not null,
  description  text,
  category     text,
  paid_by      text,               -- 'p1' | 'p2' : chi ha anticipato
  split        text default 'half',-- 'half' | 'p1' | 'p2' : come si divide
  spent_on     date not null,
  created_at   timestamptz default now()
);
-- se la tabella esisteva già senza la colonna split, la aggiunge
alter table public.expenses add column if not exists split text default 'half';
create index if not exists expenses_family_idx on public.expenses (family_id, spent_on);

-- Saldi/pareggi tra i due genitori
create table if not exists public.settlements (
  id          uuid primary key default gen_random_uuid(),
  family_id   text not null,
  payer       text not null,       -- 'p1' | 'p2' : chi paga per pareggiare
  amount      numeric not null,
  spent_on    date not null default current_date,
  created_at  timestamptz default now()
);
create index if not exists settlements_family_idx on public.settlements (family_id, created_at);

-- ---- Sicurezza (Row Level Security) -------------------------
alter table public.settings   enable row level security;
alter table public.expenses   enable row level security;
alter table public.settlements enable row level security;

create or replace function public.current_family()
returns text language sql stable as $$
  select coalesce(auth.jwt() -> 'user_metadata' ->> 'family_id', '')
$$;

-- SETTINGS
drop policy if exists settings_select on public.settings;
drop policy if exists settings_insert on public.settings;
drop policy if exists settings_update on public.settings;
create policy settings_select on public.settings for select using (family_id = public.current_family());
create policy settings_insert on public.settings for insert with check (family_id = public.current_family());
create policy settings_update on public.settings for update using (family_id = public.current_family()) with check (family_id = public.current_family());

-- EXPENSES
drop policy if exists expenses_select on public.expenses;
drop policy if exists expenses_insert on public.expenses;
drop policy if exists expenses_update on public.expenses;
drop policy if exists expenses_delete on public.expenses;
create policy expenses_select on public.expenses for select using (family_id = public.current_family());
create policy expenses_insert on public.expenses for insert with check (family_id = public.current_family());
create policy expenses_update on public.expenses for update using (family_id = public.current_family()) with check (family_id = public.current_family());
create policy expenses_delete on public.expenses for delete using (family_id = public.current_family());

-- SETTLEMENTS
drop policy if exists settlements_select on public.settlements;
drop policy if exists settlements_insert on public.settlements;
drop policy if exists settlements_delete on public.settlements;
create policy settlements_select on public.settlements for select using (family_id = public.current_family());
create policy settlements_insert on public.settlements for insert with check (family_id = public.current_family());
create policy settlements_delete on public.settlements for delete using (family_id = public.current_family());

-- ---- Sincronizzazione in tempo reale (idempotente) ----------
do $$
begin
  if not exists (select 1 from pg_publication_tables where pubname='supabase_realtime' and schemaname='public' and tablename='expenses') then
    alter publication supabase_realtime add table public.expenses; end if;
  if not exists (select 1 from pg_publication_tables where pubname='supabase_realtime' and schemaname='public' and tablename='settings') then
    alter publication supabase_realtime add table public.settings; end if;
  if not exists (select 1 from pg_publication_tables where pubname='supabase_realtime' and schemaname='public' and tablename='settlements') then
    alter publication supabase_realtime add table public.settlements; end if;
end $$;

-- Fatto! 🎉
