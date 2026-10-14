import Foundation
import Testing
@testable import mangoaudioplayer

struct AudioTrackMapperTests {
    @Test func mapsTrackDTOToDomainTrack() {
        let id = UUID(uuidString: "11111111-2222-3333-4444-555555555555")!
        let dto = AudioTrackDTO(
            id: id,
            name: "Night Drive",
            streamingUrl: "https://audio.example/track.mp3",
            thumbnailUrl: "https://audio.example/cover.jpg",
            audioMetadataUrl: "https://audio.example/metadata"
        )

        let track = TrackMapper().map(dto: dto)

        #expect(track.id == id)
        #expect(track.name == "Night Drive")
        #expect(track.streamingUrl == "https://audio.example/track.mp3")
        #expect(track.thumbnailUrl == "https://audio.example/cover.jpg")
        #expect(track.audioMetadataUrl == "https://audio.example/metadata")
    }

    @Test func mapsLyricDTOUsingRequestedTrackID() {
        let lyricId = UUID(uuidString: "aaaaaaaa-bbbb-cccc-dddd-eeeeeeeeeeee")!
        let requestedTrackId = UUID(uuidString: "11111111-2222-3333-4444-555555555555")!
        let dto = AudioLyricDTO(id: lyricId, trackId: UUID(), content: "First line\nSecond line")

        let lyric = TrackLyricMapper().map(dto: dto, for: requestedTrackId)

        #expect(lyric.id == lyricId)
        #expect(lyric.trackId == requestedTrackId)
        #expect(lyric.content == "First line\nSecond line")
    }

    @Test func mapsMetadataDTOUsingRequestedTrackID() {
        let metadataId = UUID(uuidString: "aaaaaaaa-bbbb-cccc-dddd-eeeeeeeeeeee")!
        let requestedTrackId = UUID(uuidString: "11111111-2222-3333-4444-555555555555")!
        let releaseDay = Date(timeIntervalSince1970: 1_700_000_000)
        let createdAt = Date(timeIntervalSince1970: 1_700_000_060)
        let dto = AudioTrackMetadataDTO(
            id: metadataId,
            trackID: UUID(),
            author: "A. Artist",
            releaseDay: releaseDay,
            isSubtitleSupport: true,
            isFavorite: true,
            created_at: createdAt
        )

        let metadata = TrackMetadataMapper().map(dto: dto, for: requestedTrackId)

        #expect(metadata.id == metadataId)
        #expect(metadata.trackID == requestedTrackId)
        #expect(metadata.author == "A. Artist")
        #expect(metadata.releaseDay == releaseDay)
        #expect(metadata.isSubtitleSupport)
        #expect(metadata.isFavorite)
        #expect(metadata.created_at == createdAt)
    }
}
