alter table public.perfis
  add column if not exists cpf text,
  add column if not exists sexo text;

create unique index if not exists perfis_cpf_unique_idx
  on public.perfis (cpf)
  where cpf is not null and cpf <> '';

create or replace function public.criar_perfil()
returns trigger
language plpgsql
security definer
set search_path = public
as $$
begin
  insert into public.perfis (
    id,
    nome,
    email,
    telefone,
    data_nascimento,
    cpf,
    sexo,
    tipo
  )
  values (
    new.id,
    coalesce(new.raw_user_meta_data->>'nome', ''),
    new.email,
    new.raw_user_meta_data->>'telefone',
    nullif(new.raw_user_meta_data->>'data_nascimento', '')::date,
    nullif(new.raw_user_meta_data->>'cpf', ''),
    nullif(new.raw_user_meta_data->>'sexo', ''),
    coalesce(new.raw_user_meta_data->>'tipo', 'paciente')
  )
  on conflict (id) do nothing;
  return new;
end;
$$;

create table if not exists public.favoritos (
  id uuid primary key default gen_random_uuid(),
  paciente_id uuid not null references public.perfis(id) on delete cascade,
  medico_id uuid references public.medicos(id) on delete cascade,
  exame_id uuid references public.exames(id) on delete cascade,
  criado_em timestamptz not null default now(),
  constraint favoritos_um_alvo check (
    (medico_id is not null and exame_id is null)
    or (medico_id is null and exame_id is not null)
  )
);

create unique index if not exists favoritos_medico_unique_idx
  on public.favoritos (paciente_id, medico_id)
  where medico_id is not null;
create unique index if not exists favoritos_exame_unique_idx
  on public.favoritos (paciente_id, exame_id)
  where exame_id is not null;

create table if not exists public.notificacoes (
  id uuid primary key default gen_random_uuid(),
  paciente_id uuid not null references public.perfis(id) on delete cascade,
  titulo text not null,
  mensagem text not null,
  tipo text not null,
  lida boolean not null default false,
  consulta_id uuid references public.consultas(id) on delete set null,
  exame_agendado_id uuid references public.exames_agendados(id) on delete set null,
  criada_em timestamptz not null default now()
);

create index if not exists notificacoes_paciente_data_idx
  on public.notificacoes (paciente_id, criada_em desc);

create table if not exists public.avaliacoes (
  id uuid primary key default gen_random_uuid(),
  consulta_id uuid not null unique references public.consultas(id) on delete cascade,
  paciente_id uuid not null references public.perfis(id) on delete cascade,
  medico_id uuid not null references public.medicos(id) on delete cascade,
  nota smallint not null check (nota between 1 and 5),
  comentario text,
  criada_em timestamptz not null default now()
);

create index if not exists avaliacoes_medico_data_idx
  on public.avaliacoes (medico_id, criada_em desc);

alter table public.favoritos enable row level security;
alter table public.notificacoes enable row level security;
alter table public.avaliacoes enable row level security;

drop policy if exists "ler meus favoritos" on public.favoritos;
create policy "ler meus favoritos" on public.favoritos
  for select using (auth.uid() = paciente_id);
drop policy if exists "criar meus favoritos" on public.favoritos;
create policy "criar meus favoritos" on public.favoritos
  for insert with check (auth.uid() = paciente_id);
drop policy if exists "remover meus favoritos" on public.favoritos;
create policy "remover meus favoritos" on public.favoritos
  for delete using (auth.uid() = paciente_id);

drop policy if exists "ler minhas notificacoes" on public.notificacoes;
create policy "ler minhas notificacoes" on public.notificacoes
  for select using (auth.uid() = paciente_id);
drop policy if exists "marcar minhas notificacoes" on public.notificacoes;
create policy "marcar minhas notificacoes" on public.notificacoes
  for update using (auth.uid() = paciente_id)
  with check (auth.uid() = paciente_id);

drop policy if exists "ler avaliacoes" on public.avaliacoes;
create policy "ler avaliacoes" on public.avaliacoes
  for select using (true);
drop policy if exists "criar avaliacao da propria consulta" on public.avaliacoes;
create policy "criar avaliacao da propria consulta" on public.avaliacoes
  for insert with check (
    auth.uid() = paciente_id
    and exists (
      select 1
      from public.consultas
      where consultas.id = avaliacoes.consulta_id
        and consultas.paciente_id = auth.uid()
        and consultas.medico_id = avaliacoes.medico_id
        and consultas.status = 'agendada'
    )
  );

create or replace function public.notificar_consulta_agendada()
returns trigger
language plpgsql
security definer
set search_path = public
as $$
declare
  v_medico text;
  v_clinica text;
begin
  if old.status is distinct from new.status
     and new.status = 'agendada'
     and new.paciente_id is not null then
    select nome into v_medico from public.medicos where id = new.medico_id;
    select nome into v_clinica from public.clinicas where id = new.clinica_id;
    insert into public.notificacoes (paciente_id, titulo, mensagem, tipo, consulta_id)
    values (
      new.paciente_id,
      'Consulta confirmada',
      format('Consulta com %s em %s.', coalesce(v_medico, 'profissional'), coalesce(v_clinica, 'clínica')),
      'consulta',
      new.id
    );
  end if;
  return new;
end;
$$;

drop trigger if exists consulta_agendada_notificacao on public.consultas;
create trigger consulta_agendada_notificacao
  after update of status on public.consultas
  for each row execute function public.notificar_consulta_agendada();

create or replace function public.notificar_exame_agendado()
returns trigger
language plpgsql
security definer
set search_path = public
as $$
declare
  v_exame text;
begin
  select nome into v_exame from public.exames where id = new.exame_id;
  insert into public.notificacoes (paciente_id, titulo, mensagem, tipo, exame_agendado_id)
  values (
    new.paciente_id,
    'Exame agendado',
    format('O exame %s foi agendado.', coalesce(v_exame, 'selecionado')),
    'exame',
    new.id
  );
  return new;
end;
$$;

drop trigger if exists exame_agendado_notificacao on public.exames_agendados;
create trigger exame_agendado_notificacao
  after insert on public.exames_agendados
  for each row execute function public.notificar_exame_agendado();
