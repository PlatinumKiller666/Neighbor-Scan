//
//  DevicesTabView.swift
//  Neighbor Scan
//
//  Created by Kirill Zolotarev on 25.10.2025.
//


import SwiftUI
import Lottie

struct DevicesTabView: View {
	@ObservedObject var coordinator: AppCoordinator
	@State private var selectedDeviceTypeSegment = 0
	@State private var selectedTimePeriodSegment = 0
	@State private var showDatePicker = false
	@State private var selectedStartDate = Date().addingTimeInterval(-86400)
	@State private var selectedEndDate = Date()
	@State private var sortOrder: SortOrder = .descending
	@State private var showSortOptions = false
	
	@EnvironmentObject var scannerViewModel: ScannerViewModel
	
	var body: some View {
		NavigationView {
			VStack(spacing: 0) {
				ZStack{
					//				List{
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
						
						CurrentScanDeviceListView(
							coordinator: coordinator,
							deviceTypeFilter: deviceTypeFilter,
							sortOrder: sortOrder
						)
						Spacer()
					}
					
//					.padding(.bottom)
					
					
					VStack {
					
						if scannerViewModel.isScanning {
							Spacer()
							LottieView(animation:  .named("Pulse")).looping()
								.padding(.bottom, 5)
							ScanStatsView(viewModel: scannerViewModel, filter: deviceTypeFilter).scaledToFit()
						}
						Spacer()
						
						ScanControlButton(
							isScanning: scannerViewModel.isScanning,
							action: {
								if scannerViewModel.isScanning {
									scannerViewModel.stopScanning()
								} else {
									scannerViewModel.clearCurrentScanResults()
									scannerViewModel.startScanning()
								}
							}
						)
						.padding(.bottom)
					}
					.background(Color.clear)
				}
//				}.listStyle(.plain)
			}
			.navigationTitle("Сканирование")
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
			.alert("Ошибка", isPresented: $scannerViewModel.showAlert) {
				Button("OK", role: .cancel) { }
			} message: {
				Text(scannerViewModel.errorMessage ?? "Неизвестная ошибка")
			}
			.alert("Сканирование завершено", isPresented: $scannerViewModel.showCompletionAlert) {
				Button("OK", role: .cancel) { }
			} message: {
				Text("Найдено устройств: \(scannerViewModel.foundDevicesCount)")
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
}
