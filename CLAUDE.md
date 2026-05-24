# DisneyCharacters iOS App

## Project Overview
Native iOS application built with SwiftUI that consumes the Disney API (https://api.disneyapi.dev) to browse, search, and view Disney character details. Follows Clean Architecture, MVVM, SOLID principles, and modern Swift concurrency.

## Tech Stack
- **Language:** Swift 6.0+
- **UI:** SwiftUI
- **Min Target:** iOS 17.0
- **Build:** Xcode 16+
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
│       └── DependencyContainer.swift      # DI registration
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
│       └── AppRouter.swift                # NavigationStack coordinator
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
    │       │   └── CharacterPresentationMapperTests.swift
    │       └── ViewModels/
    │           ├── CharacterListViewModelTests.swift
    │           └── CharacterDetailViewModelTests.swift
    ├── Mocks/
    │   ├── Generated/                     # Sourcery auto-generated mocks
    │   └── AutoMockable.swift             # Sourcery protocol annotation
    └── Fixtures/
        └── character_list_response.json   # stub JSON for tests

UITests/                                   # DisneyCharactersUITests target
└── SnapshotTests/
    ├── SplashViewSnapshotTests.swift
    ├── CharacterListViewSnapshotTests.swift
    ├── CharacterRowViewSnapshotTests.swift
    └── CharacterDetailViewSnapshotTests.swift
```

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
      case error(String)
  }
  ```

### Clean Architecture Rules
- **Domain layer has ZERO imports** from Data or Presentation
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
      func execute(page: Int) async throws -> (characters: [Character], info: PaginationInfo)
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
  - `searchCharacters(name:)` — filters local cache first; falls back to remote only if cache has no match; merges remote results into cache

### Mappers
- **DTO → Domain:** `CharacterDTOMapper.toDomain(_ dto: CharacterDTO) -> Character`
- **Domain → Presentation:** `CharacterPresentationMapper.toPresentation(_ character: Character) -> CharacterPresentationModel`
- Mappers are static functions or static structs — no state
- Handle optional/missing API fields gracefully in DTO mapper with defaults

### Dependency Injection
- Use a lightweight DI container (manual registration, no third-party DI frameworks)
- Register protocols to concrete types
- Inject via initializer injection — never property injection or service locator in Views
- Container created at app launch, passed through environment or init chain

### Error Handling
- Network layer throws `NetworkError` (enum: `.invalidURL`, `.noData`, `.decodingError`, `.serverError(statusCode:)`, `.noConnection`, `.timeout`, `.unknown`)
- Domain maps to `DomainError` (enum: `.characterNotFound`, `.noInternetConnection`, `.networkFailure(String)`, `.unexpected`)
  - `.noInternetConnection` — device has no connectivity; maps from `NetworkError.noConnection`; show "Check your connection" UI
  - `.networkFailure(String)` — device reached the server but something failed (timeout, bad status, decoding); show "Something went wrong, try again" UI
- ViewModels catch errors and map to user-friendly localized strings
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
- **Local-first strategy:** filter cached characters by name first
- **Remote fallback:** if local cache has no match, call `GET /character?name=<query>`
- Merge remote results into local cache to avoid duplicate API calls
- Clear search restores the original paginated list

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
  - DisneyCharacters
excluded:
  - DisneyCharacters/Tests/Mocks/Generated
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
- Run Sourcery: `sourcery --sources DisneyCharacters --templates Templates/AutoMockable.stencil --output DisneyCharacters/Tests/Mocks/Generated`
- Generated mocks go in `Tests/Mocks/Generated/` — never edit manually
- Always regenerate after protocol changes

### Snapshot Tests
- Live in the **UITests target** (`DisneyCharactersUITests/SnapshotTests/`), not the unit test target — snapshot tests render real views and are UI-bound
- Use `swift-snapshot-testing` by Point-Free (SPM)
- Test all Views and reusable components
- Test in light and dark mode
- Test with Dynamic Type sizes (`.accessibilityExtraExtraExtraLarge`)
- Test in multiple device widths (iPhone SE, iPhone 16, iPad)
- Record snapshots first (`isRecording = true`), then assert
- Store reference images in `UITests/SnapshotTests/__Snapshots__/`

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
- Organize keys by screen: `splash.title`, `characterList.searchPlaceholder`, `error.networkFailure`

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
- Error state with retry button
- Pull-to-refresh support
- Search: local filter first → remote API fallback → merge into cache
- Accessibility: search bar labeled, each row labeled with character name

### 3. Character Detail View (`CharacterDetailView`)
- Large character image (Kingfisher)
- Character name as title
- Sections for: Films, Short Films, TV Shows, Video Games, Park Attractions, Allies, Enemies
- Each section only shown if data exists (non-empty array)
- Back navigation
- Accessibility: all sections labeled, image described

## Commands
- **Build:** `Cmd+B` in Xcode or `xcodebuild -scheme DisneyCharacters`
- **Run tests:** `Cmd+U` or `xcodebuild test -scheme DisneyCharacters -destination 'platform=iOS Simulator,name=iPhone 16'`
- **Lint:** `swiftlint --config .swiftlint.yml`
- **Generate mocks:** `sourcery --sources DisneyCharacters --templates Templates/AutoMockable.stencil --output DisneyCharacters/Tests/Mocks/Generated`
- **Record snapshots:** Set `isRecording = true` in snapshot test, run once, set back to `false`

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
