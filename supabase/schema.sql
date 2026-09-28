-- Downhill — global leaderboard (Supabase / Postgres)
-- Run this once in the Supabase dashboard: SQL Editor → New query → paste → Run.
--
-- Anyone can read scores and add a score; nobody can edit or delete them (row-level security).
-- The game runs in the browser, so a determined cheater can still post a fake run — the checks
-- below just reject the impossible ones (absurd speeds, more air than run, scores out of all
-- proportion to the time) and throttle floods. There's no minimum time: riding off the road and
-- down the mountain is a legit shortcut, so short runs are real.
--
-- Safe to re-run: everything below is create-if-missing / create-or-replace.

create table if not exists public.scores (
  id         bigint generated always as identity primary key,
  created_at timestamptz not null default now(),
  level      text     not null check (level in ('ridge', 'switch')),
  name       text     not null check (name ~ '^[A-Z]{3}$'),
  time_s     real     not null check (time_s > 0 and time_s < 1200),
  score      integer  not null default 0 check (score >= 0),
  combo      integer  not null default 0 check (combo >= 0),
  air_time   real     not null default 0 check (air_time >= 0),
  top_speed  real     not null default 0 check (top_speed >= 0 and top_speed < 250),
  rider      text              check (rider is null or length(rider) <= 24)
);

create index if not exists scores_level_time  on public.scores (level, time_s);
create index if not exists scores_level_score on public.scores (level, score desc);

-- Plausibility: air time fits inside the run, and points can't pile up faster than tricks allow.
create or replace function public.scores_sanity() returns trigger language plpgsql as $$
declare
  recent integer;
begin
  if new.air_time > new.time_s then raise exception 'air time longer than the run'; end if;
  if new.score > new.time_s * 600 + 5000 then raise exception 'score too high for the time'; end if;
  if new.combo > new.score then raise exception 'combo bigger than the score'; end if;
  if new.name in ('ASS','CUM','FAG','FUC','FUK','FUQ','KKK','NIG','NGR','SEX','SHT','TIT','DIK','DIC','COK','CNT','KYS','NAZ','XXX')
    then raise exception 'pick other initials'; end if;
  -- throttle: at most 30 new scores a minute across everyone
  select count(*) into recent from public.scores where created_at > now() - interval '1 minute';
  if recent >= 30 then raise exception 'too many scores right now, try again in a minute'; end if;
  new.created_at := now();
  return new;
end $$;

drop trigger if exists scores_sanity on public.scores;
create trigger scores_sanity before insert on public.scores
  for each row execute function public.scores_sanity();

alter table public.scores enable row level security;

drop policy if exists "anyone can read scores" on public.scores;
create policy "anyone can read scores" on public.scores
  for select to anon, authenticated using (true);

drop policy if exists "anyone can add a score" on public.scores;
create policy "anyone can add a score" on public.scores
  for insert to anon, authenticated with check (true);

-- no update / delete policies: with RLS on, those are refused for everyone but the dashboard
grant select, insert on public.scores to anon, authenticated;
