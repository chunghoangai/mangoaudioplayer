import Foundation
import Testing
@testable import mangoaudioplayer

struct APIRequestBuilderTests {
    @Test func appliesEndpointPathAndMethodToBaseURL() throws {
        let builder = APIRequestBuilder(baseURL: URL(string: "https://api.example/root")!)

        let request = try builder.makeRequest(for: .audioTracks)

        #expect(request.url?.absoluteString == "https://api.example/root/audio/v1/tracks")
        #expect(request.httpMethod == "GET")
    }

    @Test func trackEndpointsIncludeTrackIDAndResourcePath() throws {
        let trackId = UUID(uuidString: "11111111-2222-3333-4444-555555555555")!
        let builder = APIRequestBuilder(baseURL: URL(string: "https://api.example")!)

        let metadataRequest = try builder.makeRequest(for: .trackMetadata(for: trackId))
        let lyricRequest = try builder.makeRequest(for: .fetchLyric(for: trackId))

        #expect(metadataRequest.url?.path == "/audio/v1/\(trackId.uuidString)/metadata")
        #expect(metadataRequest.httpMethod == "GET")
        #expect(lyricRequest.url?.path == "/audio/v1/\(trackId.uuidString)/lyric")
        #expect(lyricRequest.httpMethod == "GET")
    }
}
