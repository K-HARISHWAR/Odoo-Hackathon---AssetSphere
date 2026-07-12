-- database/sql/09_functions_and_auth_triggers.sql

begin;

-- ==========================================
-- 1. PRIVATE HELPER FUNCTIONS
-- ==========================================
create or replace function private.current_organization_id()
returns uuid
language sql
security definer
set search_path = ''
stable
as $$
    select organization_id from public.profiles where id = auth.uid();
$$;

create or replace function private.current_role_code()
returns text
language sql
security definer
set search_path = ''
stable
as $$
    select r.code 
    from public.user_roles ur
    join public.roles r on r.id = ur.role_id
    where ur.user_id = auth.uid()
    limit 1;
$$;

create or replace function private.has_role(role_name text)
returns boolean
language sql
security definer
set search_path = ''
stable
as $$
    select exists (
        select 1 
        from public.user_roles ur
        join public.roles r on r.id = ur.role_id
        where ur.user_id = auth.uid() and r.code = role_name
    );
$$;

create or replace function private.has_any_role(role_names text[])
returns boolean
language sql
security definer
set search_path = ''
stable
as $$
    select exists (
        select 1 
        from public.user_roles ur
        join public.roles r on r.id = ur.role_id
        where ur.user_id = auth.uid() and r.code = any(role_names)
    );
$$;

create or replace function private.is_department_head_of(dept_id uuid)
returns boolean
language sql
security definer
set search_path = ''
stable
as $$
    select exists (
        select 1 from public.departments
        where id = dept_id and department_head_id = auth.uid()
    );
$$;

create or replace function private.is_asset_holder(check_asset_id uuid)
returns boolean
language sql
security definer
set search_path = ''
stable
as $$
    select exists (
        select 1 from public.asset_allocations
        where asset_id = check_asset_id 
        and allocated_to_employee_id = auth.uid()
        and status = 'active'
    );
$$;

create or replace function private.is_assigned_auditor(cycle_id uuid)
returns boolean
language sql
security definer
set search_path = ''
stable
as $$
    select exists (
        select 1 from public.audit_cycle_auditors
        where audit_cycle_id = cycle_id and auditor_id = auth.uid()
    );
$$;

create or replace function private.is_assigned_technician(request_id uuid)
returns boolean
language sql
security definer
set search_path = ''
stable
as $$
    select exists (
        select 1 from public.maintenance_requests
        where id = request_id and technician_id = auth.uid()
    );
$$;

-- ==========================================
-- 2. AUTH TRIGGERS
-- ==========================================
create or replace function public.handle_new_user()
returns trigger
language plpgsql
security definer
set search_path = ''
as $$
declare
    default_org_id uuid;
    employee_role_id uuid;
    normalized_email text;
    user_full_name text;
begin
    -- 1. Read default organization
    select id into default_org_id from public.organizations where code = 'ASSETSPHERE';
    if default_org_id is null then
        raise exception 'Default organization ASSETSPHERE not found.';
    end if;

    -- 2. Find employee role
    select id into employee_role_id from public.roles where code = 'employee';
    if employee_role_id is null then
        raise exception 'Role "employee" not found.';
    end if;

    -- 3. Normalize email and safe metadata
    normalized_email := lower(trim(new.email));
    user_full_name := coalesce(new.raw_user_meta_data->>'full_name', 'Unknown User');

    -- 4. Insert profile
    insert into public.profiles (id, organization_id, full_name, email, status)
    values (new.id, default_org_id, user_full_name, normalized_email, 'active');

    -- 5. Insert exactly one user role
    insert into public.user_roles (user_id, role_id)
    values (new.id, employee_role_id);

    return new;
end;
$$;

drop trigger if exists on_auth_user_created on auth.users;
create trigger on_auth_user_created
after insert on auth.users
for each row execute function public.handle_new_user();

-- ==========================================
-- 3. WORKFLOW FUNCTIONS
-- ==========================================

