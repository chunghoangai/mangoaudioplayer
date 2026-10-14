import Foundation

struct RemoteAudioRepository: AudioRepositoryProtocol {
	let requestBuilder = APIRequestBuilder(baseURL: URL(string: "http://localhost:3000")!)
	let httpClient: HttpClientProtocol
	let trackMapper: TrackMapperProtocol
	let metadataMapper: TrackMetadataMapperProtocol
	let trackLyricMapper: TrackLyricMapperProtocol
	init(
		httpClient: HttpClientProtocol, trackMapper: TrackMapperProtocol = TrackMapper(),
		metadataMapper: TrackMetadataMapperProtocol = TrackMetadataMapper(),
		trackLyricMapper: TrackLyricMapperProtocol = TrackLyricMapper()
	) {
		self.httpClient = httpClient
		self.trackMapper = trackMapper
		self.metadataMapper = metadataMapper
		self.trackLyricMapper = trackLyricMapper
	}

	func fetchAudios() async throws -> [AudioTrack] {
		let endpoint = Endpoint.audioTracks
		let request = try requestBuilder.makeRequest(for: endpoint)
		let response = try await httpClient.send(request)
		return try JSONDecoder().decode([AudioTrackDTO].self, from: response.data).map {
			return trackMapper.map(dto: $0)
		}
	}

	func fetchMetadata(for trackId: UUID) async throws -> AudioTrackMetadata {
		let endpoint = Endpoint.trackMetadata(for: trackId)
		let request = try requestBuilder.makeRequest(for: endpoint)
		let response = try await httpClient.send(request)
		let decoder = JSONDecoder()
		decoder.dateDecodingStrategy = .custom { decoder in
			let container = try decoder.singleValueContainer()
			let value = try container.decode(String.self)
			let formatter = ISO8601DateFormatter()
			formatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
			if let date = formatter.date(from: value) {
				return date
			}
			formatter.formatOptions = [.withInternetDateTime]
			if let date = formatter.date(from: value) {
				return date
			}
			throw DecodingError.dataCorruptedError(
				in: container,
				debugDescription: "Expected an ISO 8601 date string, optionally with fractional seconds."
			)
		}
		let dtoMetadataObject = try decoder.decode(
			AudioTrackMetadataDTO.self, from: response.data)
		return metadataMapper.map(dto: dtoMetadataObject, for: trackId)
	}

	func fetchLyric(for trackId: UUID) async throws -> AudioLyric {
		let endpoint = Endpoint.fetchLyric(for: trackId)
		let request = try requestBuilder.makeRequest(for: endpoint)
		let response = try await httpClient.send(request)
		let dtoMetadataObject = try JSONDecoder().decode(
			AudioLyricDTO.self, from: response.data)
		return trackLyricMapper.map(dto: dtoMetadataObject, for: trackId)
	}

}
