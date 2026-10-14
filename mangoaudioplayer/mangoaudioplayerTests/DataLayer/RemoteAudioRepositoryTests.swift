import Foundation
import Testing
@testable import mangoaudioplayer

struct RemoteAudioRepositoryTests {
    @Test func fetchAudiosSendsTrackRequestAndMapsResponse() async throws {
        let trackId = UUID(uuidString: "11111111-2222-3333-4444-555555555555")!
        let body = #"[{"id":"11111111-2222-3333-4444-555555555555","name":"Night Drive","streamingUrl":"https://audio.example/track.mp3","thumbnailUrl":"https://audio.example/cover.jpg","audioMetadataUrl":"https://audio.example/metadata"}]"#
        let client = StubHttpClient(responseBody: Data(body.utf8))
        let repository = RemoteAudioRepository(httpClient: client)

        let tracks = try await repository.fetchAudios()

        #expect(client.requests.count == 1)
        #expect(client.requests[0].url?.path == "/audio/v1/tracks")
        #expect(client.requests[0].httpMethod == "GET")
        #expect(tracks.count == 1)
        #expect(tracks[0].id == trackId)
        #expect(tracks[0].name == "Night Drive")
    }

    @Test func fetchMetadataPassesRequestedTrackIDToDomainModel() async throws {
        let trackId = UUID(uuidString: "11111111-2222-3333-4444-555555555555")!
        let metadataId = UUID(uuidString: "aaaaaaaa-bbbb-cccc-dddd-eeeeeeeeeeee")!
        let body = #"{"id":"aaaaaaaa-bbbb-cccc-dddd-eeeeeeeeeeee","trackID":"99999999-2222-3333-4444-555555555555","author":"A. Artist","releaseDay":"2024-01-01T00:00:00.000Z","isSubtitleSupport":true,"isFavorite":true,"created_at":"2024-01-01T00:01:00.000Z"}"#
        let client = StubHttpClient(responseBody: Data(body.utf8))
        let repository = RemoteAudioRepository(httpClient: client)

        let metadata = try await repository.fetchMetadata(for: trackId)

        #expect(client.requests[0].url?.path == "/audio/v1/\(trackId.uuidString)/metadata")
        #expect(metadata.id == metadataId)
        #expect(metadata.trackID == trackId)
        #expect(metadata.author == "A. Artist")
        #expect(metadata.isSubtitleSupport)
        #expect(metadata.isFavorite)
    }

    @Test func fetchLyricPassesRequestedTrackIDToDomainModel() async throws {
        let trackId = UUID(uuidString: "11111111-2222-3333-4444-555555555555")!
        let lyricId = UUID(uuidString: "aaaaaaaa-bbbb-cccc-dddd-eeeeeeeeeeee")!
        let body = #"{"id":"aaaaaaaa-bbbb-cccc-dddd-eeeeeeeeeeee","trackId":"99999999-2222-3333-4444-555555555555","content":"First line\nSecond line"}"#
        let client = StubHttpClient(responseBody: Data(body.utf8))
        let repository = RemoteAudioRepository(httpClient: client)

        let lyric = try await repository.fetchLyric(for: trackId)

        #expect(client.requests[0].url?.path == "/audio/v1/\(trackId.uuidString)/lyric")
        #expect(lyric.id == lyricId)
        #expect(lyric.trackId == trackId)
        #expect(lyric.content == "First line\nSecond line")
    }

    @Test func propagatesHTTPClientFailure() async {
        let repository = RemoteAudioRepository(httpClient: StubHttpClient(error: StubHttpClientError.offline))

        await #expect(throws: StubHttpClientError.offline) {
            try await repository.fetchAudios()
        }
    }

    @Test func throwsWhenResponsePayloadIsInvalid() async {
        let client = StubHttpClient(responseBody: Data("{}".utf8))
        let repository = RemoteAudioRepository(httpClient: client)

        await #expect(throws: DecodingError.self) {
            try await repository.fetchAudios()
        }
    }
}

private enum StubHttpClientError: Error, Equatable {
    case offline
}

private final class StubHttpClient: HttpClientProtocol {
    private let responseBody: Data
    private let error: StubHttpClientError?
    private(set) var requests: [URLRequest] = []

    init(responseBody: Data) {
        self.responseBody = responseBody
        self.error = nil
    }

    init(error: StubHttpClientError) {
        self.responseBody = Data()
        self.error = error
    }

    func send(_ request: URLRequest) async throws -> HTTPClientResponse {
        requests.append(request)
        if let error {
            throw error
        }
        return HTTPClientResponse(data: responseBody, statusCode: 200, headers: [:])
    }
}
