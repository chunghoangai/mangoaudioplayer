//
//  TrackMapper.swift
//  mangoaudioplayer
//
//  Created by mango on 10/12/26.
//


import Foundation

protocol TrackMapperProtocol {
	func map(dto: AudioTrackDTO) -> AudioTrack
}

struct TrackMapper: TrackMapperProtocol {
	func map(dto: AudioTrackDTO) -> AudioTrack {
		AudioTrack(id: dto.id, name: dto.name, streamingUrl: dto.streamingUrl, thumbnailUrl: dto.thumbnailUrl, audioMetadataUrl: dto.audioMetadataUrl)
	}
}

