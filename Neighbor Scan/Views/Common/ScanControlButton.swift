//
//  ScanControlButton.swift
//  Neighbor Scan
//
//  Created by Kirill Zolotarev on 25.10.2025.
//


import SwiftUI

struct ScanControlButton: View {
	let isScanning: Bool
	let action: () -> Void
	
	var body: some View {
		Button(action: action) {
			HStack {
				Image(systemName: isScanning ? "stop.circle.fill" : "play.circle.fill")
					.font(.title2)
				Text(isScanning ? "Остановить сканирование" : "Начать сканирование")
					.fontWeight(.semibold)
			}
			.foregroundColor(.white)
			.padding(.horizontal, 24)
			.padding(.vertical, 12)
			.background(isScanning ? Color.red : Color.blue)
			.cornerRadius(25)
		}
	}
}

#Preview{
	ScanControlButton(isScanning: false, action: {})
}
