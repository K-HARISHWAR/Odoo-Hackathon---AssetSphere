-- database/sql/13_dashboard_views_and_scheduled_functions.sql

begin;

-- ==========================================
-- 1. DASHBOARD VIEWS
-- ==========================================
-- Use secure views so they respect RLS of the underlying tables

create or replace view public.dashboard_asset_status_counts as
select 
    organization_id,
    status,
    count(*) as count
from public.assets
group by organization_id, status;

create or replace view public.dashboard_overdue_allocations as
select 
    a.id as allocation_id,
    a.organization_id,
    a.asset_id,
    ast.asset_tag,
    ast.name as asset_name,
    a.allocated_to_employee_id,
    a.allocated_to_department_id,
    a.expected_return_date
from public.asset_allocations a
join public.assets ast on ast.id = a.asset_id
where a.status = 'active' 
and a.expected_return_date < current_date;

create or replace view public.dashboard_upcoming_returns as
select 
    a.id as allocation_id,
    a.organization_id,
    a.asset_id,
    ast.asset_tag,
    ast.name as asset_name,
    a.allocated_to_employee_id,
    a.allocated_to_department_id,
    a.expected_return_date
from public.asset_allocations a
join public.assets ast on ast.id = a.asset_id
where a.status = 'active' 
and a.expected_return_date between current_date and current_date + interval '7 days';

create or replace view public.dashboard_active_bookings as
select 
    b.id as booking_id,
    b.organization_id,
    b.asset_id,
    ast.asset_tag,
    ast.name as asset_name,
    b.booked_by,
    b.title,
    b.start_time,
    b.end_time
from public.resource_bookings b
join public.assets ast on ast.id = b.asset_id
where b.status = 'ongoing' or (b.status = 'upcoming' and b.start_time <= current_timestamp + interval '24 hours');

create or replace view public.dashboard_pending_transfers as
select 
    t.id as transfer_id,
    t.organization_id,
    t.asset_id,
    ast.asset_tag,
    ast.name as asset_name,
    t.requested_by,
    t.requested_employee_id,
    t.requested_department_id,
    t.created_at as requested_at
from public.transfer_requests t
join public.assets ast on ast.id = t.asset_id
where t.status = 'requested';

create or replace view public.dashboard_maintenance_today as
select 
    m.id as maintenance_id,
    m.organization_id,
    m.asset_id,
    m.request_number,
    ast.asset_tag,
    ast.name as asset_name,
    m.priority,
    m.technician_id,
    m.status
from public.maintenance_requests m
join public.assets ast on ast.id = m.asset_id
where m.status in ('in_progress', 'technician_assigned', 'approved')
and (m.estimated_completion_date = current_date or m.started_at::date = current_date);

create or replace view public.department_allocation_summary as
select 
    a.organization_id,
    d.id as department_id,
    d.name as department_name,
    count(a.id) as total_active_allocations
from public.asset_allocations a
join public.departments d on d.id = coalesce(a.allocated_to_department_id, (select department_id from public.profiles where id = a.allocated_to_employee_id))
where a.status = 'active'
group by a.organization_id, d.id, d.name;

create or replace view public.asset_utilization_summary as
select 
    organization_id,
    category_id,
    count(id) filter (where status = 'allocated' or status = 'reserved') as utilized_assets,
    count(id) filter (where status = 'available') as available_assets,
    count(id) as total_assets
from public.assets
where status not in ('retired', 'disposed', 'lost')
group by organization_id, category_id;

create or replace view public.maintenance_frequency_summary as
select 
    m.organization_id,
    m.asset_id,
    ast.asset_tag,
    ast.name as asset_name,
    count(m.id) as maintenance_count
from public.maintenance_requests m
join public.assets ast on ast.id = m.asset_id
group by m.organization_id, m.asset_id, ast.asset_tag, ast.name;

create or replace view public.booking_heatmap_summary as
select 
    organization_id,
    asset_id,
    date_trunc('day', start_time) as booking_date,
    count(id) as total_bookings
from public.resource_bookings
where status in ('upcoming', 'ongoing', 'completed')
group by organization_id, asset_id, date_trunc('day', start_time);

create or replace view public.audit_discrepancy_summary as
select 
    c.organization_id,
    ad.status,
    count(ad.id) as count
from public.audit_discrepancies ad
join public.audit_items ai on ai.id = ad.audit_item_id
join public.audit_cycles c on c.id = ai.audit_cycle_id
group by c.organization_id, ad.status;

