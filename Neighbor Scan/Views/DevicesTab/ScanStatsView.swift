//
//  ScanStatsView.swift
//  Neighbor Scan
//
//  Created by Kirill Zolotarev on 25.10.2025.
//


import SwiftUI

struct ScanStatsView: View {
	@ObservedObject var viewModel: ScannerViewModel
	let filter: DeviceTypeFilter
	
	var body: some View {
		VStack{
			VStack(spacing: 4) {
				Text("Статистика сканирования")
					.font(.caption)
					.foregroundColor(.secondary)
				
				HStack(spacing: 16) {
					if filter == .all || filter == .bluetooth {
						StatBadge(count: viewModel.bluetoothDevices.count, type: .bluetooth)
					}
					
					if filter == .all || filter == .lan {
						StatBadge(count: viewModel.lanDevices.count, type: .lan)
					}
					
					if filter == .all {
						StatBadge(count: viewModel.foundDevicesCount, type: .all)
					}
				}
			}
			.padding(8)
		}
		.background(Color.black)
		.cornerRadius(8)
		.overlay(
			RoundedRectangle(cornerRadius: 8)
				.stroke(.gray.opacity(0.5), lineWidth: 2)
		)
		.padding(.vertical, 8)
	}
}

struct StatBadge: View {
	let count: Int
	let type: DeviceTypeFilter
	
	var body: some View {
		HStack(spacing: 4) {
			Image(systemName: iconName)
				.font(.caption)
			Text("\(count)")
				.font(.system(.caption, design: .monospaced))
				.fontWeight(.medium)
		}
		.foregroundColor(iconColor)
		.padding(.horizontal, 8)
		.padding(.vertical, 4)
		.background(backgroundColor)
		.cornerRadius(8)
	}
	
	private var iconName: String {
		switch type {
		case .all: return "network"
		case .bluetooth: return "dot.radiowaves.left.and.right"
		case .lan: return "wifi"
		}
	}
	
	private var iconColor: Color {
		switch type {
		case .all: return .white
		case .bluetooth: return .white
		case .lan: return .white
		}
	}
	
	private var backgroundColor: Color {
		switch type {
		case .all: return .blue
		case .bluetooth: return .purple
		case .lan: return .green
		}
	}
}
