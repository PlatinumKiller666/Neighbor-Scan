//
//  DeviceListViewModel.swift
//  Neighbor Scan
//
//  Created by Kirill Zolotarev on 25.10.2025.
//

import Foundation
import RealmSwift
import Combine

@MainActor
final class DeviceListViewModel: ObservableObject {
	@Published var filteredDevices: [Device] = []
	@Published var isLoading = false
	@Published var errorMessage: String?
	
	private let realmService = RealmService.shared
	private var notificationToken: NotificationToken?
	
	init() {
		setupLiveUpdates()
	}
	
	deinit {
		notificationToken?.invalidate()
	}
	
	private func setupLiveUpdates() {
		notificationToken = realmService.observeDevices { [weak self] devices in
			self?.filteredDevices = devices
		}
	}
	
	func applyFiltersWithSessions(
		sessions: [ScanningSession],
		dateRange: ClosedRange<Date>,
		sortOrder: SortOrder = .descending
	) {
		isLoading = true
		errorMessage = nil
		
		var allDevices: [Device] = []
		for session in sessions {
			let sessionDevices = Array(session.devices)
			allDevices.append(contentsOf: sessionDevices)
		}
		
		debugPrint("Всего устройств из сессий: \(allDevices.count)")
		
		// Фильтрация по дате
		let filteredDevices = allDevices.filter { device in
			dateRange.contains(device.timestamp)
		}
		
		debugPrint("Устройств после фильтрации по дате: \(filteredDevices.count)")
		
		// Сортировка
		let sortedDevices = filteredDevices.sorted {
			sortOrder == .descending ?
			$0.timestamp > $1.timestamp :
			$0.timestamp < $1.timestamp
		}
		
		self.filteredDevices = sortedDevices
		isLoading = false
		
		debugPrint("Финальное количество устройств: \(sortedDevices.count)")
	}
	
	func refreshData() {
		// Базовая загрузка всех устройств
		filteredDevices = realmService.getAllDevices()
	}
	
	// Альтернативный метод для отладки
	func debugSessions(_ sessions: [ScanningSession]) {
		debugPrint("=== ДЕБАГ СЕССИЙ ===")
		debugPrint("Количество сессий: \(sessions.count)")
		
		for (index, session) in sessions.enumerated() {
			debugPrint("Сессия \(index + 1):")
			debugPrint("  - ID: \(session.id)")
			debugPrint("  - Начало: \(session.startTime)")
			debugPrint("  - Конец: \(session.endTime?.description ?? "N/A")")
			debugPrint("  - Количество устройств: \(session.devices.count)")
			
			// Выводим информацию об устройствах
			for device in session.devices {
				debugPrint("    Устройство: \(device.name ?? "Unnamed") - \(device.type.rawValue) - \(device.timestamp)")
			}
		}
		debugPrint("====================")
	}
}
