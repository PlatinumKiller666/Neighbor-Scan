//
//  HistoryViewModel.swift
//  Neighbor Scan
//
//  Created by Kirill Zolotarev on 25.10.2025.
//


/*
 import Foundation
 import Combine
 import RealmSwift
 
 class HistoryViewModel: ObservableObject {
 private let realmService = RealmService.shared
 
 @Published var scanningSessions: [ScanningSession] = []
 @Published var searchText = ""
 @Published var selectedTimeRange: TimeRange = .allTime
 @Published var errorMessage: String?
 
 private var notificationTokens: [NotificationToken] = []
 
 enum TimeRange {
 case lastHour, today, lastWeek, allTime
 }
 
 var filteredSessions: [ScanningSession] {
 var sessions = scanningSessions
 
 let calendar = Calendar.current
 let now = Date()
 
 switch selectedTimeRange {
 case .lastHour:
 let oneHourAgo = now.addingTimeInterval(-3600)
 sessions = sessions.filter { $0.startTime > oneHourAgo }
 case .today:
 if let todayStart = calendar.date(bySettingHour: 0, minute: 0, second: 0, of: now) {
 sessions = sessions.filter { $0.startTime > todayStart }
 }
 case .lastWeek:
 let oneWeekAgo = now.addingTimeInterval(-7 * 24 * 3600)
 sessions = sessions.filter { $0.startTime > oneWeekAgo }
 case .allTime:
 break
 }
 
 if !searchText.isEmpty {
 sessions = sessions.map { session in
 let filteredDevices = session.devices.filter {[searchText] device in
 device.name?.localizedCaseInsensitiveContains(searchText) == true ||
 device.ipAddress?.localizedCaseInsensitiveContains(searchText) == true ||
 device.macAddress?.localizedCaseInsensitiveContains(searchText) == true
 }
 
 let filteredSession = ScanningSession()
 filteredSession.id = session.id
 filteredSession.startTime = session.startTime
 filteredSession.endTime = session.endTime
 filteredSession.devices.append(objectsIn: filteredDevices)
 
 return filteredSession
 }.filter { !$0.devices.isEmpty }
 }
 
 return sessions.sorted { $0.startTime > $1.startTime }
 }
 
 init() {
 setupRealmObservers()
 }
 
 deinit {
 notificationTokens.forEach { $0.invalidate() }
 }
 
 private func setupRealmObservers() {
 guard let sessionsResults = realmService.getAllSessions() else { return }
 
 let token = sessionsResults.observe { [weak self] changes in
 switch changes {
 case .initial(let results):
 self?.scanningSessions = Array(results)
 case .update(let results, _, _, _):
 self?.scanningSessions = Array(results)
 case .error(let error):
 self?.errorMessage = "Ошибка загрузки данных: \(error.localizedDescription)"
 }
 }
 
 notificationTokens.append(token)
 }
 
 func deleteSession(_ session: ScanningSession) {
 realmService.deleteSession(session)
 }
 
 func deleteAllHistory() {
 realmService.deleteAllData()
 }
 
 func getStatistics() -> (totalDevices: Int, bluetoothCount: Int, lanCount: Int) {
 let counts = realmService.getDevicesCountByType()
 let total = realmService.getTotalDevicesCount()
 
 return (
 totalDevices: total,
 bluetoothCount: counts[.bluetooth] ?? 0,
 lanCount: counts[.lan] ?? 0
 )
 }
 }
 */

import Foundation
import Combine
import RealmSwift

class HistoryViewModel: ObservableObject {
	private let realmService = RealmService()
	
	@Published var scanningSessions: [ScanningSession] = []
	@Published var searchText = ""
	@Published var selectedTimeRange: TimeRange = .allTime
	@Published var errorMessage: String?
	
	private var notificationTokens: [NotificationToken] = []
	
	enum TimeRange {
		case lastHour, today, lastWeek, allTime
	}
	
	var filteredSessions: [ScanningSession] {
		var sessions = scanningSessions
		
		let calendar = Calendar.current
		let now = Date()
		
		switch selectedTimeRange {
		case .lastHour:
			let oneHourAgo = now.addingTimeInterval(-3600)
			sessions = sessions.filter { $0.startTime > oneHourAgo }
		case .today:
			if let todayStart = calendar.date(bySettingHour: 0, minute: 0, second: 0, of: now) {
				sessions = sessions.filter { $0.startTime > todayStart }
			}
		case .lastWeek:
			let oneWeekAgo = now.addingTimeInterval(-7 * 24 * 3600)
			sessions = sessions.filter { $0.startTime > oneWeekAgo }
		case .allTime:
			break
		}
		
		if !searchText.isEmpty {
			sessions = sessions.compactMap { session in
				let filteredDevices = session.devices.filter { device in
					device.name?.localizedCaseInsensitiveContains(searchText) == true ||
					device.ipAddress?.localizedCaseInsensitiveContains(searchText) == true ||
					device.macAddress?.localizedCaseInsensitiveContains(searchText) == true
				}
				
				guard !filteredDevices.isEmpty else { return nil }
				
				let filteredSession = ScanningSession()
				filteredSession.id = session.id
				filteredSession.startTime = session.startTime
				filteredSession.endTime = session.endTime
				filteredSession.devices.append(objectsIn: filteredDevices)
				
				return filteredSession
			}
		}
		
		return sessions.sorted { $0.startTime > $1.startTime }
	}
	
	init() {
		setupRealmObservers()
	}
	
	deinit {
		notificationTokens.forEach { $0.invalidate() }
	}
	
	private func setupRealmObservers() {
		realmService.getAllSessions { [weak self] results in
			guard let results = results else { return }
			
			let token = results.observe { changes in
				switch changes {
				case .initial(let sessions):
					self?.scanningSessions = Array(sessions)
				case .update(let sessions, _, _, _):
					self?.scanningSessions = Array(sessions)
				case .error(let error):
					self?.errorMessage = "Ошибка загрузки данных: \(error.localizedDescription)"
				}
			}
			
			self?.notificationTokens.append(token)
		}
	}
	
	func deleteSession(_ session: ScanningSession) {
		realmService.deleteSession(session) { [weak self] error in
			if let error = error {
				self?.errorMessage = "Ошибка удаления сессии: \(error.localizedDescription)"
			}
		}
	}
	
	func deleteAllHistory() {
		realmService.deleteAllData { [weak self] error in
			if let error = error {
				self?.errorMessage = "Ошибка очистки истории: \(error.localizedDescription)"
			}
		}
	}
	
	func getStatistics(completion: @escaping ((totalDevices: Int, bluetoothCount: Int, lanCount: Int)) -> Void) {
		realmService.getDevicesCountByType { counts in
			self.realmService.getTotalDevicesCount { total in
				let result = (
					totalDevices: total,
					bluetoothCount: counts[.bluetooth] ?? 0,
					lanCount: counts[.lan] ?? 0
				)
				completion(result)
			}
		}
	}
}
