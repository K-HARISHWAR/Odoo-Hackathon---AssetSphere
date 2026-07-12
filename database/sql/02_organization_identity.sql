-- database/sql/02_organization_identity.sql

begin;

-- ==========================================
-- 1. ORGANIZATIONS
-- ==========================================
create table if not exists public.organizations (
    id uuid primary key default gen_random_uuid(),
    name text not null,
    code text not null,
    logo_path text,
    status record_status not null default 'active',
    created_at timestamptz not null default now(),
    updated_at timestamptz not null default now()
);

create unique index if not exists idx_organizations_code_lower 
on public.organizations(lower(code));

drop trigger if exists tr_organizations_updated_at on public.organizations;
create trigger tr_organizations_updated_at
before update on public.organizations
for each row execute function public.trigger_set_updated_at();

-- ==========================================
-- 2. ROLES
-- ==========================================
create table if not exists public.roles (
    id uuid primary key default gen_random_uuid(),
    code text not null unique,
    name text not null,
    description text,
    created_at timestamptz not null default now()
);

-- ==========================================
-- 3. DEPARTMENTS
-- ==========================================
-- Departments has a circular dependency with profiles (department_head_id)
-- We will create departments first without the foreign key to profiles, 
-- or we create profiles first without the foreign key to departments.
-- Given the structure, we create departments first.

create table if not exists public.departments (
    id uuid primary key default gen_random_uuid(),
    organization_id uuid not null references public.organizations(id) on delete cascade,
    name text not null,
    code text not null,
    parent_department_id uuid references public.departments(id) on delete set null,
    department_head_id uuid, -- Will add foreign key later
    status record_status not null default 'active',
    created_at timestamptz not null default now(),
    updated_at timestamptz not null default now()
);

create unique index if not exists idx_departments_code_org_lower 
on public.departments(organization_id, lower(code));

-- Prevent department from being its own parent
alter table public.departments drop constraint if exists chk_department_not_own_parent;
alter table public.departments
add constraint chk_department_not_own_parent 
check (id != parent_department_id);

drop trigger if exists tr_departments_updated_at on public.departments;
create trigger tr_departments_updated_at
before update on public.departments
for each row execute function public.trigger_set_updated_at();

-- ==========================================
-- 4. PROFILES
-- ==========================================
create table if not exists public.profiles (
    id uuid primary key references auth.users(id) on delete cascade,
    organization_id uuid not null references public.organizations(id) on delete cascade,
    employee_code text,
    full_name text not null,
    email text not null,
    phone text,
    avatar_path text,
    department_id uuid references public.departments(id) on delete set null,
    status record_status not null default 'active',
    created_at timestamptz not null default now(),
    updated_at timestamptz not null default now()
);

create unique index if not exists idx_profiles_email_lower 
on public.profiles(lower(email));

create unique index if not exists idx_profiles_employee_code_org 
on public.profiles(organization_id, employee_code) 
where employee_code is not null;

drop trigger if exists tr_profiles_updated_at on public.profiles;
create trigger tr_profiles_updated_at
before update on public.profiles
for each row execute function public.trigger_set_updated_at();

-- Add department_head_id foreign key now that profiles exists
do $$ begin
    alter table public.departments drop constraint if exists fk_departments_department_head;
alter table public.departments
add constraint fk_departments_department_head
    foreign key (department_head_id) references public.profiles(id) on delete set null;
exception when duplicate_object then null; end $$;

-- ==========================================
-- 5. LOCATIONS
-- ==========================================
create table if not exists public.locations (
    id uuid primary key default gen_random_uuid(),
    organization_id uuid not null references public.organizations(id) on delete cascade,
    name text not null,
    code text not null,
    building text,
    floor text,
    room text,
    description text,
    status record_status not null default 'active',
    created_at timestamptz not null default now(),
    updated_at timestamptz not null default now()
);

create unique index if not exists idx_locations_code_org 
on public.locations(organization_id, code);

drop trigger if exists tr_locations_updated_at on public.locations;
create trigger tr_locations_updated_at
before update on public.locations
for each row execute function public.trigger_set_updated_at();

-- ==========================================
-- 6. ASSET CATEGORIES
-- ==========================================
create table if not exists public.asset_categories (
    id uuid primary key default gen_random_uuid(),
    organization_id uuid not null references public.organizations(id) on delete cascade,
    name text not null,
    description text,
    warranty_period_months integer,
    custom_field_description text,
    status record_status not null default 'active',
    created_at timestamptz not null default now(),
    updated_at timestamptz not null default now()
);

create unique index if not exists idx_asset_categories_name_org_lower 
on public.asset_categories(organization_id, lower(name));

alter table public.asset_categories drop constraint if exists chk_asset_categories_warranty;
alter table public.asset_categories
add constraint chk_asset_categories_warranty
check (warranty_period_months is null or warranty_period_months >= 0);

drop trigger if exists tr_asset_categories_updated_at on public.asset_categories;
create trigger tr_asset_categories_updated_at
before update on public.asset_categories
for each row execute function public.trigger_set_updated_at();

-- ==========================================
-- 7. CATEGORY CUSTOM FIELDS
-- ==========================================
create table if not exists public.category_custom_fields (
    id uuid primary key default gen_random_uuid(),
    category_id uuid not null references public.asset_categories(id) on delete cascade,
    field_name text not null,
    field_type text not null,
    is_required boolean not null default false,
    options_json jsonb,
    display_order integer not null default 0,
    created_at timestamptz not null default now(),
    updated_at timestamptz not null default now()
);

alter table public.category_custom_fields drop constraint if exists chk_category_custom_fields_type;
alter table public.category_custom_fields
add constraint chk_category_custom_fields_type
check (field_type in ('text', 'number', 'date', 'boolean', 'select'));

drop trigger if exists tr_category_custom_fields_updated_at on public.category_custom_fields;
create trigger tr_category_custom_fields_updated_at
before update on public.category_custom_fields
for each row execute function public.trigger_set_updated_at();

-- ==========================================
-- 8. USER ROLES
-- ==========================================
create table if not exists public.user_roles (
    id uuid primary key default gen_random_uuid(),
    user_id uuid not null references public.profiles(id) on delete cascade,
    role_id uuid not null references public.roles(id) on delete cascade,
    assigned_by uuid references public.profiles(id) on delete set null,
    assigned_at timestamptz not null default now(),
    updated_at timestamptz not null default now()
);

-- Enforce exactly one role per user
create unique index if not exists idx_user_roles_user_id 
on public.user_roles(user_id);

drop trigger if exists tr_user_roles_updated_at on public.user_roles;
create trigger tr_user_roles_updated_at
before update on public.user_roles
for each row execute function public.trigger_set_updated_at();

commit;
