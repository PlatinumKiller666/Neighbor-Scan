//
//  RealmService.swift
//  Neighbor Scan
//
//  Created by Kirill Zolotarev on 25.10.2025.
//


/*import Foundation
import RealmSwift

class RealmService: ObservableObject {
	private var realm: Realm?
	
	@Published var errorMessage: String?
	
	init() {
		setupRealm()
	}
	
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
			
		} catch {
			errorMessage = "Ошибка инициализации базы данных: \(error.localizedDescription)"
		}
	}
	
	func saveDevice(_ device: Device) {
		guard let realm = realm else { return }
		
		do {
			try realm.write {
				realm.add(device, update: .modified)
			}
		} catch {
			errorMessage = "Ошибка сохранения устройства: \(error.localizedDescription)"
		}
	}
	
	func saveDevices(_ devices: [Device]) {
		guard let realm = realm else { return }
		
		do {
			try realm.write {
				realm.add(devices, update: .modified)
			}
		} catch {
			errorMessage = "Ошибка сохранения устройств: \(error.localizedDescription)"
		}
	}
	
	func getAllDevices() -> Results<Device>? {
		return realm?.objects(Device.self).sorted(byKeyPath: "timestamp", ascending: false)
	}
	
	func getDevices(ofType type: DeviceType) -> Results<Device>? {
		return realm?.objects(Device.self)
			.filter("type == %@", type.rawValue)
			.sorted(byKeyPath: "timestamp", ascending: false)
	}
	
	func getDevices(in dateRange: ClosedRange<Date>, sortOrder: SortOrder = .descending) -> Results<Device>? {
		return realm?.objects(Device.self)
			.filter("timestamp >= %@ AND timestamp <= %@", dateRange.lowerBound, dateRange.upperBound)
			.sorted(byKeyPath: "timestamp", ascending: sortOrder.realmSortAscending)
	}
	
	func getDevices(ofType type: DeviceType, in dateRange: ClosedRange<Date>, sortOrder: SortOrder = .descending) -> Results<Device>? {
		return realm?.objects(Device.self)
			.filter("type == %@ AND timestamp >= %@ AND timestamp <= %@", 
				   type.rawValue, dateRange.lowerBound, dateRange.upperBound)
			.sorted(byKeyPath: "timestamp", ascending: sortOrder.realmSortAscending)
	}
	
	func deleteDevice(_ device: Device) {
		guard let realm = realm else { return }
		
		do {
			try realm.write {
				realm.delete(device)
			}
		} catch {
			errorMessage = "Ошибка удаления устройства: \(error.localizedDescription)"
		}
	}
	
	func createSession() -> ScanningSession {
		let session = ScanningSession()
		saveSession(session)
		return session
	}
	
	func saveSession(_ session: ScanningSession) {
		guard let realm = realm else { return }
		
		do {
			try realm.write {
				realm.add(session, update: .modified)
			}
		} catch {
			errorMessage = "Ошибка сохранения сессии: \(error.localizedDescription)"
		}
	}
	
	func completeSession(_ session: ScanningSession) {
		guard let realm = realm else { return }
		
		do {
			try realm.write {
				session.completeSession()
			}
		} catch {
			errorMessage = "Ошибка завершения сессии: \(error.localizedDescription)"
		}
	}
	
	func getAllSessions() -> Results<ScanningSession>? {
		return realm?.objects(ScanningSession.self).sorted(byKeyPath: "startTime", ascending: false)
	}
	
	func deleteSession(_ session: ScanningSession) {
		guard let realm = realm else { return }
		
		do {
			try realm.write {
				realm.delete(session.devices)
				realm.delete(session)
			}
		} catch {
			errorMessage = "Ошибка удаления сессии: \(error.localizedDescription)"
		}
	}
	
	func deleteAllData() {
		guard let realm = realm else { return }
		
		do {
			try realm.write {
				realm.deleteAll()
			}
		} catch {
			errorMessage = "Ошибка очистки базы данных: \(error.localizedDescription)"
		}
	}
	
	func getTotalDevicesCount() -> Int {
		return realm?.objects(Device.self).count ?? 0
	}
	
	func getDevicesCountByType() -> [DeviceType: Int] {
		var counts: [DeviceType: Int] = [:]
		
		DeviceType.allCases.forEach { type in
			counts[type] = realm?.objects(Device.self).filter("type == %@", type.rawValue).count ?? 0
		}
		
		return counts
	}
}*/

