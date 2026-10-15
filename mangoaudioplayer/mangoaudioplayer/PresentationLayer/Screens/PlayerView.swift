//
//  PlayerView.swift
//  mangoaudioplayer
//
//  Created by mango on 10/15/26.
//

import SwiftUI

struct PlayerView: View {
	@State private var playerModel: PlayerModel
	init(playerModel: PlayerModel) {
		self.playerModel = playerModel
	}
	
	var body: some View {
		VStack {
			ZStack(alignment: .bottomLeading) {
				AsyncImage(url: URL(string: playerModel.currentTrack?.thumbnailUrl ?? "")) { image in
					image.resizable().scaledToFill()
				} placeholder: {
					RoundedRectangle(cornerRadius: 12)
						.fill(.quaternary)
						.overlay { Image(systemName: "music.note").font(.largeTitle) }
				}
				.frame(height: 280)
				.frame(maxWidth: .infinity)
				.clipShape(RoundedRectangle(cornerRadius: 12))
				
				HStack {
					Text("playerModel.progress}")
					
					ProgressView(value: playerModel.progress, total: playerModel.duration)
						.padding(.trailing)
						.foregroundStyle(.blue)
					Text(playerModel.duration)
				}
			}
			controlView
		}
		.padding(10)
		
	}
	@ViewBuilder
	private var controlView: some View {
		HStack {
			Button {
				
			} label: {
				Text("Left")
			}
			Button {
				
			} label: {
				Text("Center")
			}
			Button {
				
			} label: {
				Text("Right")
			}
		}
	}
}

#Preview {
	let model = PlayerModel(isPlaying: true)
	PlayerView(playerModel: model)
}
