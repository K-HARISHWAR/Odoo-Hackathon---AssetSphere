# Role & Permission Matrix

AssetSphere isolates all data by `organization_id`. Inside an organization, access is governed by the user's role.

## Roles

| Module | Admin | Asset Manager | Department Head | Employee | Auditor | Technician |
|---|---|---|---|---|---|---|
| **Org Setup** | All (CRUD) | None | Read-only | Read-only | Read-only | Read-only |
| **Roles** | All (Assign/Read) | Read-only | Read-only | Read-only | Read-only | Read-only |
| **Assets** | Read All | All (Reg/Update) | Read Dept Assets | Read Allocated | Read Cycle Scope | Read Maint Assets |
| **Allocations** | Read All | All (Create/End) | Read Dept Alloc | Read Own | None | None |
| **Transfers** | Read All | Approve/Reject | Request | Request | None | None |
| **Returns** | Read All | Approve/Reject | Request | Request | None | None |
| **Bookings** | Read All | Read All | Create (Dept) | Create (Self) | None | None |
| **Maintenance** | Read All | Approve/Reject/Assign | Create | Create | None | Resolve/Update |
| **Audits** | All (Create/Close) | Read All | Read-only | None | Execute Assigned | None |
| **Notifications** | Read/Update Own | Read/Update Own | Read/Update Own | Read/Update Own | Read/Update Own | Read/Update Own |
| **Activity Logs** | Read All | None | None | None | None | None |
| **Reports (Dash)**| Read All | Read All | Dept Summary | None | None | None |

## Notes on Workflow Functions
- **Employees** cannot arbitrarily change asset statuses. They must request a transfer, return, or maintenance ticket.
- **Auditors** cannot freely browse all assets; they can only read the assets specifically assigned to their `audit_cycles`.
- **Technicians** cannot assign tickets to themselves. `Asset Managers` or `Admins` assign tickets. Once assigned, technicians can update and resolve their tickets.
- **Admins** cannot demote or deactivate the last active Admin of an organization to prevent lockouts.
