# Supabase Dashboard Runbook

This guide explains how to deploy the AssetSphere database schema using the hosted Supabase Dashboard.

## 1. SQL Execution
1. Open your Supabase project dashboard.
2. Navigate to **SQL Editor** on the left menu.
3. Open the scripts from `database/sql/` sequentially.
4. Copy the entire contents of a script, paste it into the editor, and click **Run**.
5. Ensure the execution completes with "Success".
6. Repeat for files `01` through `13` in exact numerical order.

> [!WARNING]
> If a script fails midway, DO NOT blindly click Run again. The transactions (`begin; ... commit;`) generally protect against partial schemas, but inspect the error message carefully.

## 2. Storage Buckets
The SQL policies in `11_storage_policies.sql` expect specific buckets. You must create these manually in the Supabase Dashboard:

1. Navigate to **Storage**.
2. Click **New Bucket**.
3. Create the following buckets EXACTLY as spelled:
   - `asset-images`
   - `asset-documents`
   - `maintenance-attachments`
   - `audit-evidence`
   - `profile-images`
4. **Make sure "Public" is toggled OFF.** Do not make them public.

## 3. First User Creation (Bootstrapping)
Because user accounts map to `auth.users`, you must create the first user through the dashboard to trigger the profile creation.

1. Navigate to **Authentication** -> **Users**.
2. Click **Add User** -> **Create New User**.
3. Provide an email (e.g., `admin@assetsphere.com`) and a password.
4. Disable "Auto Confirm User" if you haven't set up SMTP, or manually verify the email.
5. Once created, the database trigger (`handle_new_user`) will automatically assign them the `employee` role and the `ASSETSPHERE` default organization.

### Elevate to Admin
By default, the first user is an `employee`. You must manually promote them to `admin` using the SQL Editor:
```sql
-- Replace the email with the one you created
update public.user_roles ur
set role_id = (select id from public.roles where code = 'admin')
from public.profiles p
where p.id = ur.user_id and p.email = 'admin@assetsphere.com';
```

## 4. Verification
After executing all scripts and setting up storage, open script `14_verification_queries.sql` in the SQL Editor. 
Run the queries one by one to verify:
- Btree_gist extension is installed.
- All RLS policies are active.
- Seed data exists.

## 5. Scheduled Functions (pg_cron)
The dashboard views and scheduled functions were created in script 13. To activate them, you must configure `pg_cron` manually in the Supabase Dashboard:

1. Go to **Database** -> **Extensions** and ensure `pg_cron` is enabled.
2. Open the SQL Editor and schedule the jobs. For example:
```sql
-- Runs daily at midnight
select cron.schedule('mark_overdue', '0 0 * * *', $$ select public.mark_overdue_allocations(); $$);
select cron.schedule('update_bookings', '0 * * * *', $$ select public.update_booking_statuses(); $$);
```

## 6. Security Warnings
> [!CAUTION]
> Never put API keys, Service Role keys, SMTP passwords, or live database connection strings in the Git repository. Keep the `.env` files completely ignored by version control.
