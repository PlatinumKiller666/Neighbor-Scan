//
//  LANScanService.swift
//  Neighbor Scan
//
//  Created by Kirill Zolotarev on 25.10.2025.
//


import Foundation
import Combine
import MMLanScan
import Network


class LANScanService: NSObject, ObservableObject, MMLANScannerDelegate {
	
	private lazy var monitor: NWPathMonitor? = NWPathMonitor()

	
	func lanScanDidFindNewDevice(_ device: MMDevice!) {
		let newDevice = Device(
				type: .lan,
				name: device.hostname,
				ipAddress: device.ipAddress,
				macAddress: device.macAddress,
				timestamp: Date()
			)
		discoveredDevices.append(newDevice)
	}
	
	func lanScanDidFinishScanning(with status: MMLanScannerStatus) {
		lanScanner?.stop()
		isScanning = false
	}
	
	func lanScanDidFailedToScan() {
		errorMessage = "Проблемы с LAN"
		isScanning = false
	}
	
	@Published var discoveredDevices: [Device] = []
	@Published var isScanning = false
	@Published var errorMessage: String?
	@Published var progress: Double = 0.0
	private lazy var lanScanner = MMLANScanner(delegate:self)
	
	
	func startScanning() {
		monitor?.pathUpdateHandler = {[weak self] path in
			guard let self = self else { return }
				if path.status == .satisfied {
					// Network is available
					if path.usesInterfaceType(.wifi) {
						self.errorMessage = nil
						self.discoveredDevices.removeAll()
						self.isScanning = true
						self.lanScanner?.start()
					} else {
						self.errorMessage = "Please, turnOn WiFi.".localized()
					}
				} else {
					debugPrint("No network connection.")
				}
			}
		errorMessage = ""
		discoveredDevices.removeAll()
		isScanning = true
		lanScanner?.start()
	}
	
	func stopScanning() {
		lanScanner?.stop()
		isScanning = false
	}
}
