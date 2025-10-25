//
//  BluetoothService.swift
//  Neighbor Scan
//
//  Created by Kirill Zolotarev on 25.10.2025.
//


import Foundation
import CoreBluetooth
import Combine

class BluetoothService: NSObject, ObservableObject {
	private var centralManager: CBCentralManager?
	@Published var discoveredDevices: [Device] = []
	@Published var isScanning = false
	@Published var errorMessage: String?
	
	override init() {
		super.init()
		self.centralManager = CBCentralManager(delegate: self, queue: .main)
	}
	
	func startScanning() {
		guard let central = centralManager, central.state == .poweredOn else {
			errorMessage = "Bluetooth недоступен. Пожалуйста, включите Bluetooth."
			return
		}
		
		discoveredDevices.removeAll()
		isScanning = true
		
		central.scanForPeripherals(withServices: nil, options: [CBCentralManagerScanOptionAllowDuplicatesKey: false])
		
		DispatchQueue.main.asyncAfter(deadline: .now() + 15) {
			self.stopScanning()
		}
	}
	
	func stopScanning() {
		centralManager?.stopScan()
		isScanning = false
	}
}

extension BluetoothService: CBCentralManagerDelegate {
	func centralManagerDidUpdateState(_ central: CBCentralManager) {
		switch central.state {
		case .poweredOn:
			print("Bluetooth включен")
		case .poweredOff:
			errorMessage = "Bluetooth выключен"
		case .unauthorized:
			errorMessage = "Нет разрешения на использование Bluetooth"
		case .unsupported:
			errorMessage = "Bluetooth не поддерживается"
		default:
			break
		}
	}
	
	func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String : Any], rssi RSSI: NSNumber) {
		let device = Device(
			type: .bluetooth,
			name: peripheral.name ?? "Неизвестное устройство",
			uuid: peripheral.identifier.uuidString,
			rssi: RSSI.intValue,
			status: peripheral.state == .connected ? "Подключено" : "Доступно",
			timestamp: Date()
		)
		
		if !discoveredDevices.contains(where: { $0.uuid == device.uuid }) {
			discoveredDevices.append(device)
		}
	}
}
