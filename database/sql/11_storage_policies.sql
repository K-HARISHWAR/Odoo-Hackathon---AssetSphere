-- database/sql/11_storage_policies.sql

begin;

-- Asset Images
drop policy if exists "asset_images_read" on storage.objects;
create policy "asset_images_read" on storage.objects
for select to authenticated
using (
    bucket_id = 'asset-images' 
    and (select private.current_organization_id()::text) = (string_to_array(name, '/'))[1]
);

drop policy if exists "asset_images_write" on storage.objects;
create policy "asset_images_write" on storage.objects
for insert to authenticated
with check (
    bucket_id = 'asset-images' 
    and (select private.current_organization_id()::text) = (string_to_array(name, '/'))[1]
    and private.has_any_role(array['admin', 'asset_manager'])
);

drop policy if exists "asset_images_update" on storage.objects;
create policy "asset_images_update" on storage.objects
for update to authenticated
using (
    bucket_id = 'asset-images' 
    and (select private.current_organization_id()::text) = (string_to_array(name, '/'))[1]
    and private.has_any_role(array['admin', 'asset_manager'])
);

drop policy if exists "asset_images_delete" on storage.objects;
create policy "asset_images_delete" on storage.objects
for delete to authenticated
using (
    bucket_id = 'asset-images' 
    and (select private.current_organization_id()::text) = (string_to_array(name, '/'))[1]
    and private.has_any_role(array['admin', 'asset_manager'])
);

-- Asset Documents
drop policy if exists "asset_docs_read" on storage.objects;
create policy "asset_docs_read" on storage.objects
for select to authenticated
using (
    bucket_id = 'asset-documents' 
    and (select private.current_organization_id()::text) = (string_to_array(name, '/'))[1]
);

drop policy if exists "asset_docs_write" on storage.objects;
create policy "asset_docs_write" on storage.objects
for insert to authenticated
with check (
    bucket_id = 'asset-documents' 
    and (select private.current_organization_id()::text) = (string_to_array(name, '/'))[1]
    and private.has_any_role(array['admin', 'asset_manager'])
);

drop policy if exists "asset_docs_update" on storage.objects;
create policy "asset_docs_update" on storage.objects
for update to authenticated
using (
    bucket_id = 'asset-documents' 
    and (select private.current_organization_id()::text) = (string_to_array(name, '/'))[1]
    and private.has_any_role(array['admin', 'asset_manager'])
);

drop policy if exists "asset_docs_delete" on storage.objects;
create policy "asset_docs_delete" on storage.objects
for delete to authenticated
using (
    bucket_id = 'asset-documents' 
    and (select private.current_organization_id()::text) = (string_to_array(name, '/'))[1]
    and private.has_any_role(array['admin', 'asset_manager'])
);

-- Maintenance Attachments
drop policy if exists "maint_attach_read" on storage.objects;
create policy "maint_attach_read" on storage.objects
for select to authenticated
using (
    bucket_id = 'maintenance-attachments' 
    and (select private.current_organization_id()::text) = (string_to_array(name, '/'))[1]
);

drop policy if exists "maint_attach_write" on storage.objects;
create policy "maint_attach_write" on storage.objects
for insert to authenticated
with check (
    bucket_id = 'maintenance-attachments' 
    and (select private.current_organization_id()::text) = (string_to_array(name, '/'))[1]
);

-- Audit Evidence
drop policy if exists "audit_evidence_read" on storage.objects;
create policy "audit_evidence_read" on storage.objects
for select to authenticated
using (
    bucket_id = 'audit-evidence' 
    and (select private.current_organization_id()::text) = (string_to_array(name, '/'))[1]
    and (private.has_any_role(array['admin', 'asset_manager', 'auditor']))
);

drop policy if exists "audit_evidence_write" on storage.objects;
create policy "audit_evidence_write" on storage.objects
for insert to authenticated
with check (
    bucket_id = 'audit-evidence' 
    and (select private.current_organization_id()::text) = (string_to_array(name, '/'))[1]
    and private.has_role('auditor')
);

-- Profile Images
drop policy if exists "profile_images_read" on storage.objects;
create policy "profile_images_read" on storage.objects
for select to authenticated
using (
    bucket_id = 'profile-images' 
    and (select private.current_organization_id()::text) = (string_to_array(name, '/'))[1]
);

drop policy if exists "profile_images_write" on storage.objects;
create policy "profile_images_write" on storage.objects
for insert to authenticated
with check (
    bucket_id = 'profile-images' 
    and (select private.current_organization_id()::text) = (string_to_array(name, '/'))[1]
    and auth.uid()::text = (string_to_array(name, '/'))[3] -- organization-id/profiles/user-id/file-name
);

drop policy if exists "profile_images_update" on storage.objects;
create policy "profile_images_update" on storage.objects
for update to authenticated
using (
    bucket_id = 'profile-images' 
    and (select private.current_organization_id()::text) = (string_to_array(name, '/'))[1]
    and auth.uid()::text = (string_to_array(name, '/'))[3]
);

drop policy if exists "profile_images_delete" on storage.objects;
create policy "profile_images_delete" on storage.objects
for delete to authenticated
using (
    bucket_id = 'profile-images' 
    and (select private.current_organization_id()::text) = (string_to_array(name, '/'))[1]
    and auth.uid()::text = (string_to_array(name, '/'))[3]
);

commit;
