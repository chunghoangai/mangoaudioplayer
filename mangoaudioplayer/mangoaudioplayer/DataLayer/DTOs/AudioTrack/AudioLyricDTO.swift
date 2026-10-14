//
//  AudioLyricDTO.swift
//  mangoaudioplayer
//
//  Created by mango on 10/12/26.
//

import Foundation

struct AudioLyricDTO: Decodable {
	let id: UUID
	let trackId: UUID
	let content: String
}
