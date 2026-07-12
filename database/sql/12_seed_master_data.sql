-- database/sql/12_seed_master_data.sql

begin;

-- ==========================================
-- 1. SEED ROLES
-- ==========================================
insert into public.roles (code, name, description)
values 
    ('admin', 'Admin', 'System Administrator with full access'),
    ('asset_manager', 'Asset Manager', 'Manages assets and inventory'),
    ('department_head', 'Department Head', 'Manages department assets and staff'),
    ('employee', 'Employee', 'Standard user with basic access'),
    ('auditor', 'Auditor', 'Performs asset audits'),
    ('technician', 'Technician', 'Performs maintenance tasks')
on conflict (code) do nothing;

-- ==========================================
-- 2. SEED ORGANIZATION
-- ==========================================
do $$
declare
    v_org_id uuid;
begin
    -- Check if organization exists, otherwise insert
    select id into v_org_id from public.organizations where code = 'ASSETSPHERE';
    
    if v_org_id is null then
        insert into public.organizations (name, code)
        values ('AssetSphere Demo Organization', 'ASSETSPHERE')
        returning id into v_org_id;
    end if;

    -- ==========================================
    -- 3. SEED DEPARTMENTS
    -- ==========================================
    insert into public.departments (organization_id, name, code)
    values
        (v_org_id, 'Information Technology', 'IT'),
        (v_org_id, 'Human Resources', 'HR'),
        (v_org_id, 'Finance', 'FIN'),
        (v_org_id, 'Operations', 'OPS'),
        (v_org_id, 'Administration', 'ADMIN')
    on conflict (organization_id, lower(code)) do nothing;

    -- ==========================================
    -- 4. SEED LOCATIONS
    -- ==========================================
    insert into public.locations (organization_id, name, code, building, floor)
    values
        (v_org_id, 'Head Office Floor 1', 'HOF1', 'Head Office', '1'),
        (v_org_id, 'Head Office Floor 2', 'HOF2', 'Head Office', '2'),
        (v_org_id, 'Warehouse', 'WH', 'Warehouse Bldg', 'Ground'),
        (v_org_id, 'Branch Office', 'BO', 'Branch Bldg', '1')
    on conflict (organization_id, code) do nothing;

    -- ==========================================
    -- 5. SEED ASSET CATEGORIES
    -- ==========================================
    insert into public.asset_categories (organization_id, name, warranty_period_months)
    values
        (v_org_id, 'Electronics', 24),
        (v_org_id, 'Furniture', 12),
        (v_org_id, 'Vehicles', 36),
        (v_org_id, 'Medical Equipment', 24),
        (v_org_id, 'Office Supplies', null)
    on conflict (organization_id, lower(name)) do nothing;

    -- ==========================================
    -- 6. INITIALIZE ASSET TAG COUNTER
    -- ==========================================
    insert into public.asset_tag_counters (organization_id, current_value)
    values (v_org_id, 0)
    on conflict (organization_id) do nothing;

end $$;

commit;