-- register_asset
create or replace function public.register_asset(
    p_name text,
    p_category_id uuid,
    p_condition public.asset_condition,
    p_serial_number text default null,
    p_acquisition_date date default null,
    p_acquisition_cost numeric default null,
    p_location_id uuid default null,
    p_department_id uuid default null,
    p_is_shared boolean default false,
    p_is_bookable boolean default false,
    p_warranty_expiry_date date default null,
    p_notes text default null
) returns public.assets
language plpgsql
security definer
set search_path = ''
as $$
declare
    v_org_id uuid;
    v_new_asset public.assets;
    v_counter integer;
    v_tag text;
begin
    v_org_id := private.current_organization_id();
    
    if not private.has_any_role(array['admin', 'asset_manager']) then
        raise exception 'Unauthorized to register assets.';
    end if;

    -- Lock and increment counter safely
    update public.asset_tag_counters
    set current_value = current_value + 1
    where organization_id = v_org_id
    returning current_value into v_counter;

    v_tag := 'AF-' || lpad(v_counter::text, 4, '0');

    insert into public.assets (
        organization_id, asset_tag, name, category_id, serial_number, 
        acquisition_date, acquisition_cost, condition, location_id, 
        department_id, is_shared, is_bookable, warranty_expiry_date, 
        notes, created_by
    ) values (
        v_org_id, v_tag, p_name, p_category_id, p_serial_number,
        p_acquisition_date, p_acquisition_cost, p_condition, p_location_id,
        p_department_id, p_is_shared, p_is_bookable, p_warranty_expiry_date,
        p_notes, auth.uid()
    ) returning * into v_new_asset;

    insert into public.asset_status_history (asset_id, new_status, reason, changed_by)
    values (v_new_asset.id, 'available', 'Initial registration', auth.uid());

    insert into public.activity_logs (organization_id, actor_id, action, entity_type, entity_id, description)
    values (v_org_id, auth.uid(), 'register_asset', 'asset', v_new_asset.id, 'Registered asset ' || v_tag);

    return v_new_asset;
end;
$$;

-- allocate_asset
create or replace function public.allocate_asset(
    p_asset_id uuid,
    p_employee_id uuid default null,
    p_department_id uuid default null,
    p_expected_return_date date default null,
    p_checkout_condition public.asset_condition default 'good'
) returns public.asset_allocations
language plpgsql
security definer
set search_path = ''
as $$
declare
    v_asset public.assets;
    v_allocation public.asset_allocations;
    v_org_id uuid;
begin
    v_org_id := private.current_organization_id();
    
    if not private.has_any_role(array['admin', 'asset_manager']) then
        raise exception 'Unauthorized to allocate assets.';
    end if;

    select * into v_asset from public.assets where id = p_asset_id and organization_id = v_org_id for update;
    if not found then
        raise exception 'Asset not found.';
    end if;

    if v_asset.status != 'available' then
        raise exception 'Asset is not available for allocation.';
    end if;

    if num_nonnulls(p_employee_id, p_department_id) != 1 then
        raise exception 'Must provide exactly one of employee_id or department_id.';
    end if;

    update public.assets
    set status = 'allocated'
    where id = p_asset_id;

    insert into public.asset_allocations (
        organization_id, asset_id, allocated_to_employee_id, allocated_to_department_id,
        allocated_by, expected_return_date, checkout_condition
    ) values (
        v_org_id, p_asset_id, p_employee_id, p_department_id,
        auth.uid(), p_expected_return_date, p_checkout_condition
    ) returning * into v_allocation;

    insert into public.asset_status_history (asset_id, old_status, new_status, reason, changed_by)
    values (p_asset_id, 'available', 'allocated', 'Asset allocated', auth.uid());

    if p_employee_id is not null then
        insert into public.notifications (organization_id, user_id, title, message, type, entity_type, entity_id)
        values (v_org_id, p_employee_id, 'Asset Assigned', 'You have been assigned asset ' || v_asset.asset_tag, 'asset_assigned', 'asset', p_asset_id);
    end if;

    insert into public.activity_logs (organization_id, actor_id, action, entity_type, entity_id, description)
    values (v_org_id, auth.uid(), 'allocate_asset', 'asset', p_asset_id, 'Allocated asset ' || v_asset.asset_tag);

    return v_allocation;
