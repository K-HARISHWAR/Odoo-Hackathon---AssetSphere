-- database/sql/05_resource_bookings.sql

begin;

-- ==========================================
-- 1. RESOURCE BOOKINGS
-- ==========================================
create table if not exists public.resource_bookings (
    id uuid primary key default gen_random_uuid(),
    organization_id uuid not null references public.organizations(id) on delete cascade,
    asset_id uuid not null references public.assets(id) on delete cascade,
    booked_by uuid references public.profiles(id) on delete set null,
    department_id uuid references public.departments(id) on delete set null,
    title text not null,
    purpose text,
    start_time timestamptz not null,
    end_time timestamptz not null,
    status booking_status not null default 'upcoming',
    reminder_sent_at timestamptz,
    cancelled_by uuid references public.profiles(id) on delete set null,
    cancelled_at timestamptz,
    cancellation_reason text,
    created_at timestamptz not null default now(),
    updated_at timestamptz not null default now()
);

-- Rules: start_time < end_time
alter table public.resource_bookings drop constraint if exists chk_resource_bookings_time_order;
alter table public.resource_bookings
add constraint chk_resource_bookings_time_order
check (start_time < end_time);

-- Prevent overlap for the same asset when status is upcoming or ongoing.
-- Uses btree_gist extension for PostgreSQL exclusion constraint.
alter table public.resource_bookings drop constraint if exists ex_resource_bookings_overlap;
alter table public.resource_bookings
add constraint ex_resource_bookings_overlap
exclude using gist (
    asset_id with =,
    tstzrange(start_time, end_time, '[)') with &&
) where (status in ('upcoming', 'ongoing'));

drop trigger if exists tr_resource_bookings_updated_at on public.resource_bookings;
create trigger tr_resource_bookings_updated_at
before update on public.resource_bookings
for each row execute function public.trigger_set_updated_at();

-- ==========================================
-- 2. BOOKING STATUS HISTORY
-- ==========================================
create table if not exists public.booking_status_history (
    id uuid primary key default gen_random_uuid(),
    booking_id uuid not null references public.resource_bookings(id) on delete cascade,
    old_status booking_status,
    new_status booking_status not null,
    reason text,
    changed_by uuid references public.profiles(id) on delete set null,
    changed_at timestamptz not null default now()
);

-- ==========================================
-- 3. INDEXES
-- ==========================================
create index if not exists idx_resource_bookings_asset_id on public.resource_bookings(asset_id);
create index if not exists idx_resource_bookings_booked_by on public.resource_bookings(booked_by);
create index if not exists idx_resource_bookings_start_time on public.resource_bookings(start_time);
create index if not exists idx_resource_bookings_end_time on public.resource_bookings(end_time);
create index if not exists idx_resource_bookings_status on public.resource_bookings(status);
create index if not exists idx_resource_bookings_organization_id on public.resource_bookings(organization_id);

commit;
