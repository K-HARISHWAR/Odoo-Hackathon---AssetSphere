-- database/sql/10_row_level_security.sql

begin;

-- Enable RLS on all public tables
alter table public.organizations enable row level security;
alter table public.roles enable row level security;
alter table public.departments enable row level security;
alter table public.profiles enable row level security;
alter table public.locations enable row level security;
alter table public.asset_categories enable row level security;
alter table public.category_custom_fields enable row level security;
alter table public.user_roles enable row level security;
alter table public.asset_tag_counters enable row level security;
alter table public.assets enable row level security;
alter table public.asset_custom_field_values enable row level security;
alter table public.asset_documents enable row level security;
alter table public.asset_status_history enable row level security;
alter table public.asset_condition_history enable row level security;
alter table public.asset_allocations enable row level security;
alter table public.transfer_requests enable row level security;
alter table public.return_requests enable row level security;
alter table public.resource_bookings enable row level security;
alter table public.booking_status_history enable row level security;
alter table public.maintenance_requests enable row level security;
alter table public.maintenance_attachments enable row level security;
alter table public.maintenance_status_history enable row level security;
alter table public.audit_cycles enable row level security;
alter table public.audit_cycle_auditors enable row level security;
alter table public.audit_items enable row level security;
alter table public.audit_discrepancies enable row level security;
alter table public.notifications enable row level security;
alter table public.activity_logs enable row level security;

-- ==========================================
-- COMMON POLICIES
-- ==========================================

-- Organizations: users can only see their own org
drop policy if exists "users_read_own_org" on public.organizations;
create policy "users_read_own_org" on public.organizations
for select to authenticated
using (id = private.current_organization_id());

-- Roles: everyone needs to read roles
drop policy if exists "everyone_read_roles" on public.roles;
create policy "everyone_read_roles" on public.roles
for select to authenticated
using (true);

-- Profiles: read profiles in same org
drop policy if exists "users_read_org_profiles" on public.profiles;
create policy "users_read_org_profiles" on public.profiles
for select to authenticated
using (organization_id = private.current_organization_id());

-- Profiles: user can update safe fields on their own profile
drop policy if exists "users_update_own_profile" on public.profiles;
create policy "users_update_own_profile" on public.profiles
for update to authenticated
using (id = auth.uid())
with check (id = auth.uid() and organization_id = private.current_organization_id());

-- Notifications: read own
drop policy if exists "users_read_own_notifications" on public.notifications;
create policy "users_read_own_notifications" on public.notifications
for select to authenticated
using (user_id = auth.uid());

-- Assets: read shared/bookable assets
drop policy if exists "users_read_shared_assets" on public.assets;
create policy "users_read_shared_assets" on public.assets
for select to authenticated
using (organization_id = private.current_organization_id() and (is_shared = true or is_bookable = true));

-- User Roles: read user roles in same org
drop policy if exists "users_read_org_user_roles" on public.user_roles;
create policy "users_read_org_user_roles" on public.user_roles
for select to authenticated
using (
    exists (
        select 1 from public.profiles p 
        where p.id = user_roles.user_id 
        and p.organization_id = private.current_organization_id()
    )
);

-- ==========================================
-- EMPLOYEE POLICIES
-- ==========================================
drop policy if exists "employee_read_own_allocations" on public.asset_allocations;
create policy "employee_read_own_allocations" on public.asset_allocations
for select to authenticated
using (organization_id = private.current_organization_id() and allocated_to_employee_id = auth.uid());

drop policy if exists "employee_read_allocated_assets" on public.assets;
create policy "employee_read_allocated_assets" on public.assets
for select to authenticated
using (
    organization_id = private.current_organization_id() and
    id in (
        select asset_id from public.asset_allocations 
        where allocated_to_employee_id = auth.uid()
        and status = 'active'
    )
);

drop policy if exists "employee_read_own_bookings" on public.resource_bookings;
create policy "employee_read_own_bookings" on public.resource_bookings
for select to authenticated
using (organization_id = private.current_organization_id() and booked_by = auth.uid());

-- ==========================================
-- ADMIN / ASSET MANAGER POLICIES
-- ==========================================
drop policy if exists "admin_manager_read_all_assets" on public.assets;
create policy "admin_manager_read_all_assets" on public.assets
for select to authenticated
using (
    organization_id = private.current_organization_id() 
    and private.has_any_role(array['admin', 'asset_manager'])
);

drop policy if exists "admin_manager_read_all_allocations" on public.asset_allocations;
create policy "admin_manager_read_all_allocations" on public.asset_allocations
for select to authenticated
using (
    organization_id = private.current_organization_id() 
    and private.has_any_role(array['admin', 'asset_manager'])
);

drop policy if exists "admin_read_activity_logs" on public.activity_logs;
create policy "admin_read_activity_logs" on public.activity_logs
for select to authenticated
using (
    organization_id = private.current_organization_id() 
    and private.has_role('admin')
);

drop policy if exists "admin_manage_departments" on public.departments;
create policy "admin_manage_departments" on public.departments
for all to authenticated
using (
    organization_id = private.current_organization_id() 
    and private.has_role('admin')
);

drop policy if exists "everyone_read_departments" on public.departments;
create policy "everyone_read_departments" on public.departments
for select to authenticated
using (organization_id = private.current_organization_id());

-- Locations
drop policy if exists "admin_manage_locations" on public.locations;
create policy "admin_manage_locations" on public.locations
for all to authenticated
using (
    organization_id = private.current_organization_id() 
    and private.has_role('admin')
);

drop policy if exists "everyone_read_locations" on public.locations;
create policy "everyone_read_locations" on public.locations
for select to authenticated
using (organization_id = private.current_organization_id());

-- Asset Categories
drop policy if exists "admin_manage_categories" on public.asset_categories;
create policy "admin_manage_categories" on public.asset_categories
for all to authenticated
using (
    organization_id = private.current_organization_id() 
    and private.has_role('admin')
);

drop policy if exists "everyone_read_categories" on public.asset_categories;
create policy "everyone_read_categories" on public.asset_categories
for select to authenticated
using (organization_id = private.current_organization_id());

-- Auditors
drop policy if exists "auditor_read_assigned_cycles" on public.audit_cycles;
create policy "auditor_read_assigned_cycles" on public.audit_cycles
for select to authenticated
using (
    organization_id = private.current_organization_id() 
    and (private.has_any_role(array['admin', 'asset_manager']) or private.is_assigned_auditor(id))
);

-- Technicians
drop policy if exists "technician_read_assigned_requests" on public.maintenance_requests;
create policy "technician_read_assigned_requests" on public.maintenance_requests
for select to authenticated
using (
    organization_id = private.current_organization_id() 
    and (private.has_any_role(array['admin', 'asset_manager']) or technician_id = auth.uid() or raised_by = auth.uid())
);

-- Grants
grant select, insert, update, delete on all tables in schema public to authenticated;

commit;
