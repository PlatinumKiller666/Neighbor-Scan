//
//  Device.swift
//  Neighbor Scan
//
//  Created by Kirill Zolotarev on 25.10.2025.
//


import Foundation
import RealmSwift

class Device: Object, ObjectKeyIdentifiable {
	@Persisted(primaryKey: true) var id: String = UUID().uuidString
	@Persisted var type: DeviceType
	@Persisted var name: String?
	@Persisted var uuid: String?
	@Persisted var rssi: Int?
	@Persisted var status: String?
	@Persisted var ipAddress: String?
	@Persisted var macAddress: String?
	@Persisted var timestamp: Date
	
	convenience init(
		type: DeviceType,
		name: String? = nil,
		uuid: String? = nil,
		rssi: Int? = nil,
		status: String? = nil,
		ipAddress: String? = nil,
		macAddress: String? = nil,
		timestamp: Date = Date()
	) {
		self.init()
		self.type = type
		self.name = name
		self.uuid = uuid
		self.rssi = rssi
		self.status = status
		self.ipAddress = ipAddress
		self.macAddress = macAddress
		self.timestamp = timestamp
	}
}

class ScanningSession: Object, ObjectKeyIdentifiable {
	@Persisted(primaryKey: true) var id: String = UUID().uuidString
	@Persisted var startTime: Date = Date()
	@Persisted var endTime: Date?
	@Persisted var devices: RealmSwift.List<Device>
	
	var duration: TimeInterval {
		return (endTime ?? Date()).timeIntervalSince(startTime)
	}
	
	var devicesCount: Int {
		return devices.count
	}
	
	convenience init(startTime: Date = Date(), devices: [Device] = []) {
		self.init()
		self.startTime = startTime
		self.devices.append(objectsIn: devices)
	}
	
	func addDevice(_ device: Device) {
		devices.append(device)
	}
	
	func completeSession() {
		endTime = Date()
	}
}
