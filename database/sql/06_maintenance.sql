-- database/sql/06_maintenance.sql

begin;

-- ==========================================
-- 1. MAINTENANCE REQUESTS
-- ==========================================
create table if not exists public.maintenance_requests (
    id uuid primary key default gen_random_uuid(),
    organization_id uuid not null references public.organizations(id) on delete cascade,
    request_number text not null,
    asset_id uuid not null references public.assets(id) on delete cascade,
    raised_by uuid references public.profiles(id) on delete set null,
    issue_description text not null,
    priority maintenance_priority not null default 'medium',
    status maintenance_status not null default 'pending',
    approved_by uuid references public.profiles(id) on delete set null,
    approved_at timestamptz,
    rejection_reason text,
    technician_id uuid references public.profiles(id) on delete set null,
    estimated_completion_date date,
    started_at timestamptz,
    resolved_at timestamptz,
    resolution_notes text,
    final_asset_status asset_status,
    created_at timestamptz not null default now(),
    updated_at timestamptz not null default now()
);

-- Unique request number per organization
create unique index if not exists idx_maintenance_requests_number_org
on public.maintenance_requests(organization_id, request_number);

drop trigger if exists tr_maintenance_requests_updated_at on public.maintenance_requests;
create trigger tr_maintenance_requests_updated_at
before update on public.maintenance_requests
for each row execute function public.trigger_set_updated_at();

-- ==========================================
-- 2. MAINTENANCE ATTACHMENTS
-- ==========================================
create table if not exists public.maintenance_attachments (
    id uuid primary key default gen_random_uuid(),
    maintenance_request_id uuid not null references public.maintenance_requests(id) on delete cascade,
    file_name text not null,
    storage_path text not null,
    mime_type text not null,
    size_bytes bigint not null,
    uploaded_by uuid references public.profiles(id) on delete set null,
    uploaded_at timestamptz not null default now()
);

-- ==========================================
-- 3. MAINTENANCE STATUS HISTORY
-- ==========================================
create table if not exists public.maintenance_status_history (
    id uuid primary key default gen_random_uuid(),
    maintenance_request_id uuid not null references public.maintenance_requests(id) on delete cascade,
    old_status maintenance_status,
    new_status maintenance_status not null,
    notes text,
    changed_by uuid references public.profiles(id) on delete set null,
    changed_at timestamptz not null default now()
);

-- ==========================================
-- 4. INDEXES
-- ==========================================
create index if not exists idx_maintenance_requests_asset_id on public.maintenance_requests(asset_id);
create index if not exists idx_maintenance_requests_raised_by on public.maintenance_requests(raised_by);
create index if not exists idx_maintenance_requests_technician_id on public.maintenance_requests(technician_id);
create index if not exists idx_maintenance_requests_status on public.maintenance_requests(status);
create index if not exists idx_maintenance_requests_priority on public.maintenance_requests(priority);
create index if not exists idx_maintenance_requests_estimated_completion on public.maintenance_requests(estimated_completion_date);

commit;
