# AssetSphere Database Foundation

This directory contains the complete PostgreSQL database foundation for the AssetSphere project, tailored for Supabase.

## Purpose
These scripts initialize the multi-tenant organization model, roles, user profiles, assets, maintenance, bookings, audits, and their associated row-level security (RLS) and storage policies.

## Execution Order
The SQL scripts **MUST** be executed in the exact numerical order provided. Some scripts depend on schema structures, types, and functions defined in earlier scripts.

1. `01_extensions_and_enums.sql`
2. `02_organization_identity.sql`
3. `03_assets.sql`
4. `04_allocations_transfers_returns.sql`
5. `05_resource_bookings.sql`
6. `06_maintenance.sql`
7. `07_audits.sql`
8. `08_notifications_activity_logs.sql`
9. `09_functions_and_auth_triggers.sql`
10. `10_row_level_security.sql`
11. `11_storage_policies.sql`
12. `12_seed_master_data.sql`
13. `13_dashboard_views_and_scheduled_functions.sql`
14. `14_verification_queries.sql`

## Supabase Dashboard-only Workflow
At this stage, we are not using the Supabase CLI migrations.
These scripts are intended for manual execution via the **Supabase SQL Editor**. See `docs/supabase_dashboard_runbook.md` for detailed instructions.

### Warnings
- **Do not skip script order.**
- **Do not rerun partially applied scripts blindly.** Each script contains transactions (`begin; ... commit;`) and idempotent commands where possible, but manual review is always required if a script fails mid-way due to syntax or state errors.

## Verification
Use `14_verification_queries.sql` after applying all scripts to verify the correctness of constraints, extensions, triggers, RLS, and seed data.

## Future Schema Changes
If new tables or columns are required, do not edit these initial 14 scripts if they have already been executed against production/staging. Instead, create a new script (e.g., `15_add_asset_depreciation.sql`).

**Rule:** All SQL Editor changes must also be saved in Git within this repository. Never modify the database directly without checking the corresponding `.sql` script into version control.
