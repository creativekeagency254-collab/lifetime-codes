-- Life Time Technology Store
-- Supabase schema for products and orders used by the storefront/admin app.

create extension if not exists pgcrypto;

create table if not exists public.products (
  id uuid primary key default gen_random_uuid(),
  name text not null,
  slug text not null unique,
  category text not null,
  brand text not null,
  price numeric(12,2) not null check (price >= 0),
  original_price numeric(12,2),
  stock integer not null default 0 check (stock >= 0),
  badge text,
  description text,
  variants jsonb not null default '[]'::jsonb,
  images jsonb not null default '[]'::jsonb,
  specs jsonb not null default '{}'::jsonb,
  sku text,
  tagline text,
  highlights jsonb not null default '[]'::jsonb,
  active boolean not null default true,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create index if not exists idx_products_active on public.products(active);
create index if not exists idx_products_category on public.products(category);
create index if not exists idx_products_created_at on public.products(created_at desc);

create table if not exists public.orders (
  id uuid primary key default gen_random_uuid(),
  order_number text not null unique,
  customer_name text,
  customer_email text not null,
  customer_phone text,
  delivery_area text,
  delivery_address text,
  items jsonb not null default '[]'::jsonb,
  subtotal numeric(12,2) not null default 0,
  delivery_fee numeric(12,2) not null default 0,
  total numeric(12,2) not null default 0,
  currency text not null default 'KES',
  payment_method text not null,
  payment_status text not null default 'pending',
  paystack_ref text,
  order_status text not null default 'confirmed',
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create index if not exists idx_orders_created_at on public.orders(created_at desc);
create index if not exists idx_orders_payment_status on public.orders(payment_status);
create index if not exists idx_orders_order_status on public.orders(order_status);

create or replace function public.set_updated_at()
returns trigger
language plpgsql
as $$
begin
  new.updated_at = now();
  return new;
end;
$$;

drop trigger if exists trg_products_updated_at on public.products;
create trigger trg_products_updated_at
before update on public.products
for each row execute function public.set_updated_at();

drop trigger if exists trg_orders_updated_at on public.orders;
create trigger trg_orders_updated_at
before update on public.orders
for each row execute function public.set_updated_at();

alter table public.products enable row level security;
alter table public.orders enable row level security;

do $$
begin
  if not exists (
    select 1
    from pg_policies
    where schemaname = 'public' and tablename = 'products' and policyname = 'products_public_all'
  ) then
    create policy products_public_all
      on public.products
      for all
      using (true)
      with check (true);
  end if;

  if not exists (
    select 1
    from pg_policies
    where schemaname = 'public' and tablename = 'orders' and policyname = 'orders_public_all'
  ) then
    create policy orders_public_all
      on public.orders
      for all
      using (true)
      with check (true);
  end if;
end
$$;

grant usage on schema public to anon, authenticated;
grant select, insert, update, delete on public.products to anon, authenticated;
grant select, insert, update, delete on public.orders to anon, authenticated;
