-- database/sql/04_allocations_transfers_returns.sql

begin;

-- ==========================================
-- 1. ASSET ALLOCATIONS
-- ==========================================
create table if not exists public.asset_allocations (
    id uuid primary key default gen_random_uuid(),
    organization_id uuid not null references public.organizations(id) on delete cascade,
    asset_id uuid not null references public.assets(id) on delete cascade,
    allocated_to_employee_id uuid references public.profiles(id) on delete set null,
    allocated_to_department_id uuid references public.departments(id) on delete set null,
    allocated_by uuid references public.profiles(id) on delete set null,
    allocated_at timestamptz not null default now(),
    expected_return_date date,
    actual_return_date date,
    checkout_condition asset_condition not null,
    checkin_condition asset_condition,
    checkin_notes text,
    status allocation_status not null default 'active',
    created_at timestamptz not null default now(),
    updated_at timestamptz not null default now()
);

-- Enforce exactly one allocation target
alter table public.asset_allocations drop constraint if exists chk_asset_allocations_target;
alter table public.asset_allocations
add constraint chk_asset_allocations_target
check (num_nonnulls(allocated_to_employee_id, allocated_to_department_id) = 1);

-- Prevent more than one active or overdue allocation for an asset using a partial unique index
create unique index if not exists idx_asset_allocations_active_unique 
on public.asset_allocations(asset_id) 
where status in ('active', 'overdue');

drop trigger if exists tr_asset_allocations_updated_at on public.asset_allocations;
create trigger tr_asset_allocations_updated_at
before update on public.asset_allocations
for each row execute function public.trigger_set_updated_at();

-- ==========================================
-- 2. TRANSFER REQUESTS
-- ==========================================
create table if not exists public.transfer_requests (
    id uuid primary key default gen_random_uuid(),
    organization_id uuid not null references public.organizations(id) on delete cascade,
    asset_id uuid not null references public.assets(id) on delete cascade,
    current_allocation_id uuid not null references public.asset_allocations(id) on delete cascade,
    requested_by uuid references public.profiles(id) on delete set null,
    requested_employee_id uuid references public.profiles(id) on delete set null,
    requested_department_id uuid references public.departments(id) on delete set null,
    reason text not null,
    status request_status not null default 'requested',
    reviewed_by uuid references public.profiles(id) on delete set null,
    reviewed_at timestamptz,
    rejection_reason text,
    created_at timestamptz not null default now(),
    updated_at timestamptz not null default now()
);

-- Require exactly one requested destination
alter table public.transfer_requests drop constraint if exists chk_transfer_requests_target;
alter table public.transfer_requests
add constraint chk_transfer_requests_target
check (num_nonnulls(requested_employee_id, requested_department_id) = 1);

drop trigger if exists tr_transfer_requests_updated_at on public.transfer_requests;
create trigger tr_transfer_requests_updated_at
before update on public.transfer_requests
for each row execute function public.trigger_set_updated_at();

-- ==========================================
-- 3. RETURN REQUESTS
-- ==========================================
create table if not exists public.return_requests (
    id uuid primary key default gen_random_uuid(),
    organization_id uuid not null references public.organizations(id) on delete cascade,
    allocation_id uuid not null references public.asset_allocations(id) on delete cascade,
    requested_by uuid references public.profiles(id) on delete set null,
    requested_at timestamptz not null default now(),
    return_condition asset_condition not null,
    return_notes text,
    status request_status not null default 'requested',
    reviewed_by uuid references public.profiles(id) on delete set null,
    reviewed_at timestamptz,
    rejection_reason text,
    created_at timestamptz not null default now(),
    updated_at timestamptz not null default now()
);

drop trigger if exists tr_return_requests_updated_at on public.return_requests;
create trigger tr_return_requests_updated_at
before update on public.return_requests
for each row execute function public.trigger_set_updated_at();

-- Indexes for status and dates
create index if not exists idx_asset_allocations_status on public.asset_allocations(status);
create index if not exists idx_asset_allocations_expected_return on public.asset_allocations(expected_return_date);
create index if not exists idx_transfer_requests_status on public.transfer_requests(status);
create index if not exists idx_return_requests_status on public.return_requests(status);

commit;
