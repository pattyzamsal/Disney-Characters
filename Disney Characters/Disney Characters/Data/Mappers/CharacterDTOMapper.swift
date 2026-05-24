/// Transforms Data layer DTOs into Domain layer models.
///
/// **Why an enum?**
/// A caseless enum is the most precise Swift construct for a pure stateless namespace.
/// It cannot be instantiated — `CharacterDTOMapper()` does not compile — which makes
/// the intent explicit: these are pure functions, not objects with lifecycle or state.
/// A `class` or `struct` would allow pointless instantiation and signal the wrong thing
/// to the reader.
///
/// **Why a dedicated mapper instead of a `toDomain()` extension on the DTO?**
/// DTOs have one responsibility: decoding JSON (`Decodable`). Adding domain mapping to
/// them would mean a DTO knows about Domain types, blurring the boundary between layers.
/// Keeping the mapper separate preserves that boundary — the DTO stays a dumb data
/// container, and all transformation logic lives in one predictable place.
///
/// **Why this matters as the app grows**
/// As the API evolves, response fields change: some become optional, some are renamed,
/// new fields are added. All of that complexity is absorbed here, in one file, without
/// touching the Domain model or the Views. The Domain layer stays stable and the rest
/// of the app is insulated from API churn. This mapper is also the easiest type to
/// unit test — pure input/output, no mocks, no async — so regressions are caught
/// immediately when a mapping rule changes.
enum CharacterDTOMapper {
    static func toDomain(_ dto: CharacterDTO) -> Character {
        Character(
            id: dto.id,
            name: dto.name,
            imageURL: dto.imageUrl,
            films: dto.films,
            shortFilms: dto.shortFilms,
            tvShows: dto.tvShows,
            videoGames: dto.videoGames,
            parkAttractions: dto.parkAttractions,
            allies: dto.allies,
            enemies: dto.enemies
        )
    }

    static func toDomain(_ dto: PaginationInfoDTO) -> PaginationInfo {
        PaginationInfo(
            totalPages: dto.totalPages,
            count: dto.count,
            previousPage: dto.previousPage,
            nextPage: dto.nextPage
        )
    }
}
