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
	@State private var selectedTimePeriodSegment = 0
	@State private var showDatePicker = false
	@State private var selectedStartDate = Date().addingTimeInterval(-7 * 24 * 3600)
	@State private var selectedEndDate = Date()
	@State private var sortOrder: SortOrder = .descending
	@State private var showSortOptions = false
	
	// Вычисляемое свойство для фильтрованных сессий
	private var filteredSessions: [ScanningSession] {
		let sessions = historyViewModel.scanningSessions
		
		// Фильтрация по времени
		let now = Date()
		let timeFilteredSessions: [ScanningSession]
		
		switch selectedTimePeriodSegment {
		case 0: // 24 часа
			let oneDayAgo = now.addingTimeInterval(-24 * 3600)
			timeFilteredSessions = sessions.filter { $0.startTime > oneDayAgo }
		case 1: // Неделя
			let oneWeekAgo = now.addingTimeInterval(-7 * 24 * 3600)
			timeFilteredSessions = sessions.filter { $0.startTime > oneWeekAgo }
		case 2: // Выбор даты
			timeFilteredSessions = sessions.filter { session in
				dateRange.contains(session.startTime)
			}
		default:
			timeFilteredSessions = sessions
		}
		
		// Сортировка
		return timeFilteredSessions.sorted {
			sortOrder == .descending ?
			$0.startTime > $1.startTime :
			$0.startTime < $1.startTime
		}
	}
	
	var body: some View {
		NavigationView {
			VStack(spacing: 0) {
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
				.padding(.vertical, 8)
				
				if historyViewModel.isLoading {
					ProgressView("Загрузка истории...")
						.padding()
				} else if filteredSessions.isEmpty {
					EmptyHistoryView(
						timePeriod: timePeriodFilter,
						sortOrder: sortOrder
					)
				} else {
					HistoryDeviceListView(
						sessions: filteredSessions,
						dateRange: dateRange,
						sortOrder: sortOrder,
						onDeleteSession: { session in
							historyViewModel.deleteSession(session)
						}
					)
				}
				
				Spacer()
			}
			.navigationTitle("История")
			.navigationBarItems(
				trailing: sortButton
			)
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
			.onChange(of: selectedStartDate) { _ in
			}
			.onChange(of: selectedEndDate) { _ in
			}
			.onAppear {
			}
		}
		.navigationViewStyle(StackNavigationViewStyle())
	}
	
	// MARK: - Computed Properties
	
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
	
	// MARK: - Buttons
	
	private var refreshButton: some View {
		Button(action: {
			historyViewModel.refreshData()
		}) {
			Image(systemName: "arrow.clockwise")
				.font(.system(size: 18))
		}
	}
	
	private var sortButton: some View {
		Button(action: {
			showSortOptions = true
		}) {
			HStack(spacing: 4) {
				Image(systemName: sortOrder.iconName)
					.font(.system(size: 14, weight: .medium))
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
}
