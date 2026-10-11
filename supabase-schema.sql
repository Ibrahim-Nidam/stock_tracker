-- Run this once in the Supabase SQL editor for the Stocktrack project.
-- This schema keeps each Stocktrack data set in its own editable table.
-- The browser app uses the publishable key, so these policies intentionally
-- allow the app to read and write its own records without a login.

drop table if exists public.stocktrack_records;

create table if not exists public.parts (
  pn text primary key,
  name text not null,
  type text not null,
  min integer
);

create table if not exists public.storages (
  name text primary key
);

create table if not exists public.stock (
  pn text not null,
  storage text not null,
  qty integer not null default 0,
  primary key (pn, storage)
);

create table if not exists public.serials (
  sn text primary key,
  pn text not null,
  storage text,
  status text,
  machine text,
  "order" text,
  date text,
  note text,
  doa boolean not null default false,
  rma boolean not null default false,
  used_date text
);

create table if not exists public.incoming (
  id bigint primary key,
  pn text not null,
  storage text,
  "order" text,
  qty integer,
  sn text,
  status text,
  date text,
  note text
);

create table if not exists public.rma (
  id bigint primary key,
  pn text,
  "order" text,
  old text,
  "new" text,
  machine text,
  status text,
  date text,
  ts bigint,
  new_created boolean not null default false,
  wo text,
  note text
);

create table if not exists public.history (
  id bigint primary key,
  pn text,
  name text,
  sn text,
  action text,
  detail text,
  machine text,
  storage text,
  "order" text,
  date text,
  ts bigint
);

create table if not exists public.machines (
  name text primary key,
  "group" text
);

create table if not exists public.machine_groups (
  name text primary key
);

create table if not exists public.workorders (
  wo text primary key,
  machine text,
  type text,
  status text,
  po text,
  opened text,
  closed text,
  note text,
  src text
);

create table if not exists public.wo_lines (
  id bigint primary key,
  wo text not null,
  pn text not null,
  name text,
  qty integer,
  status text,
  sn text,
  note text,
  src text
);

alter table public.parts enable row level security;
alter table public.storages enable row level security;
alter table public.stock enable row level security;
alter table public.serials enable row level security;
alter table public.incoming enable row level security;
alter table public.rma enable row level security;
alter table public.history enable row level security;
alter table public.machines enable row level security;
alter table public.machine_groups enable row level security;
alter table public.workorders enable row level security;
alter table public.wo_lines enable row level security;

-- Re-running this file is safe: each policy is replaced.
do $$
declare
  table_name text;
begin
  foreach table_name in array array[
    'parts','storages','stock','serials','incoming','rma','history',
    'machines','machine_groups','workorders','wo_lines'
  ] loop
    execute format('drop policy if exists "stocktrack public access" on public.%I', table_name);
    execute format(
      'create policy "stocktrack public access" on public.%I for all using (true) with check (true)',
      table_name
    );
  end loop;
end $$;
