//
//  SignalStrengthView.swift
//  Neighbor Scan
//
//  Created by Kirill Zolotarev on 25.10.2025.
//


import SwiftUI

struct SignalStrengthView: View {
	let rssi: Int
	
	var body: some View {
		HStack(spacing: 4) {
			ForEach(0..<4) { index in
				Rectangle()
					.fill(signalColor(for: index))
					.frame(width: 3, height: CGFloat(index + 2) * 2)
			}
			
			Text("\(rssi) dBm")
				.font(.system(.caption, design: .monospaced))
				.foregroundColor(rssiColor)
				.frame(width: 50, alignment: .trailing)
		}
	}
	
	private func signalColor(for index: Int) -> Color {
		let levels = signalLevels
		return index < levels ? .green : .gray.opacity(0.3)
	}
	
	private var signalLevels: Int {
		switch rssi {
		case ..<(-80): return 1
		case -80..<(-60): return 2
		case -60..<(-40): return 3
		default: return 4
		}
	}
	
	private var rssiColor: Color {
		switch rssi {
		case ..<(-80): return .red
		case -80..<(-60): return .orange
		case -60..<(-40): return .yellow
		default: return .green
		}
	}
}
