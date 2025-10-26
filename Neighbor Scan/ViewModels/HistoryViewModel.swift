//
//  HistoryViewModel.swift
//  Neighbor Scan
//
//  Created by Kirill Zolotarev on 25.10.2025.
//


import Foundation
import RealmSwift
import Combine

import Foundation
import RealmSwift
import Combine

@MainActor
final class HistoryViewModel: ObservableObject {
	@Published var scanningSessions: [ScanningSession] = []
	@Published var searchText = ""
	@Published var selectedTimeRange: TimeRange = .allTime
	@Published var errorMessage: String?
	@Published var isLoading = false
	
	private let realmService = RealmService.shared
	private var notificationToken: NotificationToken?
	
	enum TimeRange {
		case lastHour, today, lastWeek, allTime
	}
	
	var filteredSessions: [ScanningSession] {
		var sessions = scanningSessions
		
		// Фильтрация по времени
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
		
		// Фильтрация по поиску
		if !searchText.isEmpty {
			sessions = sessions.compactMap { [weak self] session in
				
				let filteredSession = ScanningSession()
				filteredSession.id = session.id
				filteredSession.startTime = session.startTime
				filteredSession.endTime = session.endTime
				
				let searchText = self?.searchText ?? ""
				
				let filteredDevices = session.devices.filter { device in
					device.name?.localizedCaseInsensitiveContains(searchText) == true ||
					device.ipAddress?.localizedCaseInsensitiveContains(searchText) == true ||
					device.macAddress?.localizedCaseInsensitiveContains(searchText) == true
				}
				
				guard !filteredDevices.isEmpty else { return nil }
				
				filteredSession.devices.append(objectsIn: filteredDevices)
				
				return filteredSession
			}
		}
		
		return sessions.sorted { $0.startTime > $1.startTime }
	}
	
	init() {
		loadSessions()
		setupLiveUpdates()
	}
	
	deinit {
		notificationToken?.invalidate()
	}
	
	private func setupLiveUpdates() {
		notificationToken = realmService.observeSessions { [weak self] sessions in
			self?.scanningSessions = sessions
		}
	}
	
	func loadSessions() {
		scanningSessions = realmService.getAllSessions()
	}
	
	func deleteSession(_ session: ScanningSession) {
		realmService.deleteSession(session)
	}
	
	func deleteAllHistory() {
		realmService.deleteAllData()
	}
	
	func refreshData() {
		loadSessions()
	}
}