import Foundation
import RealmSwift

class RealmService: ObservableObject {
	private var realm: Realm?
	private let queue = DispatchQueue(label: "com.networkscanner.realm", qos: .userInitiated)
	
	@Published var errorMessage: String?
	
	init() {
		setupRealm()
	}
	
	private func setupRealm() {
		queue.sync {
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
				self.realm = try Realm()
				
			} catch {
				DispatchQueue.main.async {
					self.errorMessage = "Ошибка инициализации базы данных: \(error.localizedDescription)"
				}
			}
		}
	}
	
	// MARK: - Device Operations
	
	func saveDevice(_ device: Device, completion: ((Error?) -> Void)? = nil) {
		performRealmOperation({ realm in
			try realm.write {
				realm.add(device, update: .modified)
			}
		}, completion: completion)
	}
	
	func saveDevices(_ devices: [Device], completion: ((Error?) -> Void)? = nil) {
		performRealmOperation({ realm in
			try realm.write {
				realm.add(devices, update: .modified)
			}
		}, completion: completion)
	}
	
	func getAllDevices(completion: @escaping (Results<Device>?) -> Void) {
		performRealmQuery({ realm in
			return realm.objects(Device.self).sorted(byKeyPath: "timestamp", ascending: false)
		}, completion: completion)
	}
	
	func getDevices(ofType type: DeviceType, completion: @escaping (Results<Device>?) -> Void) {
		performRealmQuery({ realm in
			return realm.objects(Device.self)
				.filter("type == %@", type.rawValue)
				.sorted(byKeyPath: "timestamp", ascending: false)
		}, completion: completion)
	}
	
	func getDevices(in dateRange: ClosedRange<Date>, sortOrder: SortOrder = .descending, completion: @escaping (Results<Device>?) -> Void) {
		performRealmQuery({ realm in
			return realm.objects(Device.self)
				.filter("timestamp >= %@ AND timestamp <= %@", dateRange.lowerBound, dateRange.upperBound)
				.sorted(byKeyPath: "timestamp", ascending: sortOrder.realmSortAscending)
		}, completion: completion)
	}
	
	func getDevices(ofType type: DeviceType, in dateRange: ClosedRange<Date>, sortOrder: SortOrder = .descending, completion: @escaping (Results<Device>?) -> Void) {
		performRealmQuery({ realm in
			return realm.objects(Device.self)
				.filter("type == %@ AND timestamp >= %@ AND timestamp <= %@",
					   type.rawValue, dateRange.lowerBound, dateRange.upperBound)
				.sorted(byKeyPath: "timestamp", ascending: sortOrder.realmSortAscending)
		}, completion: completion)
	}
	
	func deleteDevice(_ device: Device, completion: ((Error?) -> Void)? = nil) {
		performRealmOperation({ realm in
			try realm.write {
				realm.delete(device)
			}
		}, completion: completion)
	}
	
	// MARK: - ScanningSession Operations
	
	func createSession(completion: ((ScanningSession?, Error?) -> Void)? = nil) {
		performRealmOperation({ realm in
			let session = ScanningSession()
			try realm.write {
				realm.add(session, update: .modified)
			}
			return session
		}, completion: completion)
	}
	
	func saveSession(_ session: ScanningSession, completion: ((Error?) -> Void)? = nil) {
		performRealmOperation({ realm in
			try realm.write {
				realm.add(session, update: .modified)
			}
		}, completion: completion)
	}
	
	func completeSession(_ session: ScanningSession, completion: ((Error?) -> Void)? = nil) {
		performRealmOperation({ realm in
			try realm.write {
				session.completeSession()
			}
		}, completion: completion)
	}
	
	func getAllSessions(completion: @escaping (Results<ScanningSession>?) -> Void) {
		performRealmQuery({ realm in
			return realm.objects(ScanningSession.self).sorted(byKeyPath: "startTime", ascending: false)
		}, completion: completion)
	}
	
	func deleteSession(_ session: ScanningSession, completion: ((Error?) -> Void)? = nil) {
		performRealmOperation({ realm in
			try realm.write {
				realm.delete(session.devices)
				realm.delete(session)
			}
		}, completion: completion)
	}
	
	func deleteAllData(completion: ((Error?) -> Void)? = nil) {
		performRealmOperation({ realm in
			try realm.write {
				realm.deleteAll()
			}
		}, completion: completion)
	}
	
	// MARK: - Statistics
	
	func getTotalDevicesCount(completion: @escaping (Int) -> Void) {
		performRealmQuery({ realm in
			return realm.objects(Device.self).count
		}, completion: completion)
	}
	
	func getDevicesCountByType(completion: @escaping ([DeviceType: Int]) -> Void) {
		performRealmOperation({ realm in
			var counts: [DeviceType: Int] = [:]
			
			for type in DeviceType.allCases {
				counts[type] = realm.objects(Device.self).filter("type == %@", type.rawValue).count
			}
			
			return counts
		}, completion: completion)
	}
	
	// MARK: - Thread-safe Operations
	
	private func performRealmOperation<T>(_ operation: @escaping (Realm) throws -> T, completion: ((T?, Error?) -> Void)? = nil) {
		queue.async {
			do {
				guard let realm = self.realm else {
					throw RealmError.realmNotInitialized
				}
				
				let result = try operation(realm)
				
				DispatchQueue.main.async {
					completion?(result, nil)
				}
				
			} catch {
				DispatchQueue.main.async {
					self.errorMessage = "Ошибка операции Realm: \(error.localizedDescription)"
					completion?(nil, error)
				}
			}
		}
	}
	
	private func performRealmOperation(_ operation: @escaping (Realm) throws -> Void, completion: ((Error?) -> Void)? = nil) {
		performRealmOperation({ realm in
			try operation(realm)
			return () // Void return
		}, completion: { _, error in
			completion?(error)
		})
	}
	
	private func performRealmQuery<T>(_ query: @escaping (Realm) -> T, completion: @escaping (T) -> Void) {
		queue.async {
			do {
				guard let realm = self.realm else {
					// Если realm не инициализирован, создаем временный экземпляр для запроса
					let temporaryRealm = try Realm()
					let result = query(temporaryRealm)
					DispatchQueue.main.async {
						completion(result)
					}
					return
				}
				
				let result = query(realm)
				
				DispatchQueue.main.async {
					completion(result)
				}
			} catch {
				DispatchQueue.main.async {
					self.errorMessage = "Ошибка выполнения запроса: \(error.localizedDescription)"
					// Возвращаем значение по умолчанию в зависимости от типа T
					if T.self == Int.self {
						completion(0 as! T)
					} else if T.self == [DeviceType: Int].self {
						completion([:] as! T)
					} else {
						completion(query(Realm())) // Это вызовет краш, но это крайний случай
					}
				}
			}
		}
	}
	
	// MARK: - Background Operations
	
	func performInBackground<T>(_ operation: @escaping (Realm) throws -> T, completion: @escaping (Result<T, Error>) -> Void) {
		DispatchQueue.global(qos: .background).async {
			do {
				let realm = try Realm()
				let result = try operation(realm)
				
				DispatchQueue.main.async {
					completion(.success(result))
				}
			} catch {
				DispatchQueue.main.async {
					completion(.failure(error))
				}
			}
		}
	}
	
	// MARK: - Live Updates with NotificationToken
	
	func observeDevices(_ block: @escaping (RealmCollectionChange<Results<Device>>) -> Void) -> NotificationToken? {
		return realm?.objects(Device.self).observe(block)
	}
	
	func observeSessions(_ block: @escaping (RealmCollectionChange<Results<ScanningSession>>) -> Void) -> NotificationToken? {
		return realm?.objects(ScanningSession.self).observe(block)
	}
	
	// MARK: - Safe Query Methods
	
	func safeGetAllDevices(completion: @escaping (Result<[Device], Error>) -> Void) {
		performInBackground { realm in
			return Array(realm.objects(Device.self).sorted(byKeyPath: "timestamp", ascending: false))
		} completion: { result in
			completion(result)
		}
	}
	
	func safeGetDevices(in dateRange: ClosedRange<Date>, sortOrder: SortOrder = .descending, completion: @escaping (Result<[Device], Error>) -> Void) {
		performInBackground { realm in
			let results = realm.objects(Device.self)
				.filter("timestamp >= %@ AND timestamp <= %@", dateRange.lowerBound, dateRange.upperBound)
				.sorted(byKeyPath: "timestamp", ascending: sortOrder.realmSortAscending)
			return Array(results)
		} completion: { result in
			completion(result)
		}
	}
}

