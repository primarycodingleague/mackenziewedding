-- =============================================================
-- Wedding site database schema + security policies.
-- Run this once in the Supabase SQL Editor (paste + Run).
-- Safe to re-run: uses IF NOT EXISTS / OR REPLACE where possible.
-- =============================================================

-- ---------- Tables ----------

create table if not exists public.settings (
  id   int primary key check (id = 1),
  data jsonb not null default '{}'::jsonb,
  updated_at timestamptz not null default now()
);

create table if not exists public.menu_items (
  id     uuid primary key default gen_random_uuid(),
  course text not null check (course in ('starter', 'main', 'dessert')),
  label  text not null,
  note   text not null default '',
  sort   int  not null default 0,
  active boolean not null default true
);

create table if not exists public.rsvps (
  id            uuid primary key,
  created_at    timestamptz not null default now(),
  contact_name  text not null,
  contact_email text not null,
  contact_phone text not null default '',
  attending     boolean not null,
  party_size    int not null default 1,
  song          text not null default '',
  message       text not null default ''
);

create table if not exists public.rsvp_guests (
  id            uuid primary key default gen_random_uuid(),
  rsvp_id       uuid not null references public.rsvps(id) on delete cascade,
  sort          int not null default 0,
  name          text not null,
  starter       text not null default '',
  main          text not null default '',
  dessert       text not null default '',
  allergens     text not null default '',
  allergy_notes text not null default ''
);

-- Seed the single settings row (guest site supplies defaults for
-- any keys missing from this blob, so empty is fine to start).
insert into public.settings (id, data) values (1, '{}'::jsonb)
on conflict (id) do nothing;

-- Seed the menu only if it is empty.
insert into public.menu_items (course, label, note, sort)
select * from (values
  ('starter', 'Roasted tomato & basil soup', 'vegan, gluten free', 1),
  ('starter', 'Smoked salmon & dill crème fraîche tart', '', 2),
  ('starter', 'Whipped goat''s cheese, beetroot & candied walnuts', 'vegetarian', 3),
  ('main', 'Roast beef, Yorkshire pudding & red wine jus', '', 1),
  ('main', 'Pan-roasted chicken breast, fondant potato & tarragon cream', '', 2),
  ('main', 'Wild mushroom & chestnut wellington', 'vegan', 3),
  ('dessert', 'Sticky toffee pudding & vanilla ice cream', 'vegetarian', 1),
  ('dessert', 'Lemon posset with raspberries & shortbread', 'vegetarian, gluten-free option', 2),
  ('dessert', 'Dark chocolate & salted caramel torte', 'vegan, gluten free', 3)
) as seed(course, label, note, sort)
where not exists (select 1 from public.menu_items);

-- ---------- Row-level security ----------
-- Guests (anon key): may READ site content, and INSERT an RSVP.
-- They can never read, change, or delete anyone's responses.
-- Signed-in users (you two): full access.

alter table public.settings    enable row level security;
alter table public.menu_items  enable row level security;
alter table public.rsvps       enable row level security;
alter table public.rsvp_guests enable row level security;

drop policy if exists "public read settings"  on public.settings;
drop policy if exists "admin write settings"  on public.settings;
drop policy if exists "public read menu"      on public.menu_items;
drop policy if exists "admin write menu"      on public.menu_items;
drop policy if exists "public submit rsvp"    on public.rsvps;
drop policy if exists "admin manage rsvps"    on public.rsvps;
drop policy if exists "admin update rsvps"    on public.rsvps;
drop policy if exists "admin delete rsvps"    on public.rsvps;
drop policy if exists "public submit guests"  on public.rsvp_guests;
drop policy if exists "admin manage guests"   on public.rsvp_guests;
drop policy if exists "admin update guests"   on public.rsvp_guests;
drop policy if exists "admin delete guests"   on public.rsvp_guests;

create policy "public read settings" on public.settings
  for select to anon, authenticated using (true);
create policy "admin write settings" on public.settings
  for update to authenticated using (true) with check (id = 1);

create policy "public read menu" on public.menu_items
  for select to anon, authenticated using (true);
create policy "admin write menu" on public.menu_items
  for all to authenticated using (true) with check (true);

create policy "public submit rsvp" on public.rsvps
  for insert to anon, authenticated with check (true);
create policy "admin manage rsvps" on public.rsvps
  for select to authenticated using (true);
create policy "admin update rsvps" on public.rsvps
  for update to authenticated using (true);
create policy "admin delete rsvps" on public.rsvps
  for delete to authenticated using (true);

create policy "public submit guests" on public.rsvp_guests
  for insert to anon, authenticated with check (true);
create policy "admin manage guests" on public.rsvp_guests
  for select to authenticated using (true);
create policy "admin update guests" on public.rsvp_guests
  for update to authenticated using (true);
create policy "admin delete guests" on public.rsvp_guests
  for delete to authenticated using (true);
