# Schema Reference

## Identity & Access Management
- **organizations**: Top-level tenant. All records map to an organization.
- **roles**: Defines static roles (`admin`, `asset_manager`, `department_head`, `employee`, `auditor`, `technician`).
- **user_roles**: Links a user to exactly one role.
- **profiles**: Extended user information mapping 1:1 with `auth.users`. Contains `organization_id` and `department_id`.

## Organizational Structure
- **departments**: Self-referencing hierarchy. Maps to an organization and an optional department head.
- **locations**: Physical locations within an organization.

## Assets
- **asset_categories**: Types of assets (e.g. Electronics, Furniture) with global warranty rules.
- **category_custom_fields**: Dynamic schema definition for asset categories.
- **assets**: The primary entity. Contains core fields, location, department mapping, and condition/status. Uses `asset_tag` uniquely per organization.
- **asset_custom_field_values**: EAV store for dynamic asset attributes matching `category_custom_fields`.
- **asset_tag_counters**: A concurrency-safe sequence generator for asset tags per organization.
- **asset_documents**: Files related to an asset.
- **asset_status_history** & **asset_condition_history**: Append-only logs for state changes.

## Allocations & Movements
- **asset_allocations**: Active or historical assignments of an asset to an employee or department. A partial unique index prevents concurrent active allocations.
- **transfer_requests**: Requests to move an asset from one allocation target to another.
- **return_requests**: Requests to return an allocated asset.

## Resource Bookings
- **resource_bookings**: Time-based reservations of shared, bookable assets. Overlaps are strictly prevented at the database level using GiST exclusion constraints on `start_time` and `end_time`.
- **booking_status_history**: Logs of booking state changes.

## Maintenance
- **maintenance_requests**: Ticketing system for asset repairs.
- **maintenance_attachments**: Files/images describing issues or resolutions.
- **maintenance_status_history**: History of ticket status changes.

## Audits
- **audit_cycles**: A bounded time period for auditing assets within a scope (location/department).
- **audit_cycle_auditors**: The staff permitted to perform the audit.
- **audit_items**: Specific assets expected to be audited.
- **audit_discrepancies**: Findings resulting from failed or missing audit items.

## Observability
- **notifications**: User alerts for workflows (e.g., booking confirmed, maintenance assigned).
- **activity_logs**: Append-only system-generated audit logs of important actions. Clients cannot directly manipulate these.

## Constraints & Indexes
- Foreign keys explicitly cascade where logical (e.g., deleting an organization deletes all its assets), but restrict when dangerous (e.g., deleting an asset category).
- Enums are heavily used to restrict status and condition fields.
- Partial unique indexes are used to enforce business rules (like one active allocation per asset).
- Exclusion constraints (`tstzrange` with `&&`) enforce non-overlapping bookings.
