//
//  RealmService.swift
//  Neighbor Scan
//
//  Created by Kirill Zolotarev on 25.10.2025.
//

import Foundation
import RealmSwift

@MainActor
final class RealmService: ObservableObject {
	
	// MARK: - Singleton
	static let shared = RealmService()
	
	// MARK: - Properties
	private var realm: Realm?
	
	@Published var errorMessage: String?
	
	// MARK: - Initialization
	private init() {
		setupRealm()
	}
	
	// MARK: - Setup
	private func setupRealm() {
		do {
			let config = Realm.Configuration(
				schemaVersion: 1,
				migrationBlock: { migration, oldSchemaVersion in
					if oldSchemaVersion < 1 {
						// Миграция при необходимости
					}
				}
			)
			
			Realm.Configuration.defaultConfiguration = config
			realm = try Realm()
			debugPrint("Realm initialized successfully at: \(Realm.Configuration.defaultConfiguration.fileURL!)")
			
		} catch {
			errorMessage = "Ошибка инициализации базы данных: \(error.localizedDescription)"
			debugPrint("Realm initialization error: \(error)")
		}
	}
	
	// MARK: - Thread-safe Helpers
	private func performWrite(_ block: @escaping (Realm) -> Void) {
		guard let realm = realm else {
			errorMessage = "Realm не инициализирован"
			return
		}
		
		do {
			try realm.write {
				block(realm)
			}
		} catch {
			errorMessage = "Ошибка записи: \(error.localizedDescription)"
		}
	}
	
	// MARK: - Device Operations
	func saveDevice(_ device: Device) {
		performWrite { realm in
			realm.add(device, update: .modified)
		}
	}
	
	func saveDevices(_ devices: [Device]) {
		performWrite { realm in
			realm.add(devices, update: .modified)
		}
	}
	
	func saveDevicesToSession(_ devices: [Device], session: ScanningSession) async {
		await MainActor.run {
			performWrite { realm in
				realm.add(devices, update: .modified)
				session.devices.append(objectsIn: devices)
				realm.add(session, update: .modified)
			}
			debugPrint("Устройства добавлены в сессию \(session.id): \(devices.count) устройств")
		}
	}
	
	func getAllDevices() -> [Device] {
		guard let realm = realm else { return [] }
		return Array(realm.objects(Device.self).sorted(byKeyPath: "timestamp", ascending: false))
	}
	
	func getDevices(ofType type: DeviceType) -> [Device] {
		guard let realm = realm else { return [] }
		return Array(realm.objects(Device.self)
			.filter("type == %@", type.rawValue)
			.sorted(byKeyPath: "timestamp", ascending: false))
	}
	
	func getDevices(in dateRange: ClosedRange<Date>, sortOrder: SortOrder = .descending) -> [Device] {
		guard let realm = realm else { return [] }
		return Array(realm.objects(Device.self)
			.filter("timestamp >= %@ AND timestamp <= %@", dateRange.lowerBound, dateRange.upperBound)
			.sorted(byKeyPath: "timestamp", ascending: sortOrder.realmSortAscending))
	}
	
	func deleteDevice(_ device: Device) {
		performWrite { realm in
			realm.delete(device)
		}
	}
	
	// MARK: - ScanningSession Operations
	func createSession() -> ScanningSession {
		let session = ScanningSession()
		saveSession(session)
		debugPrint("Создана сессия: \(session.id)")
		return session
	}
	
	func saveSession(_ session: ScanningSession) {
		performWrite { realm in
			realm.add(session, update: .modified)
		}
	}
	
	func completeSession(_ session: ScanningSession) {
		performWrite { realm in
			session.completeSession()
			realm.add(session, update: .modified)
			debugPrint("Сессия завершена: \(session.id), устройств: \(session.devices.count)")
		}
	}
	
	func getAllSessions() -> [ScanningSession] {
		guard let realm = realm else { return [] }
		let sessions = Array(realm.objects(ScanningSession.self).sorted(byKeyPath: "startTime", ascending: false))
		debugPrint("Загружено сессий: \(sessions.count)")
		for session in sessions {
			debugPrint("  Сессия \(session.id): \(session.devices.count) устройств")
		}
		return sessions
	}
	
	func getSession(by id: String) -> ScanningSession? {
		guard let realm = realm else { return nil }
		return realm.object(ofType: ScanningSession.self, forPrimaryKey: id)
	}
	
	func deleteSession(_ session: ScanningSession) {
		performWrite { realm in
			realm.delete(session.devices)
			realm.delete(session)
		}
	}
	
	func deleteAllData() {
		performWrite { realm in
			realm.deleteAll()
		}
	}
	
	// MARK: - Live Updates
	func observeDevices(_ callback: @escaping ([Device]) -> Void) -> NotificationToken? {
		guard let realm = realm else { return nil }
		
		let results = realm.objects(Device.self).sorted(byKeyPath: "timestamp", ascending: false)
		
		return results.observe { changes in
			switch changes {
			case .initial(let devices), .update(let devices, _, _, _):
				callback(Array(devices))
			case .error(let error):
				self.errorMessage = "Ошибка наблюдения: \(error.localizedDescription)"
			}
		}
	}
	
	func observeSessions(_ callback: @escaping ([ScanningSession]) -> Void) -> NotificationToken? {
		guard let realm = realm else { return nil }
		
		let results = realm.objects(ScanningSession.self).sorted(byKeyPath: "startTime", ascending: false)
		
		return results.observe { changes in
			switch changes {
			case .initial(let sessions), .update(let sessions, _, _, _):
				debugPrint("Обновление сессий: \(sessions.count) сессий")
				for session in sessions {
					debugPrint("  Сессия \(session.id): \(session.devices.count) устройств")
				}
				callback(Array(sessions))
			case .error(let error):
				self.errorMessage = "Ошибка наблюдения: \(error.localizedDescription)"
			}
		}
	}
}
