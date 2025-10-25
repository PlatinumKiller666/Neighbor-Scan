//
//  HistoryDeviceListView.swift
//  Neighbor Scan
//
//  Created by Kirill Zolotarev on 25.10.2025.
//


import SwiftUI
import RealmSwift

struct HistoryDeviceListView: View {
	let deviceTypeFilter: DeviceTypeFilter
	let timePeriodFilter: TimePeriodFilter
	let dateRange: ClosedRange<Date>
	let sortOrder: SortOrder
	
	@StateObject private var viewModel = DeviceListViewModel()
	
	var body: some View {
		Group {
			if viewModel.isLoading {
				ProgressView("Загрузка истории...")
					.padding()
			} else if viewModel.filteredDevices.isEmpty {
				EmptyHistoryView(
					filter: deviceTypeFilter,
					timePeriod: timePeriodFilter,
					sortOrder: sortOrder
				)
			} else {
				List {
					Section {
						EmptyView()
					} header: {
						HistoryHeaderView(
							deviceCount: viewModel.filteredDevices.count,
							sortOrder: sortOrder,
							timePeriod: timePeriodFilter
						)
					}
					
					ForEach(viewModel.filteredDevices) { device in
						NavigationLink(destination: DeviceDetailView(device: device)) {
							DeviceRow(
								device: device,
								showDeviceType: deviceTypeFilter == .all,
								sortOrder: sortOrder
							)
						}
					}
				}
				.listStyle(GroupedListStyle())
			}
		}
		.onAppear {
			viewModel.applyFilters(
				deviceType: deviceTypeFilter,
				dateRange: dateRange,
				sortOrder: sortOrder
			)
		}
		.onChange(of: deviceTypeFilter) { newFilter in
			viewModel.applyFilters(
				deviceType: newFilter,
				dateRange: dateRange,
				sortOrder: sortOrder
			)
		}
		.onChange(of: dateRange) { newRange in
			viewModel.applyFilters(
				deviceType: deviceTypeFilter,
				dateRange: newRange,
				sortOrder: sortOrder
			)
		}
		.onChange(of: sortOrder) { newOrder in
			viewModel.applyFilters(
				deviceType: deviceTypeFilter,
				dateRange: dateRange,
				sortOrder: newOrder
			)
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
