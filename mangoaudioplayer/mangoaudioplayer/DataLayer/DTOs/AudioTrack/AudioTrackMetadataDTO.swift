//
//  AudioTrackMetadataDTO.swift
//  mangoaudioplayer
//
//  Created by mango on 10/12/26.
//

import Foundation

struct AudioTrackMetadataDTO: Decodable {
	var id: UUID
	var trackID: UUID
	var author: String
	var releaseDay: Date
	var isSubtitleSupport: Bool = false
	var isFavorite: Bool = false
	var created_at: Date
}
