//
//  LANScanService.swift
//  Neighbor Scan
//
//  Created by Kirill Zolotarev on 25.10.2025.
//


import Foundation
import Combine

class LANScanService: ObservableObject {
	@Published var discoveredDevices: [Device] = []
	@Published var isScanning = false
	@Published var errorMessage: String?
	@Published var progress: Double = 0.0
	
	private var scanner: LANScanner?
	
	func startScanning() {
		discoveredDevices.removeAll()
		isScanning = true
		progress = 0.0
		
		scanner = LANScanner()
		scanner?.onDeviceDiscovered = { [weak self] device in
			self?.discoveredDevices.append(device)
			self?.progress = Double(self?.discoveredDevices.count ?? 0) / 254.0
		}
		
		scanner?.onScanFinished = { [weak self] in
			self?.isScanning = false
			self?.progress = 1.0
		}
		
		scanner?.startScan()
		
		DispatchQueue.main.asyncAfter(deadline: .now() + 15) {
			self.stopScanning()
		}
	}
	
	func stopScanning() {
		scanner?.stopScan()
		isScanning = false
	}
}

class LANScanner {
	var onDeviceDiscovered: ((Device) -> Void)?
	var onScanFinished: (() -> Void)?
	private var isScanning = false
	
	func startScan() {
		isScanning = true
		
		DispatchQueue.global(qos: .background).async {
			for i in 1...254 {
				guard self.isScanning else { break }
				
				if i % 10 == 0 {
					let device = Device(
						type: .lan,
						name: "Устройство \(i)",
						ipAddress: "192.168.1.\(i)",
						macAddress: "00:1B:44:11:3A:B\(i % 10)",
						timestamp: Date()
					)
					
					DispatchQueue.main.async {
						self.onDeviceDiscovered?(device)
					}
				}
				
				usleep(100000)
			}
			
			DispatchQueue.main.async {
				self.onScanFinished?()
			}
		}
	}
	
	func stopScan() {
		isScanning = false
	}
}
