-- database/sql/07_audits.sql

begin;

-- ==========================================
-- 1. AUDIT CYCLES
-- ==========================================
create table if not exists public.audit_cycles (
    id uuid primary key default gen_random_uuid(),
    organization_id uuid not null references public.organizations(id) on delete cascade,
    name text not null,
    department_id uuid references public.departments(id) on delete set null,
    location_id uuid references public.locations(id) on delete set null,
    start_date date not null,
    end_date date not null,
    status audit_cycle_status not null default 'draft',
    created_by uuid references public.profiles(id) on delete set null,
    closed_by uuid references public.profiles(id) on delete set null,
    closed_at timestamptz,
    created_at timestamptz not null default now(),
    updated_at timestamptz not null default now()
);

-- Rules: start_date <= end_date
alter table public.audit_cycles drop constraint if exists chk_audit_cycles_dates;
alter table public.audit_cycles
add constraint chk_audit_cycles_dates
check (start_date <= end_date);

drop trigger if exists tr_audit_cycles_updated_at on public.audit_cycles;
create trigger tr_audit_cycles_updated_at
before update on public.audit_cycles
for each row execute function public.trigger_set_updated_at();

-- ==========================================
-- 2. AUDIT CYCLE AUDITORS
-- ==========================================
create table if not exists public.audit_cycle_auditors (
    id uuid primary key default gen_random_uuid(),
    audit_cycle_id uuid not null references public.audit_cycles(id) on delete cascade,
    auditor_id uuid not null references public.profiles(id) on delete cascade,
    assigned_by uuid references public.profiles(id) on delete set null,
    assigned_at timestamptz not null default now()
);

-- Unique audit_cycle_id + auditor_id
create unique index if not exists idx_audit_cycle_auditors_unique
on public.audit_cycle_auditors(audit_cycle_id, auditor_id);

-- ==========================================
-- 3. AUDIT ITEMS
-- ==========================================
create table if not exists public.audit_items (
    id uuid primary key default gen_random_uuid(),
    audit_cycle_id uuid not null references public.audit_cycles(id) on delete cascade,
    asset_id uuid not null references public.assets(id) on delete cascade,
    assigned_auditor_id uuid references public.profiles(id) on delete set null,
    verification_status audit_verification_status not null default 'pending',
    expected_location_id uuid references public.locations(id) on delete set null,
    actual_location_id uuid references public.locations(id) on delete set null,
    expected_condition asset_condition not null,
    observed_condition asset_condition,
    notes text,
    evidence_path text,
    verified_at timestamptz,
    created_at timestamptz not null default now(),
    updated_at timestamptz not null default now()
);

-- Unique audit_cycle_id + asset_id
create unique index if not exists idx_audit_items_unique
on public.audit_items(audit_cycle_id, asset_id);

drop trigger if exists tr_audit_items_updated_at on public.audit_items;
create trigger tr_audit_items_updated_at
before update on public.audit_items
for each row execute function public.trigger_set_updated_at();

-- ==========================================
-- 4. AUDIT DISCREPANCIES
-- ==========================================
create table if not exists public.audit_discrepancies (
    id uuid primary key default gen_random_uuid(),
    audit_item_id uuid not null references public.audit_items(id) on delete cascade,
    discrepancy_type text not null,
    description text not null,
    status discrepancy_status not null default 'open',
    resolved_by uuid references public.profiles(id) on delete set null,
    resolved_at timestamptz,
    resolution_notes text,
    created_at timestamptz not null default now(),
    updated_at timestamptz not null default now()
);

drop trigger if exists tr_audit_discrepancies_updated_at on public.audit_discrepancies;
create trigger tr_audit_discrepancies_updated_at
before update on public.audit_discrepancies
for each row execute function public.trigger_set_updated_at();

-- ==========================================
-- 5. INDEXES
-- ==========================================
create index if not exists idx_audit_cycles_org_status on public.audit_cycles(organization_id, status);
create index if not exists idx_audit_cycles_dates on public.audit_cycles(start_date, end_date);
create index if not exists idx_audit_items_auditor on public.audit_items(assigned_auditor_id);
create index if not exists idx_audit_items_status on public.audit_items(verification_status);
create index if not exists idx_audit_discrepancies_status on public.audit_discrepancies(status);

commit;
