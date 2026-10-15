import SwiftUI

struct HomeView: View {
	@State private var viewModel: HomeViewModel

	init(viewModel: HomeViewModel) {
		_viewModel = State(initialValue: viewModel)
	}

	var body: some View {
		Group {
			if viewModel.isLoading && viewModel.tracks.isEmpty {
				ProgressView("Loading tracks…")
					.frame(maxWidth: .infinity, maxHeight: .infinity)
			} else if let errorMessage = viewModel.errorMessage, viewModel.tracks.isEmpty {
				ContentUnavailableView {
					Label("Couldn't Load Tracks", systemImage: "exclamationmark.triangle")
				} description: {
					Text(errorMessage)
				} actions: {
					Button("Try Again") {
						Task { await viewModel.loadTracks() }
					}
				}
			} else if viewModel.tracks.isEmpty {
				ContentUnavailableView("No Tracks", systemImage: "music.note.list")
			} else {
				List(viewModel.tracks, id: \.id) { track in
					Button {
						viewModel.selectTrack(track)
					} label: {
						TrackRow(track: track)
							.contentShape(Rectangle())
					}
					.buttonStyle(.plain)
				}
				.refreshable {
					await viewModel.loadTracks()
				}
			}
		}
		.navigationTitle("Mango Audio")
		.task {
			await viewModel.loadTracks()
		}
	}
}

#Preview {
	NavigationStack {
		HomeView(viewModel: HomeViewModel(audioRepository: PreviewRepository()))
	}
}

@MainActor
private struct PreviewRepository: AudioRepositoryProtocol {
	func fetchAudios() async throws -> [AudioTrack] {
		[
			AudioTrack(
				id: UUID(), name: "Night Drive",
				streamingUrl: "https://example.com/night-drive.mp3",
				thumbnailUrl: "https://example.com/cover.jpg",
				audioMetadataUrl: "https://example.com/metadata"
			),
			AudioTrack(
				id: UUID(), name: "Soft Focus",
				streamingUrl: "https://example.com/soft-focus.mp3",
				thumbnailUrl: "https://example.com/cover-2.jpg",
				audioMetadataUrl: "https://example.com/metadata-2"
			)
		]
	}
	func fetchMetadata(for trackId: UUID) async throws -> AudioTrackMetadata {
		AudioTrackMetadata(id: UUID(), trackID: trackId, author: "Sample Artist", releaseDay: .now, created_at: .now)
	}
	func fetchLyric(for trackId: UUID) async throws -> AudioLyric {
		AudioLyric(id: UUID(), trackId: trackId, content: "Sample lyrics")
	}
}


private struct TrackRow: View {
	let track: AudioTrack

	var body: some View {
		HStack(spacing: 12) {
			AsyncImage(url: URL(string: track.thumbnailUrl)) { image in
				image
					.resizable()
						.scaledToFill()
			} placeholder: {
				RoundedRectangle(cornerRadius: 8)
					.fill(.quaternary)
					.overlay {
						Image(systemName: "music.note")
							.foregroundStyle(.secondary)
					}
			}
			.frame(width: 52, height: 52)
			.clipShape(RoundedRectangle(cornerRadius: 8))

			Text(track.name)
				.font(.headline)
				.lineLimit(1)
		}
		.padding(.vertical, 4)
	}
}
