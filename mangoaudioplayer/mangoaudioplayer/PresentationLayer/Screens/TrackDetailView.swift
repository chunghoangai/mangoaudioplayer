import SwiftUI
import AVKit

struct TrackDetailView: View {
	let track: AudioTrack
	@State private var viewModel: TrackDetailViewModel

	init(track: AudioTrack, viewModel: TrackDetailViewModel) {
		self.track = track
		_viewModel = State(initialValue: viewModel)
	}

	var body: some View {
		ScrollView {
			VStack(alignment: .leading, spacing: 20) {
				ZStack {
					AsyncImage(url: URL(string: track.thumbnailUrl)) { image in
						image.resizable().scaledToFill()
					} placeholder: {
						RoundedRectangle(cornerRadius: 12)
							.fill(.quaternary)
							.overlay { Image(systemName: "music.note").font(.largeTitle) }
					}
					.frame(height: 280)
					.frame(maxWidth: .infinity)
					.clipShape(RoundedRectangle(cornerRadius: 12))
				}

				Text(track.name)
					.font(.title.bold())

				if viewModel.isLoading && viewModel.metadata == nil {
					ProgressView("Loading track details…")
				} else if let errorMessage = viewModel.errorMessage {
					ContentUnavailableView {
						Label("Couldn't Load Details", systemImage: "exclamationmark.triangle")
					} description: {
						Text(errorMessage)
					} actions: {
						Button("Try Again") {
							Task { await viewModel.loadDetails() }
						}
					}
				} else if let metadata = viewModel.metadata {
					LabeledContent("Artist", value: metadata.author)
					LabeledContent("Released", value: metadata.releaseDay.formatted(date: .long, time: .omitted))
					if let lyric = viewModel.lyric {
						Text("Lyrics")
							.font(.headline)
						Text(lyric.content)
							.foregroundStyle(.secondary)
					}
				}
			}
			.padding()
		}
		.navigationTitle(track.name)
		.navigationBarTitleDisplayMode(.inline)
		.task { await viewModel.loadDetails() }
	}
}

#Preview {
	let trackID = UUID()
	let track = AudioTrack(
		id: trackID,
		name: "Night Drive",
		streamingUrl: "https://example.com/night-drive.mp3",
		thumbnailUrl: "https://example.com/cover.jpg",
		audioMetadataUrl: "https://example.com/metadata"
	)
	NavigationStack {
		TrackDetailView(
			track: track,
			viewModel: TrackDetailViewModel(trackID: trackID, audioRepository: PreviewRepository())
		)
	}
}

@MainActor
private struct PreviewRepository: AudioRepositoryProtocol {
	func fetchAudios() async throws -> [AudioTrack] { [] }
	func fetchMetadata(for trackId: UUID) async throws -> AudioTrackMetadata {
		AudioTrackMetadata(
			id: UUID(), trackID: trackId, author: "Sample Artist",
			releaseDay: .now, isSubtitleSupport: true, isFavorite: true, created_at: .now
		)
	}
	func fetchLyric(for trackId: UUID) async throws -> AudioLyric {
		AudioLyric(id: UUID(), trackId: trackId, content: "First sample lyric line.\\nSecond sample lyric line.")
	}
}
