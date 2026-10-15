//
//  PlayerModel.swift
//  mangoaudioplayer
//
//  Created by mango on 10/15/26.
//

import Foundation
import AVFoundation

@MainActor
@Observable
final class PlayerModel {
	private(set) var currentTrack: AudioTrack?
	private(set) var isPlaying = false
	private(set) var player = AVPlayer()
	var progress = 0.0
	var duration = 100.0
	init(isPlaying: Bool = false) {
		self.isPlaying = isPlaying
	}
	
	func load(_ track: AudioTrack) {
		self.currentTrack = track
	}
	
	func play(_ track: AudioTrack) {
		if currentTrack?.id != track.id {
			load(track)
		}
		
		player.play()
		isPlaying = true
	}
	
	func pause() {
		player.pause()
		isPlaying = false
	}
}
