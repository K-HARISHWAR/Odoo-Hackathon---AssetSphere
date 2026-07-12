-- database/sql/08_notifications_activity_logs.sql

begin;

-- ==========================================
-- 1. NOTIFICATIONS
-- ==========================================
create table if not exists public.notifications (
    id uuid primary key default gen_random_uuid(),
    organization_id uuid not null references public.organizations(id) on delete cascade,
    user_id uuid not null references public.profiles(id) on delete cascade,
    title text not null,
    message text not null,
    type notification_type not null,
    entity_type text,
    entity_id uuid,
    is_read boolean not null default false,
    created_at timestamptz not null default now(),
    read_at timestamptz
);

-- Indexes for notifications
create index if not exists idx_notifications_org on public.notifications(organization_id);
create index if not exists idx_notifications_user on public.notifications(user_id);
create index if not exists idx_notifications_is_read on public.notifications(is_read);
create index if not exists idx_notifications_created_at on public.notifications(created_at);

-- ==========================================
-- 2. ACTIVITY LOGS
-- ==========================================
create table if not exists public.activity_logs (
    id uuid primary key default gen_random_uuid(),
    organization_id uuid not null references public.organizations(id) on delete cascade,
    actor_id uuid references public.profiles(id) on delete set null,
    action text not null,
    entity_type text not null,
    entity_id uuid not null,
    description text not null,
    old_values jsonb,
    new_values jsonb,
    created_at timestamptz not null default now()
);

-- Indexes for activity logs
create index if not exists idx_activity_logs_org on public.activity_logs(organization_id);
create index if not exists idx_activity_logs_actor on public.activity_logs(actor_id);
create index if not exists idx_activity_logs_entity on public.activity_logs(entity_type, entity_id);
create index if not exists idx_activity_logs_created_at on public.activity_logs(created_at);

commit;
