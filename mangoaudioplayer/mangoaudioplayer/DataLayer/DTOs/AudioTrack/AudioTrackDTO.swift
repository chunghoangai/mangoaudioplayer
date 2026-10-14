//
//  AudioTrackDTO.swift
//  mangoaudioplayer
//
//  Created by mango on 10/12/26.
//

import Foundation

struct AudioTrackDTO: Decodable {
	let id: UUID
	let name: String
	let streamingUrl: String
	let thumbnailUrl: String
	let audioMetadataUrl: String
}
