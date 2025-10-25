//
//  HistoryView.swift
//  Neighbor Scan
//
//  Created by Kirill Zolotarev on 25.10.2025.
//


import SwiftUI

struct HistoryView: View {
	@ObservedObject var coordinator: AppCoordinator
	@StateObject private var historyViewModel = HistoryViewModel()
	@State private var selectedDeviceTypeSegment = 0
	@State private var selectedTimePeriodSegment = 0
	@State private var showDatePicker = false
	@State private var selectedStartDate = Date().addingTimeInterval(-7 * 24 * 3600)
	@State private var selectedEndDate = Date()
	@State private var sortOrder: SortOrder = .descending
	@State private var showSortOptions = false
	
	var body: some View {
		NavigationView {
			VStack(spacing: 0) {
//				Picker("Тип устройств", selection: $selectedDeviceTypeSegment) {
//					Text("Все").tag(0)
//					Text("Bluetooth").tag(1)
//					Text("LAN").tag(2)
//				}
//				.pickerStyle(SegmentedPickerStyle())
//				.padding(.horizontal)
//				.padding(.top, 8)
				
				VStack(spacing: 8) {
					Picker("Период", selection: $selectedTimePeriodSegment) {
						Text("24 часа").tag(0)
						Text("Неделя").tag(1)
						Text("Выбор даты").tag(2)
					}
					.pickerStyle(SegmentedPickerStyle())
					.padding(.horizontal)
					
					if showDatePicker {
						DateRangePickerView(
							startDate: $selectedStartDate,
							endDate: $selectedEndDate
						)
						.padding(.horizontal)
					}
				}
				.padding(.bottom, 4)
				
				HistoryDeviceListView(
					deviceTypeFilter: deviceTypeFilter,
					timePeriodFilter: timePeriodFilter,
					dateRange: dateRange,
					sortOrder: sortOrder
				)
				
				Spacer()
			}
			.navigationTitle("История")
			.navigationBarItems(trailing: sortButton)
			.actionSheet(isPresented: $showSortOptions) {
				ActionSheet(
					title: Text("Сортировка по дате"),
					message: Text("Выберите порядок сортировки устройств"),
					buttons: [
						.default(Text("Сначала новые (по убыванию)")) {
							sortOrder = .descending
						},
						.default(Text("Сначала старые (по возрастанию)")) {
							sortOrder = .ascending
						},
						.cancel(Text("Отмена"))
					]
				)
			}
			.onChange(of: selectedTimePeriodSegment) { newValue in
				showDatePicker = (newValue == 2)
			}
		}
		.navigationViewStyle(StackNavigationViewStyle())
	}
	
	private var sortButton: some View {
		Button(action: {
			showSortOptions = true
		}) {
			HStack(spacing: 4) {
				Image(systemName: sortOrder.iconName)
					.font(.system(size: 16, weight: .medium))
				Text("Сортировка")
					.font(.system(size: 14, weight: .medium))
			}
			.foregroundColor(.blue)
			.padding(.horizontal, 12)
			.padding(.vertical, 6)
			.background(Color.blue.opacity(0.1))
			.cornerRadius(8)
		}
	}
	
	private var deviceTypeFilter: DeviceTypeFilter {
		switch selectedDeviceTypeSegment {
		case 1: return .bluetooth
		case 2: return .lan
		default: return .all
		}
	}
	
	private var timePeriodFilter: TimePeriodFilter {
		switch selectedTimePeriodSegment {
		case 0: return .last24Hours
		case 1: return .lastWeek
		case 2: return .customRange
		default: return .last24Hours
		}
	}
	
	private var dateRange: ClosedRange<Date> {
		let now = Date()
		switch timePeriodFilter {
		case .last24Hours:
			let startDate = now.addingTimeInterval(-24 * 3600)
			return startDate...now
		case .lastWeek:
			let startDate = now.addingTimeInterval(-7 * 24 * 3600)
			return startDate...now
		case .customRange:
			return selectedStartDate...selectedEndDate
		}
	}
}
