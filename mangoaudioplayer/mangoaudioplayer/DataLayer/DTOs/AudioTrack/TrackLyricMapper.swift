//
//  TrackMapper.swift
//  mangoaudioplayer
//
//  Created by mango on 10/12/26.
//


import Foundation

protocol TrackLyricMapperProtocol {
	func map(dto: AudioLyricDTO, for trackId: UUID) -> AudioLyric
}

struct TrackLyricMapper: TrackLyricMapperProtocol {
	func map(dto: AudioLyricDTO, for trackId: UUID) -> AudioLyric {
		AudioLyric(id: dto.id, trackId: trackId, content: dto.content)
	}
}