-- ==========================================
-- 2. SCHEDULED FUNCTIONS
-- ==========================================

-- Mark allocations overdue
create or replace function public.mark_overdue_allocations()
returns void
language plpgsql
security definer
set search_path = ''
as $$
begin
    update public.asset_allocations
    set status = 'overdue', updated_at = now()
    where status = 'active' and expected_return_date < current_date;
end;
$$;

-- Update booking statuses
create or replace function public.update_booking_statuses()
returns void
language plpgsql
security definer
set search_path = ''
as $$
begin
    -- Mark started bookings as ongoing
    update public.resource_bookings
    set status = 'ongoing', updated_at = now()
    where status = 'upcoming' and start_time <= current_timestamp;

    -- Mark ended bookings as completed
    update public.resource_bookings
    set status = 'completed', updated_at = now()
    where status = 'ongoing' and end_time <= current_timestamp;
end;
$$;

-- Create booking reminders
create or replace function public.create_booking_reminders()
returns void
language plpgsql
security definer
set search_path = ''
as $$
begin
    insert into public.notifications (organization_id, user_id, title, message, type, entity_type, entity_id)
    select 
        b.organization_id, 
        b.booked_by, 
        'Upcoming Booking Reminder', 
        'Your booking for ' || b.title || ' starts in less than 24 hours.', 
        'booking_reminder', 
        'booking', 
        b.id
    from public.resource_bookings b
    where b.status = 'upcoming' 
    and b.start_time <= current_timestamp + interval '24 hours'
    and b.reminder_sent_at is null;

    update public.resource_bookings
    set reminder_sent_at = now()
    where status = 'upcoming' 
    and start_time <= current_timestamp + interval '24 hours'
    and reminder_sent_at is null;
end;
$$;

-- Create upcoming return notifications
create or replace function public.create_upcoming_return_notifications()
returns void
language plpgsql
security definer
set search_path = ''
as $$
begin
    insert into public.notifications (organization_id, user_id, title, message, type, entity_type, entity_id)
    select 
        a.organization_id, 
        a.allocated_to_employee_id, 
        'Asset Return Due Soon', 
        'Your assigned asset is due for return on ' || a.expected_return_date, 
        'asset_return_due', 
        'allocation', 
        a.id
    from public.asset_allocations a
    where a.status = 'active' 
    and a.expected_return_date = current_date + interval '3 days'
    and a.allocated_to_employee_id is not null
    and not exists (
        select 1 from public.notifications n 
        where n.entity_id = a.id and n.type = 'asset_return_due'
    );
end;
$$;

-- Create maintenance deadline notifications
create or replace function public.create_maintenance_deadline_notifications()
returns void
language plpgsql
security definer
set search_path = ''
as $$
begin
    insert into public.notifications (organization_id, user_id, title, message, type, entity_type, entity_id)
    select 
        m.organization_id, 
        m.technician_id, 
        'Maintenance Deadline Approaching', 
        'Maintenance request ' || m.request_number || ' is due by ' || m.estimated_completion_date, 
        'system', 
        'maintenance', 
        m.id
    from public.maintenance_requests m
    where m.status in ('in_progress', 'technician_assigned')
    and m.estimated_completion_date = current_date + interval '1 day'
    and m.technician_id is not null
    and not exists (
        select 1 from public.notifications n 
        where n.entity_id = m.id and n.type = 'system' and n.title = 'Maintenance Deadline Approaching'
    );
end;
$$;

-- Create audit deadline notifications
create or replace function public.create_audit_deadline_notifications()
returns void
language plpgsql
security definer
set search_path = ''
as $$
begin
    insert into public.notifications (organization_id, user_id, title, message, type, entity_type, entity_id)
    select 
        ac.organization_id, 
        aca.auditor_id, 
        'Audit Cycle Ending Soon', 
        'Audit cycle ' || ac.name || ' is ending on ' || ac.end_date, 
        'system', 
        'audit_cycle', 
        ac.id
    from public.audit_cycles ac
    join public.audit_cycle_auditors aca on aca.audit_cycle_id = ac.id
    where ac.status = 'in_progress'
    and ac.end_date = current_date + interval '3 days'
    and not exists (
        select 1 from public.notifications n 
        where n.entity_id = ac.id and n.type = 'system' and n.title = 'Audit Cycle Ending Soon'
    );
end;
$$;

-- Ensure execute on public views/functions by authenticated users
grant select on all tables in schema public to authenticated;
grant execute on all functions in schema public to authenticated;

commit;
