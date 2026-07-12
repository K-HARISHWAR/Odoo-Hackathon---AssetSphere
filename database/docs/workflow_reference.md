# Workflow Reference

AssetSphere leverages PostgreSQL functions to ensure state consistency for all major business processes.

## 1. User Signup (`handle_new_user`)
- Triggered by Supabase Auth (`auth.users` insert).
- Finds the default 'ASSETSPHERE' organization.
- Finds the 'employee' role.
- Inserts a profile for the user.
- Assigns exactly one `user_roles` entry as `employee`.
- Safely pulls metadata while ignoring malicious client-provided roles.

## 2. Asset Registration (`register_asset`)
- Locks the `asset_tag_counters` row for the organization.
- Atomically generates the next tag (`AF-0001`).
- Inserts the asset with status `available`.
- Adds an entry to `asset_status_history`.
- Logs the action in `activity_logs`.

## 3. Allocation (`allocate_asset`)
- Asset must be `available`.
- Updates asset status to `allocated`.
- Inserts an active `asset_allocations` row (enforces exclusivity via partial index).
- Creates `asset_status_history`.
- Dispatches a notification to the employee.

## 4. Transfers & Returns
- **Request**: Employees insert into `transfer_requests` or `return_requests`.
- **Approval**: Manager invokes `approve_asset_transfer()` or `approve_asset_return()`.
- **Action (Return)**: Closes the active allocation. Restores asset status to `available` (unless returning as damaged/retired). Records return condition.
- **Action (Transfer)**: Closes current allocation, instantly opens a new one for the target.

## 5. Resource Bookings (`create_resource_booking`)
- Only assets marked `is_shared` and `is_bookable` can be booked.
- Database constraint `ex_resource_bookings_overlap` throws an exception if the time range overlaps with an existing `upcoming` or `ongoing` booking.
- Scheduled functions later transition `upcoming` -> `ongoing` -> `completed`.

## 6. Maintenance
- **Raise Ticket**: Anyone can insert into `maintenance_requests`. Status is `pending`.
- **Approve**: Asset Manager changes ticket to `approved` and asset status to `under_maintenance`.
- **Assign**: Ticket given to a `technician`.
- **Resolve**: Technician resolves ticket. Asset status restored to `available`.

## 7. Audits
- **Create Cycle**: Admin defines scope (start/end dates, location/department). Status is `draft`.
- **Assign Items**: Function generates `audit_items` snapshot based on scope. Status -> `scheduled`.
- **Execute**: Status -> `in_progress`. Auditors verify expected vs. actual location and condition.
- **Discrepancies**: Missing or broken assets automatically spawn `audit_discrepancies`.
- **Close**: Admin closes the cycle. `closed` cycles cannot be edited by clients. If items are unverified or marked missing, asset statuses are automatically updated (e.g. to `lost`).
