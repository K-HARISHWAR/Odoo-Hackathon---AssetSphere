-- database/sql/01_extensions_and_enums.sql

begin;

-- ==========================================
-- 1. EXTENSIONS
-- ==========================================
create extension if not exists btree_gist;
create extension if not exists pg_trgm with schema extensions;

-- ==========================================
-- 2. SCHEMAS
-- ==========================================
create schema if not exists private;
revoke all on schema private from public;
revoke all on schema private from anon;
revoke all on schema private from authenticated;

-- ==========================================
-- 3. ENUMS
-- ==========================================
do $$ begin
    create type record_status as enum ('active', 'inactive');
exception when duplicate_object then null; end $$;

do $$ begin
    create type asset_status as enum (
        'available',
        'allocated',
        'reserved',
        'under_maintenance',
        'lost',
        'retired',
        'disposed'
    );
exception when duplicate_object then null; end $$;

do $$ begin
    create type asset_condition as enum (
        'new',
        'good',
        'fair',
        'damaged',
        'unusable'
    );
exception when duplicate_object then null; end $$;

do $$ begin
    create type allocation_status as enum (
        'active',
        'returned',
        'transferred',
        'cancelled',
        'overdue'
    );
exception when duplicate_object then null; end $$;

do $$ begin
    create type request_status as enum (
        'requested',
        'approved',
        'rejected',
        'completed',
        'cancelled'
    );
exception when duplicate_object then null; end $$;

do $$ begin
    create type booking_status as enum (
        'upcoming',
        'ongoing',
        'completed',
        'cancelled'
    );
exception when duplicate_object then null; end $$;

do $$ begin
    create type maintenance_priority as enum (
        'low',
        'medium',
        'high',
        'critical'
    );
exception when duplicate_object then null; end $$;

do $$ begin
    create type maintenance_status as enum (
        'pending',
        'approved',
        'rejected',
        'technician_assigned',
        'in_progress',
        'resolved',
        'cancelled'
    );
exception when duplicate_object then null; end $$;

do $$ begin
    create type audit_cycle_status as enum (
        'draft',
        'scheduled',
        'in_progress',
        'completed',
        'closed'
    );
exception when duplicate_object then null; end $$;

do $$ begin
    create type audit_verification_status as enum (
        'pending',
        'verified',
        'missing',
        'damaged'
    );
exception when duplicate_object then null; end $$;

do $$ begin
    create type discrepancy_status as enum (
        'open',
        'under_review',
        'resolved',
        'dismissed'
    );
exception when duplicate_object then null; end $$;

do $$ begin
    create type notification_type as enum (
        'asset_assigned',
        'asset_return_due',
        'asset_return_overdue',
        'transfer_requested',
        'transfer_approved',
        'transfer_rejected',
        'booking_confirmed',
        'booking_reminder',
        'booking_cancelled',
        'maintenance_requested',
        'maintenance_approved',
        'maintenance_rejected',
        'technician_assigned',
        'maintenance_resolved',
        'audit_assigned',
        'audit_discrepancy',
        'system'
    );
exception when duplicate_object then null; end $$;

-- ==========================================
-- 4. UTILITY FUNCTIONS
-- ==========================================
create or replace function public.trigger_set_updated_at()
returns trigger
language plpgsql
security definer
set search_path = ''
as $$
begin
    new.updated_at = now();
    return new;
end;
$$;

commit;
