-- database/sql/03_assets.sql

begin;

-- ==========================================
-- 1. ASSET TAG COUNTERS
-- ==========================================
create table if not exists public.asset_tag_counters (
    organization_id uuid primary key references public.organizations(id) on delete cascade,
    current_value integer not null default 0,
    updated_at timestamptz not null default now()
);

drop trigger if exists tr_asset_tag_counters_updated_at on public.asset_tag_counters;
create trigger tr_asset_tag_counters_updated_at
before update on public.asset_tag_counters
for each row execute function public.trigger_set_updated_at();

-- ==========================================
-- 2. ASSETS
-- ==========================================
create table if not exists public.assets (
    id uuid primary key default gen_random_uuid(),
    organization_id uuid not null references public.organizations(id) on delete cascade,
    asset_tag text not null,
    name text not null,
    category_id uuid not null references public.asset_categories(id) on delete restrict,
    serial_number text,
    acquisition_date date,
    acquisition_cost numeric(14,2),
    condition asset_condition not null,
    location_id uuid references public.locations(id) on delete set null,
    department_id uuid references public.departments(id) on delete set null,
    status asset_status not null default 'available',
    is_shared boolean not null default false,
    is_bookable boolean not null default false,
    photo_path text,
    warranty_expiry_date date,
    retirement_date date,
    notes text,
    created_by uuid references public.profiles(id) on delete set null,
    created_at timestamptz not null default now(),
    updated_at timestamptz not null default now()
);

-- asset_tag unique per organization
create unique index if not exists idx_assets_asset_tag_org 
on public.assets(organization_id, asset_tag);

-- serial number unique per organization when present
create unique index if not exists idx_assets_serial_number_org 
on public.assets(organization_id, serial_number) 
where serial_number is not null;

-- acquisition cost null or >= 0
alter table public.assets drop constraint if exists chk_assets_acquisition_cost;
alter table public.assets
add constraint chk_assets_acquisition_cost
check (acquisition_cost is null or acquisition_cost >= 0);

-- bookable implies shared
alter table public.assets drop constraint if exists chk_assets_bookable_shared;
alter table public.assets
add constraint chk_assets_bookable_shared
check (not is_bookable or is_shared);

-- retired and disposed assets cannot be bookable
alter table public.assets drop constraint if exists chk_assets_retired_disposed_bookable;
alter table public.assets
add constraint chk_assets_retired_disposed_bookable
check (not (is_bookable and status in ('retired', 'disposed')));

drop trigger if exists tr_assets_updated_at on public.assets;
create trigger tr_assets_updated_at
before update on public.assets
for each row execute function public.trigger_set_updated_at();

-- Search indexes
create index if not exists idx_assets_organization_id on public.assets(organization_id);
create index if not exists idx_assets_category_id on public.assets(category_id);
create index if not exists idx_assets_status on public.assets(status);
create index if not exists idx_assets_department_id on public.assets(department_id);
create index if not exists idx_assets_location_id on public.assets(location_id);
create index if not exists idx_assets_name on public.assets using gin (name extensions.gin_trgm_ops) where name is not null;

-- ==========================================
-- 3. ASSET CUSTOM FIELD VALUES
-- ==========================================
create table if not exists public.asset_custom_field_values (
    id uuid primary key default gen_random_uuid(),
    asset_id uuid not null references public.assets(id) on delete cascade,
    custom_field_id uuid not null references public.category_custom_fields(id) on delete cascade,
    value_json jsonb not null,
    created_at timestamptz not null default now(),
    updated_at timestamptz not null default now()
);

-- Unique per asset and custom field
create unique index if not exists idx_asset_custom_field_values_unique 
on public.asset_custom_field_values(asset_id, custom_field_id);

drop trigger if exists tr_asset_custom_field_values_updated_at on public.asset_custom_field_values;
create trigger tr_asset_custom_field_values_updated_at
before update on public.asset_custom_field_values
for each row execute function public.trigger_set_updated_at();

-- ==========================================
-- 4. ASSET DOCUMENTS
-- ==========================================
create table if not exists public.asset_documents (
    id uuid primary key default gen_random_uuid(),
    asset_id uuid not null references public.assets(id) on delete cascade,
    file_name text not null,
    storage_path text not null,
    mime_type text not null,
    size_bytes bigint not null,
    uploaded_by uuid references public.profiles(id) on delete set null,
    uploaded_at timestamptz not null default now()
);

-- ==========================================
-- 5. ASSET STATUS HISTORY
-- ==========================================
create table if not exists public.asset_status_history (
    id uuid primary key default gen_random_uuid(),
    asset_id uuid not null references public.assets(id) on delete cascade,
    old_status asset_status,
    new_status asset_status not null,
    reason text,
    changed_by uuid references public.profiles(id) on delete set null,
    changed_at timestamptz not null default now()
);

-- ==========================================
-- 6. ASSET CONDITION HISTORY
-- ==========================================
create table if not exists public.asset_condition_history (
    id uuid primary key default gen_random_uuid(),
    asset_id uuid not null references public.assets(id) on delete cascade,
    old_condition asset_condition,
    new_condition asset_condition not null,
    notes text,
    recorded_by uuid references public.profiles(id) on delete set null,
    recorded_at timestamptz not null default now()
);

commit;
