enum CharacterDTOMapper {
    static func toDomain(_ dto: CharacterDTO) -> DisneyCharacter {
        DisneyCharacter(
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
        PaginationInfo(hasNextPage: dto.nextPage != nil)
    }
}
