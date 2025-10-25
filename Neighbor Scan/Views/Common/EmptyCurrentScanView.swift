//
//  EmptyCurrentScanView.swift
//  Neighbor Scan
//
//  Created by Kirill Zolotarev on 25.10.2025.
//


import SwiftUI

struct EmptyCurrentScanView: View {
	let filter: DeviceTypeFilter
	
	var body: some View {
		VStack(spacing: 20) {
			Image(systemName: iconName)
				.font(.system(size: 60))
				.foregroundColor(.gray)
			
			Text(title)
				.font(.title2)
				.foregroundColor(.secondary)
				.multilineTextAlignment(.center)
			
			Text(subtitle)
				.font(.body)
				.foregroundColor(.secondary)
				.multilineTextAlignment(.center)
				.padding(.horizontal, 40)
		}
		.padding()
	}
	
	private var iconName: String {
		switch filter {
		case .all: return "magnifyingglass"
		case .bluetooth: return "dot.radiowaves.left.and.right"
		case .lan: return "network"
		}
	}
	
	private var title: String {
		switch filter {
		case .all: return "Устройства не найдены"
		case .bluetooth: return "Bluetooth устройства не найдены"
		case .lan: return "LAN устройства не найдены"
		}
	}
	
	private var subtitle: String {
		return "Запустите сканирование для поиска устройств в сети"
	}
}

struct EmptyHistoryView: View {
	let filter: DeviceTypeFilter
	let timePeriod: TimePeriodFilter
	let sortOrder: SortOrder
	
	var body: some View {
		VStack(spacing: 20) {
			Image(systemName: "clock")
				.font(.system(size: 60))
				.foregroundColor(.gray)
			
			Text("История пуста")
				.font(.title2)
				.foregroundColor(.secondary)
				.multilineTextAlignment(.center)
			
			Text("В выбранных фильтрах (\(periodText)) устройства не найдены")
				.font(.body)
				.foregroundColor(.secondary)
				.multilineTextAlignment(.center)
				.padding(.horizontal, 40)
			
			HStack(spacing: 6) {
				Image(systemName: sortOrder.iconName)
					.font(.caption)
					.foregroundColor(.blue)
				
				Text("Сортировка: \(sortOrder.title)")
					.font(.caption)
					.foregroundColor(.secondary)
			}
			.padding(8)
			.background(Color.blue.opacity(0.1))
			.cornerRadius(6)
		}
		.padding()
	}
	
	private var periodText: String {
		switch timePeriod {
		case .last24Hours: return "за последние 24 часа"
		case .lastWeek: return "за последнюю неделю"
		case .customRange: return "в выбранный период"
		}
	}
}
