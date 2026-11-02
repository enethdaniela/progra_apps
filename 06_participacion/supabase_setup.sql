create table if not exists public.perfiles (
  id uuid primary key references auth.users (id) on delete cascade,
  nombre text not null,
  creado_en timestamptz not null default now()
);

alter table public.perfiles enable row level security;

create policy "usuarios autenticados pueden leer perfiles"
on public.perfiles
for select
to authenticated
using (true);

create policy "cada usuario inserta solo su perfil"
on public.perfiles
for insert
to authenticated
with check (auth.uid() = id);