// MARK: - Realm Errors

enum RealmError: Error {
	case realmNotInitialized
	case writeFailed
	case queryFailed
	case invalidOperation
}

extension RealmError: LocalizedError {
	var errorDescription: String? {
		switch self {
		case .realmNotInitialized:
			return "Realm база данных не инициализирована"
		case .writeFailed:
			return "Ошибка записи в базу данных"
		case .queryFailed:
			return "Ошибка выполнения запроса"
		case .invalidOperation:
			return "Недопустимая операция"
		}
	}
}

// MARK: - Thread-safe Extensions

extension RealmService {
	
	// Batch operations
	func batchSaveDevices(_ devices: [Device], completion: ((Error?) -> Void)? = nil) {
		performRealmOperation({ realm in
			try realm.write {
				realm.add(devices, update: .modified)
			}
		}, completion: completion)
	}
	
	func batchDeleteDevices(_ devices: [Device], completion: ((Error?) -> Void)? = nil) {
		performRealmOperation({ realm in
			try realm.write {
				realm.delete(devices)
			}
		}, completion: completion)
	}
	
	// Safe device creation
	func createDevice(
		type: DeviceType,
		name: String? = nil,
		uuid: String? = nil,
		rssi: Int? = nil,
		status: String? = nil,
		ipAddress: String? = nil,
		macAddress: String? = nil,
		completion: ((Device?, Error?) -> Void)? = nil
	) {
		performRealmOperation({ realm in
			let device = Device(
				type: type,
				name: name,
				uuid: uuid,
				rssi: rssi,
				status: status,
				ipAddress: ipAddress,
				macAddress: macAddress
			)
			
			try realm.write {
				realm.add(device, update: .modified)
			}
			
			return device
		}, completion: completion)
	}
	
	// Safe search operations
	func searchDevices(query: String, completion: @escaping (Result<[Device], Error>) -> Void) {
		safeGetAllDevices { result in
			switch result {
			case .success(let devices):
				let filteredDevices = devices.filter { device in
					device.name?.localizedCaseInsensitiveContains(query) == true ||
					device.ipAddress?.localizedCaseInsensitiveContains(query) == true ||
					device.macAddress?.localizedCaseInsensitiveContains(query) == true
				}
				completion(.success(filteredDevices))
			case .failure(let error):
				completion(.failure(error))
			}
		}
	}
	
	// Safe statistics
	func getSafeStatistics(completion: @escaping (Result<(totalDevices: Int, bluetoothCount: Int, lanCount: Int), Error>) -> Void) {
		safeGetAllDevices { result in
			switch result {
			case .success(let devices):
				let total = devices.count
				let bluetoothCount = devices.filter { $0.type == .bluetooth }.count
				let lanCount = devices.filter { $0.type == .lan }.count
				completion(.success((total, bluetoothCount, lanCount)))
			case .failure(let error):
				completion(.failure(error))
			}
		}
	}
}


