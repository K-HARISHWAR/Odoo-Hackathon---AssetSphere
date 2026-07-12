# AssetSphere - Dashboard & Asset Management Modules (Clean Architecture Refactor)

## Refactored Folder Structure
Following advanced **Clean Architecture** patterns:

```
lib/features/
├── assets/
│   ├── data/
│   │   ├── datasources/
│   │   │   └── assets_mock_datasource.dart      # Local/Mock Data Source
│   │   ├── models/
│   │   │   └── asset_model.dart                # JSON Mapping & DTOs
│   │   └── repositories/
│   │       └── asset_repository_impl.dart      # Repository implementation
│   ├── domain/
│   │   ├── entities/                           # Pure Business Entities
│   │   ├── repositories/                       # Repository Interfaces
│   │   └── usecases/                           # Application Logic
│   │       ├── add_asset_usecase.dart
│   │       └── get_assets_usecase.dart
│   └── presentation/                           # UI Layer
└── dashboard/
    ├── data/
    │   ├── datasources/
    │   │   └── dashboard_mock_datasource.dart
    │   ├── models/
    │   │   └── dashboard_kpi_model.dart
    │   └── repositories/
    │       └── dashboard_repository_impl.dart
    ├── domain/
    │   ├── entities/
    │   ├── repositories/
    │   └── usecases/
    │       └── get_dashboard_data_usecase.dart
    └── presentation/
```

## Architectural Implementation
1.  **Domain Layer**: Contains pure Dart classes (Entities, Repository Interfaces, Use Cases).
2.  **Data Layer**: Handles data retrieval from the `DataSource` (Mock), mapping JSON/Data to `Models` and then to `Entities`.
3.  **Presentation Layer**: UI widgets and `Controllers`.
    *   *State Management*: Manual Dependency Injection via constructors to keep the project package-free (no GetIt/BLoC as per initial constraints).
    *   *Controllers*: Use `ChangeNotifier` to manage UI state.

## Best Practices Followed
*   **Layer Separation**: Business logic is encapsulated in `UseCases`.
*   **Model-Entity Separation**: `AssetModel` handles JSON serialization, while `Asset` remains a pure entity.
*   **Dependency Inversion**: Controllers depend on `UseCases`, which depend on `Repository` interfaces.
*   **Mocking**: Data sources simulate backend latency for realistic UI testing.

## Integration Points for Developer 1
*   **Authentication**: Wrap use cases with session check logic.
*   **Remote Data**: Implement a `SupabaseAssetsDataSource` to replace the `AssetsMockDataSource` in the Repository implementation.
*   **Routing**: The `Pages` are modular and can be easily registered with a central router.
