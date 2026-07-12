# Authentication & Organization Modules Documentation

## 1. Authentication Module

The Authentication module handles user identity and session management. It strictly adheres to Clean Architecture principles, ensuring a separation of concerns across Data, Domain, and Presentation layers.

### Key Entities
- **AuthenticatedUser**: Represents the current logged-in user, storing their ID, full name, email, role, department name, and active status.
- **AuthRole**: Defines user permission levels (`employee`, `departmentHead`, `assetManager`, `admin`).

### Security Rule Enforcements
- **Employee-Only Signups**: The `SignupEmployee` use case only accepts standard user details (name, email, password, department) and automatically assigns the `AuthRole.employee` role. It does not accept role assignments during signup. Elevated roles must be assigned post-signup by an administrator.

### Data Source
- **MockAuthDataSource**: Serves as the in-memory data provider, maintaining a list of mock users. Simulates network latency and implements logical checks for authentication (e.g., matching credentials, verifying account active status).

### Presentation
- Uses `ChangeNotifier` (`AuthController`) for state management.
- Reusable UI components like `AuthTextField`, `PasswordField`, and `AuthFormContainer` maintain design consistency.
- Features Login, Signup, and Forgot Password screens.

---

## 2. Organization Setup Module

The Organization Setup module provides a central dashboard for administrators to manage departments, asset categories, and the employee directory.

### Key Entities
- **Department**: Hierarchical organizational units with self-referencing relationships (parent/child) and designated heads.
- **AssetCategory**: Classifications for assets (e.g., Electronics, Furniture) defining default parameters like warranty periods.
- **Employee**: Represents staff members linked to departments and assigned system roles.
- **RecordStatus**: Centralized active/inactive status flag for soft deletes.

### Use Cases
Use cases provide fine-grained operations, including retrieving lists, saving entities, and updating specific properties (e.g., `UpdateEmployeeRole`, `UpdateEmployeeStatus`).

### Data Source
- **MockOrganizationDataSource**: In-memory data store with pre-populated hierarchical departments, categorized asset types, and a diverse set of employees.
- Implements safety checks (e.g., preventing a department from being its own parent, ensuring at least one active administrator remains when updating roles/statuses).

### Presentation
- Uses `ChangeNotifier` (`OrganizationController`) for state and complex filtering logic.
- The UI is divided into three tabs:
  1. **Departments**: Data table with hierarchical viewing and add/edit forms.
  2. **Asset Categories**: Management of asset types.
  3. **Employee Directory**: Centralized management of staff with quick-action dialogs for changing roles, reassigning departments, and toggling active status.
- Reusable `OrganizationFilterBar` provides real-time client-side search and filtering across all tabs.

## 3. Implementation Notes
- Both modules use Dart's standard `ChangeNotifier` and `ListenableBuilder` (Flutter SDK tools) to eliminate external state-management dependencies.
- The UI conforms to the application's central `AppTheme`, utilizing `ColorScheme.fromSeed` and standard breakpoints for responsiveness.
- Repositories (`AuthRepository`, `OrganizationRepository`) use abstract domain interfaces with concrete implementations mapped to mock data sources, ready for drop-in replacement with real Supabase/API data sources in the future.
