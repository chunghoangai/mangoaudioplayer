//
//  TrackMetadataMapper.swift
//  mangoaudioplayer
//
//  Created by mango on 10/12/26.
//

import Foundation

protocol TrackMetadataMapperProtocol {
	func map(dto: AudioTrackMetadataDTO, for trackID: UUID) -> AudioTrackMetadata
}

struct TrackMetadataMapper: TrackMetadataMapperProtocol {
	func map(dto: AudioTrackMetadataDTO, for trackID: UUID) -> AudioTrackMetadata {
		AudioTrackMetadata(
			id: dto.id,
			trackID: trackID,
			author: dto.author,
			releaseDay: dto.releaseDay,
			isSubtitleSupport: dto.isSubtitleSupport,
			isFavorite: dto.isFavorite,
			created_at: dto.created_at)
	}
}

