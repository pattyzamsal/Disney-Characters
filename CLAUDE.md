# DisneyCharacters iOS App

## Project Overview
Native iOS application built with SwiftUI that consumes the Disney API (https://api.disneyapi.dev) to browse, search, and view Disney character details. Follows Clean Architecture, MVVM, SOLID principles, and modern Swift concurrency.

## Tech Stack
- **Language:** Swift 6.0+
- **UI:** SwiftUI
- **Min Target:** iOS 26.2
- **Build:** Xcode 26.2+
- **Dependency Manager:** Swift Package Manager (SPM)
- **Linting:** SwiftLint
- **Mocking:** Sourcery
- **Testing:** Swift Testing (`import Testing`), swift-snapshot-testing
- **Image Loading:** Kingfisher (via SPM)

## API Reference
- Base URL: stored in `.xcconfig`, never hardcoded
- `GET /character` — paginated list (50/page), query params: `page`, `pageSize`
- `GET /character/:id` — single character detail
- `GET /character?name=<query>` — filter by name
- No authentication required
- Response shape: `{ "info": { "totalPages", "count", "previousPage", "nextPage" }, "data": [...] }`

## Architecture: Clean Architecture + MVVM

### Layer Diagram
```
┌─────────────────────────────────────────────────────┐
│                  Presentation Layer                  │
│  Views (SwiftUI) ←→ ViewModels ←→ PresentationModels│
│                                                     │
│  Mappers: Domain → Presentation                     │
├─────────────────────────────────────────────────────┤
│                    Domain Layer                      │
│  UseCases ← Protocols (RepositoryContracts)         │
│  Domain Models (entities)                           │
│                                                     │
│  NO dependencies on Data or Presentation            │
├─────────────────────────────────────────────────────┤
│                     Data Layer                       │
│  Repositories (implementations) → DataSources       │
│  DTOs (API response models, Decodable)              │
│                                                     │
│  Mappers: DTO → Domain                              │
├─────────────────────────────────────────────────────┤
│                     Core / DI                        │
│  DI Container, Extensions, Networking, Config        │
└─────────────────────────────────────────────────────┘
```

### Folder Structure
```
DisneyCharacters/
├── App/
│   ├── DisneyCharactersApp.swift          # @main entry point
│   ├── AppDelegate.swift                  # if needed
│   └── DI/
│       └── DependencyContainer.swift      # registers shared long-lived dependencies (repositories)
│
├── Core/
│   ├── Network/
│   │   ├── HTTPClient.swift               # protocol
│   │   ├── URLSessionHTTPClient.swift     # implementation
│   │   ├── Endpoint.swift                 # endpoint builder
│   │   ├── HTTPMethod.swift
│   │   └── NetworkError.swift             # typed error enum
│   ├── Configuration/
│   │   ├── Environment.swift              # reads from xcconfig
│   │   └── AppConfiguration.swift
│   ├── Extensions/
│   │   └── (Swift extensions)
│   └── Accessibility/
│       └── AccessibilityIdentifiers.swift # centralized identifiers
│
├── Data/
│   ├── DTOs/
│   │   ├── CharacterDTO.swift             # Decodable, matches API JSON: _id, name, imageUrl, films, shortFilms, tvShows, videoGames, parkAttractions, allies, enemies, url (url dropped in mapper)
│   │   ├── CharacterListResponseDTO.swift # { info: PaginationInfoDTO, data: [CharacterDTO] }
│   │   ├── CharacterDetailResponseDTO.swift # { info: PaginationInfoDTO, data: CharacterDTO } — detail endpoint returns single object, not array
│   │   └── PaginationInfoDTO.swift
│   ├── DataSources/
│   │   ├── Remote/
│   │   │   └── CharacterRemoteDataSource.swift
│   │   └── Local/
│   │       └── CharacterLocalDataSource.swift  # CharacterLocalDataSourceProtocol + impl; caches characters, pages, and PaginationInfo per page
│   ├── Repositories/
│   │   └── DefaultCharacterRepository.swift    # implements domain protocol
│   └── Mappers/
│       └── CharacterDTOMapper.swift            # DTO → Domain (maps all fields; drops url — not a domain concept)
│
├── Domain/
│   ├── Entities/
│   │   ├── DisneyCharacter.swift          # domain model (struct): id, name, imageURL, films, shortFilms, tvShows, videoGames, parkAttractions, allies, enemies
│   │   └── PaginationInfo.swift
│   ├── Repositories/
│   │   └── CharacterRepositoryProtocol.swift   # contract
│   ├── UseCases/
│   │   ├── GetCharactersUseCase.swift
│   │   ├── GetCharacterDetailUseCase.swift
│   │   └── SearchCharactersUseCase.swift
│   └── Errors/
│       └── DomainError.swift
│
├── Presentation/
│   ├── Models/
│   │   ├── CharacterPresentationModel.swift
│   │   └── CharacterDetailPresentationModel.swift
│   ├── Mappers/
│   │   ├── CharacterPresentationMapper.swift   # Domain → Presentation
│   │   └── CharacterDetailPresentationMapper.swift
│   ├── Splash/
│   │   ├── SplashView.swift
│   │   └── SplashViewModel.swift
│   ├── CharacterList/
│   │   ├── CharacterListAssembler.swift   # builds CharacterListView + ViewModel; receives container + router
│   │   ├── CharacterListView.swift
│   │   ├── CharacterListViewModel.swift
│   │   └── Components/
│   │       ├── CharacterRowView.swift
│   │       └── SearchBarView.swift
│   ├── CharacterDetail/
│   │   ├── CharacterDetailView.swift
│   │   └── CharacterDetailViewModel.swift
│   ├── Common/
│   │   ├── ViewState.swift                # generic ViewState<T> enum
│   │   ├── ErrorView.swift                # reusable error + retry
│   │   └── LoadingView.swift              # reusable loading indicator
│   └── Navigation/
│       └── AppRouter.swift                # AppRoute enum + @Observable AppRouter with NavigationPath
│
├── Resources/
│   ├── Assets.xcassets/
│   └── Localizable.xcstrings              # string catalog for localization
│
├── Configuration/
│   ├── Dev.xcconfig
│   ├── Staging.xcconfig
│   └── Prod.xcconfig
│
└── Tests/                                 # DisneyCharactersTests target
    ├── UnitTests/
    │   ├── Data/
    │   │   ├── Mappers/
    │   │   │   └── CharacterDTOMapperTests.swift
    │   │   └── Repositories/
    │   │       └── DefaultCharacterRepositoryTests.swift
    │   ├── Domain/
    │   │   └── UseCases/
    │   │       ├── GetCharactersUseCaseTests.swift
    │   │       ├── GetCharacterDetailUseCaseTests.swift
    │   │       └── SearchCharactersUseCaseTests.swift
    │   └── Presentation/
    │       ├── Mappers/
    │       │   ├── CharacterPresentationMapperTests.swift
    │       │   └── CharacterDetailPresentationMapperTests.swift
    │       └── ViewModels/
    │           ├── CharacterListViewModelTests.swift
    │           └── CharacterDetailViewModelTests.swift
    ├── Mocks/
    │   ├── Generated/                     # Sourcery auto-generated mocks
    │   └── AutoMockable.swift             # Sourcery protocol annotation
    ├── Stubs/                             # one file per type: TypeName+Stub.swift
    │   ├── CharacterDTO+Stub.swift
    │   ├── CharacterListResponseDTO+Stub.swift
    │   ├── DisneyCharacter+Stub.swift
    │   ├── PaginationInfo+Stub.swift
    │   └── PaginationInfoDTO+Stub.swift
    ├── SnapshotTests/                     # snapshot tests (NOT in UITests — see Snapshot Tests section)
    │   ├── SplashViewSnapshotTests.swift
    │   ├── CharacterListViewSnapshotTests.swift
    │   ├── CharacterRowViewSnapshotTests.swift
    │   └── CharacterDetailViewSnapshotTests.swift
    └── Fixtures/
        └── character_list_response.json   # stub JSON for tests

UITests/                                   # DisneyCharactersUITests target
    ├── DisneyCharactersUITests.swift          # 5 smoke tests (Splash → List → Detail → back)
    └── DisneyCharactersUITestsLaunchTests.swift  # launch screenshot in all UI configurations
```

Note: Snapshot tests live in `DisneyCharactersTests/SnapshotTests/` (unit test target), not UITests.
See the Snapshot Tests section under Testing for the reason.

## Coding Conventions

### General Swift Rules
- Use `struct` over `class` for models and value types
- Use `final class` when class is required (ViewModels)
- Prefer `let` over `var`; mutability only when necessary
- Use `private` access control by default; expose only what is needed
- No force unwraps (`!`) except `fatalError` in DI container for missing registrations
- No force try (`try!`) — always handle errors
- Mark all protocol conformances in extensions
- One type per file; filename matches type name

### Naming Conventions
- **Protocols:** suffix with describing role — `CharacterRepositoryProtocol`, `HTTPClient`
- **UseCases:** verb + noun — `GetCharactersUseCase`, `SearchCharactersUseCase`
- **ViewModels:** screen name + `ViewModel` — `CharacterListViewModel`
- **DTOs:** model name + `DTO` — `CharacterDTO`
- **Mappers:** source + `Mapper` — `CharacterDTOMapper`, `CharacterPresentationMapper`
- **Views:** screen name + `View` — `CharacterListView`
- **Tests:** tested type + `Tests` — `CharacterListViewModelTests`

### SwiftUI Conventions
- Extract reusable components into separate files under `Components/`
- Use `@Observable` macro (iOS 17+ Observation framework) for ViewModels
- Inject ViewModels via initializer — never create inside View body
- Use `task {}` modifier for async data loading, not `onAppear`
- Prefer `LazyVStack` inside `ScrollView` for large lists
- Always add `.accessibilityLabel()`, `.accessibilityHint()`, `.accessibilityIdentifier()`
- Use SF Symbols via `Image(systemName:)` — never bundle icon PNGs when SF Symbol exists
- Support Dynamic Type — never use fixed font sizes, use `.font(.title)`, `.font(.body)`, etc.
- Use `Localizable.xcstrings` (String Catalogs) for every user-facing string

### View File Structure
Every View follows this structure — `body` only composes named subview properties; all constants and visual chunks live in a `private extension`:

```swift
struct MyView: View {
    var body: some View {
        topSection
        bottomSection
    }
}

private extension MyView {
    // Only include the enums that are actually needed:
    enum AccessibilityContent {
        static let someLabel: LocalizedStringKey = "screen.element.label"
        static let someHint: LocalizedStringKey  = "screen.element.hint"
    }
    enum Content {
        static let title: LocalizedStringKey = "screen.title"
    }
    enum Constant {
        static let spacing: CGFloat = 16
    }
    enum ImageName {
        static let icon = "sf.symbol.name"
    }

    var topSection: some View { ... }
    var bottomSection: some View { ... }
}
```

This keeps `body` readable at a glance, eliminates magic strings and numbers, and groups each visual responsibility in its own named property.

Previews are always wrapped in `#if DEBUG` so they are stripped from Release and Staging builds:

```swift
#if DEBUG
#Preview {
    MyView(viewModel: MyViewModel(...))
}
#endif
```

### MVVM Rules
- Views observe ViewModels. Views NEVER call UseCases or Repositories directly
- ViewModels call UseCases only. ViewModels NEVER import Data layer types
- ViewModels expose state using `@Observable` macro
- ViewModels handle mapping Domain → Presentation via Mapper
- ViewModels manage loading, error, and success states via a `ViewState` enum:
  ```swift
  enum ViewState<T> {
      case idle
      case loading
      case loaded(T)
      case error(String, isRetryable: Bool)
  }

  extension ViewState: Equatable where T: Equatable {}
  ```
- `isRetryable: false` — errors where retrying immediately makes no sense (no internet, character not found); `ErrorView` hides the retry button
- `isRetryable: true` — transient errors the user can recover from (network failure, unexpected); `ErrorView` shows the retry button
- Always catch `CancellationError` separately in ViewModel async methods and return silently — do not set error state on cancellation

### Clean Architecture Rules
- **Domain layer has ZERO imports** from Data or Presentation
- **Domain entities do not import Foundation** unless they explicitly use a Foundation type (URL, Date, etc.) — pure Swift stdlib types (Int, String, [String]) need no import. Unnecessary Foundation imports can cause spurious `@MainActor` isolation warnings in Swift 6
- **Data layer** implements Domain protocols; depends on Domain only
- **Presentation layer** depends on Domain only (through UseCases)
- All cross-layer data flow goes through Mappers — never pass DTOs to Views
- Dependency direction: Presentation → Domain ← Data

### UseCases
- Each UseCase has a single `execute()` method
- UseCase protocol + concrete implementation
- Always async throws:
  ```swift
  protocol GetCharactersUseCaseProtocol {
      func execute(page: Int) async throws -> (characters: [DisneyCharacter], info: PaginationInfo)
  }
  ```

### Repository Pattern
- Domain defines the protocol (contract)
- Data provides the implementation
- Repository decides data source (remote vs local cache)
- Both data sources are injected via protocol — fully mockable and consistent
- **Cache-first strategy (offline support):**
  - `getCharacters(page:)` — returns cached characters + PaginationInfo if available; fetches remote otherwise and caches both
  - `getCharacterDetail(id:)` — returns cached character if available; fetches remote otherwise
  - `searchCharacters(name:)` — always calls remote API; merges results into cache (local cache cannot guarantee exhaustive results across all API pages)

### Mappers
- **DTO → Domain:** `CharacterDTOMapper.toDomain(_ dto: CharacterDTO) -> DisneyCharacter`
- **Domain → Presentation:** `CharacterPresentationMapper.toPresentation(_ character: DisneyCharacter) -> CharacterPresentationModel`
- Mappers are **caseless enums** — prevents instantiation, signals a pure stateless namespace. Never use `class` or `struct` for mappers
- `CharacterPresentationMapper` and `CharacterDetailPresentationMapper` convert `imageURL: String?` → `imageURL: URL?` via `URL.init(string:)` (returns nil for invalid strings)
- Handle optional/missing API fields gracefully in DTO mapper with defaults

### Dependency Injection
- Use a lightweight DI container (manual registration, no third-party DI frameworks)
- `DependencyContainer` holds shared, long-lived dependencies (e.g., `characterRepository`) — one instance per app lifetime, created at app launch; lives in `App/DI/`
- **Assemblers** (caseless enums, one per screen) receive the container + router and build the ViewModel + View for a route — keeps `DisneyCharactersApp` thin
  ```swift
  enum CharacterListAssembler {
      static func make(container: DependencyContainer, router: AppRouter) -> some View { ... }
  }
  ```
- Assemblers live **inside their feature folder** (e.g., `Presentation/CharacterList/CharacterListAssembler.swift`), not in `App/DI/` — see Architecture Decisions
- Inject via initializer injection — never property injection or service locator in Views
- Add a new assembler whenever a new route is wired in `DisneyCharactersApp`

### Error Handling
- Network layer throws `NetworkError` (enum: `.invalidURL`, `.noData`, `.decodingError`, `.serverError(statusCode:)`, `.noConnection`, `.timeout`, `.unknown`)
- Domain maps to `DomainError` (enum: `.characterNotFound`, `.noInternetConnection`, `.networkFailure(String)`, `.unexpected`)
  - `.noInternetConnection` — device has no connectivity; maps from `NetworkError.noConnection`; `isRetryable: false` — show "Check your connection" without retry button
  - `.networkFailure(String)` — device reached the server but something failed (timeout, bad status, decoding); `isRetryable: true` — show "Something went wrong, try again" with retry button
  - `.characterNotFound` — resource does not exist (404); `isRetryable: false` — retrying the same request will not help
  - `.unexpected` — unknown error; `isRetryable: true` — worth trying again
- ViewModels catch errors and map to user-friendly localized strings + `isRetryable` flag via `ViewState.error(String, isRetryable: Bool)`
- Always catch `CancellationError` before the generic `catch` block and return silently
- Never show raw error messages to users — always use localized strings

### Modern Concurrency (async/await)
- All network calls use `async throws`
- Use `URLSession.shared.data(for:)` — no completion handlers
- Use `Task {}` in ViewModels to bridge into async context
- Cancel tasks in ViewModel deinit or on view disappear using `task.cancel()`
- Use `@MainActor` on ViewModels to ensure UI updates on main thread
- Use `TaskGroup` only when parallel fetching is needed

### Search Implementation (List View)
- Search bar with debounce (500ms) using `Task` with `try await Task.sleep`
- **Always-remote:** call `GET /character?name=<query>` on every search — local cache only contains pages the user has scrolled through and cannot give exhaustive results
- Merge remote results into local cache after each search to warm subsequent detail fetches
- Clear search restores the original paginated list

## Architecture Decisions

### ADR-001: Assemblers live inside their feature folder, not in App/DI/

**Decision:** Each screen's assembler (e.g., `CharacterListAssembler`) lives in its own feature folder under `Presentation/` alongside the View and ViewModel it wires up.

**Rationale:** As the app grows, keeping all assemblers in a central `App/DI/` folder would create a bottleneck — every new screen would require touching that folder. Placing the assembler next to its feature means all files that belong to a screen (View, ViewModel, components, assembler) are in one place. This makes it easy to add, remove, or refactor a feature without navigating across unrelated folders.

**Rule:** `DependencyContainer` stays in `App/DI/` because it owns shared cross-feature dependencies. Assemblers are per-feature and travel with their feature.

---

## Security

### API Configuration via .xcconfig
- Store `API_BASE_URL` in `.xcconfig` files per environment:
  ```
  // Dev.xcconfig
  API_BASE_URL = https:/$()/api.disneyapi.dev
  ```
- Access via `Bundle.main.infoDictionary` in `Environment.swift`
- **Never hardcode URLs, keys, or secrets in Swift source files**
- Add `.xcconfig` to `.gitignore` if it contains sensitive data (for this project the API is public, but enforce the pattern)

### .gitignore Essentials
```
*.xcconfig           # only if contains secrets
Pods/
.build/
DerivedData/
*.generated.swift    # Sourcery output (regenerate via script)
```

## Linting: SwiftLint

### Installation
- Add SwiftLint via Homebrew (`brew install swiftlint`) or SPM plugin
- Add Run Script Build Phase: `swiftlint --config .swiftlint.yml`

### .swiftlint.yml (project root)
```yaml
included:
  - Disney Characters/DisneyCharacters
  - Disney Characters/DisneyCharactersTests
excluded:
  - Disney Characters/DisneyCharactersTests/Mocks/Generated
  - .build

disabled_rules:
  - trailing_whitespace

opt_in_rules:
  - empty_count
  - closure_spacing
  - contains_over_first_not_nil
  - discouraged_optional_boolean
  - explicit_init
  - fatal_error_message
  - first_where
  - force_unwrapping
  - implicitly_unwrapped_optional
  - modifier_order
  - overridden_super_call
  - private_action
  - private_outlet
  - unneeded_parentheses_in_closure_argument
  - vertical_whitespace_closing_braces

line_length:
  warning: 120
  error: 150

type_body_length:
  warning: 300
  error: 400

file_length:
  warning: 500
  error: 700

function_body_length:
  warning: 40
  error: 60

identifier_name:
  min_length: 2
  max_length: 50

nesting:
  type_level: 2

reporter: "xcode"
```

## Testing

### Unit Tests (Swift Testing framework)
- Import `import Testing`, NOT `XCTest`
- Use `@Test` attribute, `#expect()`, `#require()`
- Test each layer independently: Mapper → UseCase → ViewModel
- Mock all dependencies using Sourcery-generated mocks
- Test error cases and edge cases (empty list, nil image URL, network failure)
- Name tests descriptively: `@Test("Returns mapped characters for valid page")`

### Sourcery Mocks
- Annotate protocols: `// sourcery: AutoMockable`
- Generated mocks go in `Tests/Mocks/Generated/` — never edit manually
- **Mocks regenerate automatically** on every `DisneyCharactersTests` build via a `preBuildScripts` entry in `project.yml`. Sourcery must be installed locally (`brew install sourcery`, or `make install`); the build phase falls back to a warning if it isn't.
- Generated file (`AutoMockable.generated.swift`) is **gitignored** — it is a build artifact, not source.
- For manual regeneration (e.g., to inspect changes before building): `make mocks`
- **Nil return value gotcha:** Sourcery generates `var xReturnValue: T?!` for optional-returning methods. Setting this to bare `nil` crashes — the outer IUO becomes nil and force-unwraps. Use a typed nil instead:
  ```swift
  // Wrong — crashes at runtime
  mock.getCachedCharactersReturnValue = nil

  // Correct — IUO holds .some(nil), force-unwrap returns nil safely
  mock.getCachedCharactersReturnValue = [DisneyCharacter]?.none
  ```

### Test Stubs
- Live in `DisneyCharactersTests/Stubs/` — one file per type
- Naming convention: `TypeName+Stub.swift` (e.g. `DisneyCharacter+Stub.swift`)
- Each file adds a `static func stub(...)` extension with sensible defaults for every parameter
- Domain stubs: `DisneyCharacter+Stub.swift`, `PaginationInfo+Stub.swift`
- Data stubs: `CharacterDTO+Stub.swift`, `PaginationInfoDTO+Stub.swift`, `CharacterListResponseDTO+Stub.swift`
- Presentation stubs: `CharacterPresentationModel+Stub.swift`

### Test Plans
Test plans live in `TestPlans/` (project root) and are wired to the `DisneyCharactersTests` scheme. `UnitTests` is the default plan when pressing `Cmd+U`.

| Plan | Runs |
|------|------|
| `UnitTests.xctestplan` | All unit tests; skips snapshot classes |
| `SnapshotTests.xctestplan` | All snapshot tests; skips unit classes |
| `AllTests.xctestplan` | Everything |

Switch plans in Xcode via `Product → Test Plan`. From the command line:
```bash
xcodebuild test -scheme DisneyCharactersTests -testPlan UnitTests   -destination '...'
xcodebuild test -scheme DisneyCharactersTests -testPlan SnapshotTests -destination '...'
xcodebuild test -scheme DisneyCharactersTests -testPlan AllTests      -destination '...'
```

**Keeping plans in sync:** when adding a new snapshot test class, add its name to `skippedTests` in `UnitTests.xctestplan`. When adding a new unit test class, add it to `SnapshotTests.xctestplan`. `AllTests.xctestplan` never needs updating.

### Snapshot Tests
- Live in the **unit test target** (`DisneyCharactersTests/SnapshotTests/`), NOT in the UITests target
- Reason: Xcode 16 forces `-module-alias Testing=_Testing_Unavailable` for all `com.apple.product-type.bundle.ui-testing` bundles regardless of build settings; swift-snapshot-testing 1.17+ links against Testing.framework, making the two permanently incompatible
- Use `swift-snapshot-testing` by Point-Free (SPM)
- Test all Views and reusable components
- Test in light and dark mode
- Test with Dynamic Type sizes (`.accessibilityExtraExtraExtraLarge`)
- Test in multiple device widths (iPhone SE, iPhone 16, iPad)
- To re-record snapshots wrap the call in `withSnapshotTesting(record: .all) { assertSnapshot(...) }`, run once, then remove the wrapper. Never pass `record:` to `assertSnapshot` directly — the `Bool` overload is deprecated in swift-snapshot-testing 1.17+
- Store reference images in `DisneyCharactersTests/SnapshotTests/__Snapshots__/` — these PNGs **are committed** to the repo, so CI and fresh clones run green
- **Pinned recording environment:** always re-record on **iPhone 16 / iOS 26.2** simulator (`-destination 'platform=iOS Simulator,name=iPhone 16,OS=26.2'`). Different simulators or OS versions render text and gradients differently and will produce non-deterministic diffs
- **Test method names must be globally unique** across ALL snapshot test classes — Xcode copies reference PNGs flat into the test bundle (no subdirectory per class), so two classes with the same method name cause a "Multiple commands produce" build error. Use a class-specific prefix for ambiguous names (e.g. `test_row_accessibilityExtraExtraExtraLarge` instead of `test_accessibilityExtraExtraExtraLarge`)

## Accessibility

### Requirements for Every View
- Every interactive element has `.accessibilityLabel()`
- Images have `.accessibilityLabel()` describing content, or `.accessibilityHidden(true)` for decorative
- Use `.accessibilityHint()` for non-obvious actions
- Use `.accessibilityIdentifier()` with centralized constants for UI testing
- Group related elements with `.accessibilityElement(children: .combine)`
- Support VoiceOver navigation order with `.accessibilitySortPriority()`
- Support Dynamic Type — all text uses semantic font styles
- Ensure minimum 4.5:1 contrast ratio for text
- Support Bold Text system setting
- Support Reduce Motion — disable non-essential animations when enabled

### Centralized Identifiers
```swift
enum AccessibilityID {
    enum Splash {
        static let logo = "splash_logo"
        static let startButton = "splash_start_button"
    }
    enum CharacterList {
        static let searchBar = "character_list_search_bar"
        static let characterRow = "character_list_row_"
    }
    enum CharacterDetail {
        static let characterImage = "character_detail_image"
        static let characterName = "character_detail_name"
    }
}
```

## Localization

- Use String Catalogs (`Localizable.xcstrings`) — Xcode 15+ native format
- Default language: English
- Every user-facing string must use `String(localized:)` or `LocalizedStringKey`
- Never put raw strings in Views — always reference catalog keys
- String key constants in `Content` and `AccessibilityContent` enums **must be typed as `LocalizedStringKey`**, not `String` — SwiftUI only performs catalog lookup when `Text()` receives a `LocalizedStringKey`, not a plain `String` variable
- Organize keys by screen: `splash.title`, `characterList.searchPlaceholder`, `error.networkFailure`
- The `Localizable.xcstrings` catalog is the source of truth for all keys — do not maintain a duplicate list here

## SPM Dependencies

Add in Xcode > Project > Package Dependencies:
```
- Kingfisher: https://github.com/onevcat/Kingfisher — async image loading/caching
- swift-snapshot-testing: https://github.com/pointfreeco/swift-snapshot-testing — snapshot tests
- Sourcery: install via Homebrew (`brew install sourcery`) — mock generation CLI
```

## Views Specification

### 1. Splash View (`SplashView`)
- Centered Disney-themed logo/image from Assets
- Introductory text below image (localized)
- "Start" button — navigates to Character List
- No API calls on this screen
- Accessibility: image label, button label + hint

### 2. Character List View (`CharacterListView`)
- Search bar at top with debounced input (500ms)
- Scrollable list with pagination (load next page on scroll to bottom)
- Each row: character thumbnail (Kingfisher) + character name
- Loading indicator during fetch
- Empty state for no results
- Error state — retry button shown only for retryable errors (`.networkFailure`, `.unexpected`); hidden for `.noInternetConnection` and `.characterNotFound`
- Pull-to-refresh support
- Search: always calls remote API → merge into cache
- Accessibility: search bar labeled, each row labeled with character name

### 3. Character Detail View (`CharacterDetailView`)
- Large character image (Kingfisher)
- Character name as title
- Sections for: Films, Short Films, TV Shows, Video Games, Park Attractions, Allies, Enemies
- Each section only shown if data exists (non-empty array)
- Back navigation
- Accessibility: all sections labeled, image described

## Project Setup (first time)

The `.xcodeproj` is not committed — it is generated by [XcodeGen](https://github.com/yonaskolb/XcodeGen) from `Disney Characters/project.yml`.

```bash
# Clone the repo, then:
make install   # installs xcodegen + swiftlint + sourcery, then generates the project
make open      # opens Disney Characters/DisneyCharacters.xcodeproj in Xcode
```

After any change to `project.yml` (new target, new package, etc.) regenerate with:
```bash
make generate
```

## Commands
- **Build:** `Cmd+B` in Xcode or `xcodebuild -scheme DisneyCharacters`
- **Run all tests:** `Cmd+U` (uses `UnitTests` plan by default) or `xcodebuild test -scheme DisneyCharactersTests -testPlan AllTests -destination 'platform=iOS Simulator,name=iPhone 16'`
- **Run unit tests only:** `xcodebuild test -scheme DisneyCharactersTests -testPlan UnitTests -destination 'platform=iOS Simulator,name=iPhone 16'`
- **Run snapshot tests only:** `xcodebuild test -scheme DisneyCharactersTests -testPlan SnapshotTests -destination 'platform=iOS Simulator,name=iPhone 16'`
- **Lint:** `swiftlint --config .swiftlint.yml`
- **Generate mocks:** `sourcery --sources "Disney Characters/DisneyCharacters" --templates Templates/AutoMockable.stencil --output "Disney Characters/DisneyCharactersTests/Mocks/Generated"`
- **Record snapshots:** Wrap the call in `withSnapshotTesting(record: .all) { assertSnapshot(...) }`, run once, then remove the wrapper
- **Run smoke tests (UITests):** `xcodebuild test -scheme DisneyCharactersUITests -destination 'platform=iOS Simulator,name=iPhone 16,OS=26.2'`

## Git Conventions
- Branch naming: `feature/`, `bugfix/`, `refactor/`, `test/`
- Commit messages: conventional commits — `feat:`, `fix:`, `test:`, `refactor:`, `docs:`, `chore:`
- PR must pass: build, lint, all tests
- Never push directly to `main` — always use pull requests

## Avoid
- No `AnyView` type erasure — use `@ViewBuilder` or concrete types
- No Combine (use async/await and Observation framework instead)
- No third-party DI frameworks — keep DI manual and lightweight
- No storyboards or XIBs — SwiftUI only
- No singletons except DI container
- No god objects — if a file exceeds 300 lines, split it

## Key Principles Reminder
- Readable > Clever
- Testable > Convenient
- Explicit > Implicit
- Separation of concerns at every layer boundary
- When in doubt, add a protocol
