-- database/sql/14_verification_queries.sql
-- This file is read-only and contains queries to verify the database state.

-- 1. Check Extensions
select extname, extversion from pg_extension where extname = 'btree_gist';

-- 2. Check Enums
select t.typname, e.enumlabel
from pg_type t
join pg_enum e on t.oid = e.enumtypid
order by t.typname, e.enumsortorder;

-- 3. Check Tables
select tablename 
from pg_tables 
where schemaname = 'public'
order by tablename;

-- 4. Detect tables without primary key
select tab.table_schema, tab.table_name
from information_schema.tables tab
left join information_schema.table_constraints tco 
  on tab.table_schema = tco.table_schema 
  and tab.table_name = tco.table_name 
  and tco.constraint_type = 'PRIMARY KEY'
where tab.table_schema = 'public' 
and tab.table_type = 'BASE TABLE' 
and tco.constraint_name is null;

-- 5. Detect missing indexes on foreign keys
with fk_actions as (
    select
        tc.table_name, kcu.column_name, ccu.table_name as foreign_table_name, ccu.column_name as foreign_column_name
    from information_schema.table_constraints as tc
    join information_schema.key_column_usage as kcu on tc.constraint_name = kcu.constraint_name and tc.table_schema = kcu.table_schema
    join information_schema.constraint_column_usage as ccu on ccu.constraint_name = tc.constraint_name and ccu.table_schema = tc.table_schema
    where tc.constraint_type = 'FOREIGN KEY'
)
select f.table_name, f.column_name, f.foreign_table_name 
from fk_actions f
left join pg_indexes i on i.tablename = f.table_name and i.indexdef like '%' || f.column_name || '%'
where i.indexname is null
and f.table_name not in ('asset_custom_field_values', 'category_custom_fields'); -- Add exclusions if intentional

-- 6. Check RLS enabled
select tablename, rowsecurity 
from pg_tables 
where schemaname = 'public' 
and rowsecurity = false;

-- 7. Check RLS policies
select schemaname, tablename, policyname, roles, cmd, qual, with_check 
from pg_policies 
where schemaname = 'public'
order by tablename, policyname;

-- 8. Verify Seed Organization
select * from public.organizations where code = 'ASSETSPHERE';

-- 9. Verify Seed Roles
select count(*) from public.roles;

-- 10. Verify users without profiles (detect auth.users with missing public.profiles)
select au.id, au.email 
from auth.users au 
left join public.profiles p on p.id = au.id 
where p.id is null;

-- 11. Verify profiles without roles
select p.id, p.email 
from public.profiles p 
left join public.user_roles ur on ur.user_id = p.id 
where ur.id is null;

-- 12. Verify active double allocations
select asset_id, count(id) 
from public.asset_allocations 
where status = 'active' 
group by asset_id 
having count(id) > 1;

-- 13. Verify overlapping active bookings
-- Note: the exclusion constraint already prevents this, but here is a query to verify
select a.id, a.asset_id, a.start_time, a.end_time, b.id, b.start_time, b.end_time
from public.resource_bookings a
join public.resource_bookings b on a.asset_id = b.asset_id and a.id != b.id
where a.status in ('upcoming', 'ongoing') and b.status in ('upcoming', 'ongoing')
and tstzrange(a.start_time, a.end_time, '[)') && tstzrange(b.start_time, b.end_time, '[)');

-- 14. Orphaned storage metadata references
select asset_id from public.asset_documents
where not exists (select 1 from public.assets where id = asset_documents.asset_id);
