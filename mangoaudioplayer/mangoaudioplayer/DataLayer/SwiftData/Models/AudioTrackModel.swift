//
//  AudioTrackModel.swift
//  mangoaudioplayer
//
//  Created by mango on 10/14/26.
//

import Foundation
import SwiftData

@Model
final class AudioTrackModel {
	@Attribute(.unique)
	var id: UUID
	var name: String
	var streamingUrl: String
	var thumbnailUrl: String
	var audioMetadataUrl: String
	init(id: UUID, name: String, streamingUrl: String, thumbnailUrl: String, audioMetadataUrl: String) {
		self.id = id
		self.name = name
		self.streamingUrl = streamingUrl
		self.thumbnailUrl = thumbnailUrl
		self.audioMetadataUrl = audioMetadataUrl
	}
}
