import Foundation

struct AudioTrackMetadata {
	var id: UUID
	var trackID: UUID
	var author: String
	var releaseDay: Date
	var isSubtitleSupport: Bool = false
	var isFavorite: Bool = false
	var created_at: Date
}
