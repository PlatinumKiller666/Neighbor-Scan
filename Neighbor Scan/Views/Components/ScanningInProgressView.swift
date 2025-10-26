//
//  ScanningInProgressView.swift
//  Neighbor Scan
//
//  Created by Kirill Zolotarev on 25.10.2025.
//


import SwiftUI
import Lottie

struct ScanningInProgressView: View {
	var body: some View {
		VStack(spacing: 20) {
			LottieView(animation:  .named("Pulse")).looping()

			Text("Сканирование в процессе...")
				.font(.headline)
				.foregroundColor(.primary)

			Text("Устройства появятся здесь по мере обнаружения")
				.font(.body)
				.foregroundColor(.secondary)
				.multilineTextAlignment(.center)
				.padding(.horizontal, 40)
		}
		.padding()
	}
}

struct CurrentScanHeaderView: View {
	let deviceCount: Int
	let sortOrder: SortOrder
	let isScanning: Bool
	
	var body: some View {
		HStack {
			VStack(alignment: .leading, spacing: 4) {
				if isScanning {
					Text("Сканирование...")
						.font(.subheadline)
						.foregroundColor(.blue)
						.fontWeight(.medium)
				}
				
				Text("Найдено устройств: \(deviceCount)")
					.font(.subheadline)
					.fontWeight(.medium)
					.foregroundColor(.primary)
				
				HStack(spacing: 6) {
					Image(systemName: sortOrder.iconName)
						.font(.caption2)
						.foregroundColor(.blue)
					
					Text("Сортировка: \(sortOrder.displayName)")
						.font(.caption)
						.foregroundColor(.primary)
				}
			}
			
			Spacer()
		}
//		.padding(.vertical, 8)
		.padding(.horizontal, 4)
//		.background(Color.black)
	}
}

#Preview {
	ScanningInProgressView()
}

#Preview {
	CurrentScanHeaderView(deviceCount: 100, sortOrder: .ascending, isScanning: true)
}