end;
$$;

-- Other placeholder workflow functions (fully fleshed out per prompt)
create or replace function public.assign_user_role(p_user_id uuid, p_role_code text)
returns void
language plpgsql
security definer
set search_path = ''
as $$
declare
    v_role_id uuid;
    v_org_id uuid;
begin
    if not private.has_role('admin') then
        raise exception 'Unauthorized.';
    end if;

    v_org_id := private.current_organization_id();
    select id into v_role_id from public.roles where code = p_role_code;
    if not found then raise exception 'Role not found'; end if;

    -- Prevent demoting the last admin
    if p_role_code != 'admin' then
        if exists(
            select 1 from public.user_roles ur 
            join public.roles r on r.id = ur.role_id 
            where ur.user_id = p_user_id and r.code = 'admin'
        ) and (
            select count(*) from public.user_roles ur 
            join public.roles r on r.id = ur.role_id 
            join public.profiles p on p.id = ur.user_id
            where r.code = 'admin' and p.status = 'active' and p.organization_id = v_org_id
        ) <= 1 then
            raise exception 'Cannot demote the last active admin.';
        end if;
    end if;

    update public.user_roles
    set role_id = v_role_id, assigned_by = auth.uid(), updated_at = now()
    where user_id = p_user_id;

    insert into public.activity_logs (organization_id, actor_id, action, entity_type, entity_id, description)
    values (v_org_id, auth.uid(), 'assign_role', 'user', p_user_id, 'Assigned role ' || p_role_code);
end;
$$;

create or replace function public.create_resource_booking(
    p_asset_id uuid,
    p_title text,
    p_start_time timestamptz,
    p_end_time timestamptz,
    p_purpose text default null
) returns public.resource_bookings
language plpgsql
security definer
set search_path = ''
as $$
declare
    v_asset public.assets;
    v_booking public.resource_bookings;
    v_org_id uuid;
begin
    v_org_id := private.current_organization_id();
    
    select * into v_asset from public.assets where id = p_asset_id and organization_id = v_org_id;
    if not found or not v_asset.is_shared or not v_asset.is_bookable then
        raise exception 'Asset is not bookable.';
    end if;

    if v_asset.status in ('under_maintenance', 'retired', 'disposed', 'lost') then
        raise exception 'Asset is currently unavailable for booking due to its status.';
    end if;

    -- The exclusion constraint ex_resource_bookings_overlap will handle overlap prevention automatically
    insert into public.resource_bookings (
        organization_id, asset_id, booked_by, title, purpose, start_time, end_time, status
    ) values (
        v_org_id, p_asset_id, auth.uid(), p_title, p_purpose, p_start_time, p_end_time, 'upcoming'
    ) returning * into v_booking;

    insert into public.notifications (organization_id, user_id, title, message, type, entity_type, entity_id)
    values (v_org_id, auth.uid(), 'Booking Confirmed', 'Booking ' || p_title || ' confirmed', 'booking_confirmed', 'booking', v_booking.id);

    return v_booking;
end;
$$;

-- Mark notification read
create or replace function public.mark_notification_read(p_notification_id uuid)
returns void
language plpgsql
security definer
set search_path = ''
as $$
begin
    update public.notifications
    set is_read = true, read_at = now()
    where id = p_notification_id and user_id = auth.uid();
end;
$$;

-- Revoke unsafe default execution
revoke execute on all functions in schema public from public;
revoke execute on all functions in schema public from anon;
grant execute on all functions in schema public to authenticated;

commit;
