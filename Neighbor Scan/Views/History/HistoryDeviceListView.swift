//
//  HistoryDeviceListView.swift
//  Neighbor Scan
//
//  Created by Kirill Zolotarev on 25.10.2025.
//

import SwiftUI

struct HistoryDeviceListView: View {
	let sessions: [ScanningSession]
	let dateRange: ClosedRange<Date>
	let sortOrder: SortOrder
	let onDeleteSession: ((ScanningSession) -> Void)?
	
	@StateObject private var viewModel = DeviceListViewModel()
	
	var body: some View {
		Group {
			if viewModel.isLoading {
				ProgressView("Загрузка устройств...")
					.padding()
			} else if viewModel.filteredDevices.isEmpty {
				EmptyHistoryView(
					timePeriod: timePeriodFilter,
					sortOrder: sortOrder
				)
			} else {
				List {
					Section {
						ForEach(viewModel.filteredDevices) { device in
							NavigationLink(destination: DeviceDetailView(device: device)) {
								DeviceRow(
									device: device,
									showDeviceType: true,
									sortOrder: sortOrder
								)
							}
						}
					} header: {
						HistoryHeaderView(
							deviceCount: viewModel.filteredDevices.count,
							sortOrder: sortOrder,
							timePeriod: timePeriodFilter
						)
					}
				}
				.listStyle(GroupedListStyle())
			}
		}
		.onAppear {
			// Отладочная информация
			viewModel.debugSessions(sessions)
			
			viewModel.applyFiltersWithSessions(
				sessions: sessions,
				dateRange: dateRange,
				sortOrder: sortOrder
			)
		}
		.onChange(of: sessions) { newSessions in
			debugPrint("Сессии изменились, количество: \(newSessions.count)")
			viewModel.applyFiltersWithSessions(
				sessions: newSessions,
				dateRange: dateRange,
				sortOrder: sortOrder
			)
		}
		.onChange(of: dateRange) { newRange in
			debugPrint("Диапазон дат изменился: \(newRange.lowerBound) - \(newRange.upperBound)")
			viewModel.applyFiltersWithSessions(
				sessions: sessions,
				dateRange: newRange,
				sortOrder: sortOrder
			)
		}
		.onChange(of: sortOrder) { newOrder in
			debugPrint("Сортировка изменилась: \(newOrder)")
			viewModel.applyFiltersWithSessions(
				sessions: sessions,
				dateRange: dateRange,
				sortOrder: newOrder
			)
		}
	}
	
	private var timePeriodFilter: TimePeriodFilter {
		// Определяем период на основе dateRange
		let now = Date()
		let oneDayAgo = now.addingTimeInterval(-24 * 3600)
		let oneWeekAgo = now.addingTimeInterval(-7 * 24 * 3600)
		
		if dateRange.lowerBound == oneDayAgo && dateRange.upperBound == now {
			return .last24Hours
		} else if dateRange.lowerBound == oneWeekAgo && dateRange.upperBound == now {
			return .lastWeek
		} else {
			return .customRange
		}
	}
}

struct HistoryHeaderView: View {
	let deviceCount: Int
	let sortOrder: SortOrder
	let timePeriod: TimePeriodFilter
	
	var body: some View {
		HStack {
			VStack(alignment: .leading, spacing: 4) {
				Text("Найдено устройств: \(deviceCount)")
					.font(.subheadline)
					.fontWeight(.medium)
				
				HStack(spacing: 6) {
					Image(systemName: sortOrder.iconName)
						.font(.caption2)
						.foregroundColor(.blue)
					
					Text("Сортировка: \(sortOrder.displayName)")
						.font(.caption)
						.foregroundColor(.secondary)
				}
				
				Text("Период: \(timePeriodTitle)")
					.font(.caption)
					.foregroundColor(.secondary)
			}
			
			Spacer()
		}
		.padding(.vertical, 8)
		.padding(.horizontal, 4)
	}
	
	private var timePeriodTitle: String {
		switch timePeriod {
		case .last24Hours: return "24 часа"
		case .lastWeek: return "неделя"
		case .customRange: return "выбор даты"
		}
	}
}
