-- Run in Supabase SQL Editor. This stores incoming requests but never exposes them to anonymous readers.
create table if not exists public.preorders (
  id uuid primary key default gen_random_uuid(),
  created_at timestamptz not null default now(),
  customer_name text not null check (char_length(customer_name) between 1 and 100),
  email text not null check (char_length(email) between 3 and 150),
  phone text not null check (char_length(phone) between 1 and 30),
  product_id text not null check (char_length(product_id) between 1 and 100),
  quantity integer not null check (quantity between 1 and 10),
  fulfillment_method text not null check (fulfillment_method in ('Pickup','Delivery')),
  delivery_area text check (char_length(delivery_area) <= 200),
  notes text check (char_length(notes) <= 500),
  status text not null default 'pending' check (status in ('pending','confirmed','cancelled','fulfilled'))
);
alter table public.preorders enable row level security;
revoke all on public.preorders from anon, authenticated;
grant usage on schema public to anon;
grant insert on public.preorders to anon;
drop policy if exists "Public can submit preorders" on public.preorders;
create policy "Public can submit preorders" on public.preorders for insert to anon with check (status = 'pending');
-- No SELECT, UPDATE, or DELETE policies are created for anonymous users.
-- For production, add CAPTCHA, rate limiting, and an Edge Function to validate prices and prevent spam.
