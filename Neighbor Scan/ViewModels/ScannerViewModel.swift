//
//  ScannerViewModel.swift
//  Neighbor Scan
//
//  Created by Kirill Zolotarev on 25.10.2025.
//


import Foundation
import Combine
import SwiftUI
import RealmSwift

class ScannerViewModel: ObservableObject {
	private let bluetoothService = BluetoothService()
	private let lanScanService = LANScanService()
	private let realmService = RealmService.shared
	private var cancellables = Set<AnyCancellable>()
	private var currentSession: ScanningSession?
	
	@Published var bluetoothDevices: [Device] = []
	@Published var lanDevices: [Device] = []
	@Published var isScanning = false
	@Published var scanProgress: Double = 0.0
	@Published var errorMessage: String?
	@Published var showAlert = false
	@Published var showCompletionAlert = false
	@Published var foundDevicesCount = 0
	var isCanceled = false
	
	var allDevices: [Device] {
		return bluetoothDevices + lanDevices
	}
	
	var bluetoothDevicesCount: Int {
		return bluetoothDevices.count
	}
	
	var lanDevicesCount: Int {
		return lanDevices.count
	}
	
	init() {
		setupBindings()
	}
	
	private func setupBindings() {
		bluetoothService.$discoveredDevices
			.sink { [weak self] devices in
				self?.bluetoothDevices = devices
				self?.saveDevicesToRealm(devices)
			}
			.store(in: &cancellables)
		
		lanScanService.$discoveredDevices
			.sink { [weak self] devices in
				self?.lanDevices = devices
				self?.saveDevicesToRealm(devices)
			}
			.store(in: &cancellables)
		
		bluetoothService.$isScanning
			.combineLatest(lanScanService.$isScanning)
			.map { $0 || $1 }
			.sink { [weak self] isScanning in
				self?.isScanning = isScanning
				if !isScanning && self?.currentSession != nil {
					self?.completeScanningSession()
				}
			}
			.store(in: &cancellables)
		
		lanScanService.$progress
			.assign(to: \.scanProgress, on: self)
			.store(in: &cancellables)
		
		Publishers.Merge(
			bluetoothService.$errorMessage,
			lanScanService.$errorMessage
		)
		.compactMap { $0 }
		.sink { [weak self] error in
			self?.errorMessage = error
			self?.showAlert = true
		}
		.store(in: &cancellables)
		
		Publishers.CombineLatest($bluetoothDevices, $lanDevices)
			.map { $0.count + $1.count }
			.assign(to: \.foundDevicesCount, on: self)
			.store(in: &cancellables)
	}
	
	func startScanning() {
		isCanceled = false
		currentSession = realmService.createSession()
		bluetoothService.startScanning()
		lanScanService.startScanning()
	}
	
	func stopScanning() {
		isCanceled = true
		bluetoothService.stopScanning()
		lanScanService.stopScanning()
	}
	
	func clearCurrentScanResults() {
		bluetoothDevices.removeAll()
		lanDevices.removeAll()
	}
	
	/*
	private func saveDevicesToRealm(_ devices: [Device]) {
		guard let session = currentSession else { return }
		
		realmService.saveDevices(devices)
		
		do {
			let realm = try Realm()
			try realm.write {
				devices.forEach { device in
					if !session.devices.contains(where: { $0.id == device.id }) {
						session.devices.append(device)
					}
				}
			}
		} catch {
			errorMessage = "Ошибка сохранения в базу данных: \(error.localizedDescription)"
		}
	}
	
	private func completeScanningSession() {
		guard let session = currentSession else { return }
		realmService.completeSession(session)
		currentSession = nil
		showCompletionAlert = !isCanceled
	}
	 */
	
	
	private func saveDevicesToRealm(_ devices: [Device]) {
		guard let session = currentSession else { return }
		
		realmService.saveDevices(devices) { [weak self] error in
			if let error = error {
				DispatchQueue.main.async {
					self?.errorMessage = "Ошибка сохранения в базу данных: \(error.localizedDescription)"
				}
				return
			}
			
			// Добавляем устройства в текущую сессию
			self?.realmService.performInBackground { realm in
				guard let sessionInBackground = realm.object(ofType: ScanningSession.self, forPrimaryKey: session.id) else {
					throw RealmError.queryFailed
				}
				
				try realm.write {
					devices.forEach { device in
						if !sessionInBackground.devices.contains(where: { $0.id == device.id }) {
							sessionInBackground.devices.append(device)
						}
					}
				}
			} completion: { result in
				switch result {
				case .success:
					break
				case .failure(let error):
					DispatchQueue.main.async {
						self?.errorMessage = "Ошибка добавления устройств в сессию: \(error.localizedDescription)"
					}
				}
			}
		}
	}
	
	private func completeScanningSession() {
		guard let session = currentSession else { return }
		
		realmService.completeSession(session) { [weak self] error in
			if let error = error {
				DispatchQueue.main.async {
					self?.errorMessage = "Ошибка завершения сессии: \(error.localizedDescription)"
				}
			} else {
				DispatchQueue.main.async {
					self?.currentSession = nil
					self?.showCompletionAlert = true
				}
			}
		}
	}
	
	func getDevices(for filter: DeviceTypeFilter) -> [Device] {
		switch filter {
		case .all: return allDevices
		case .bluetooth: return bluetoothDevices
		case .lan: return lanDevices
		}
	}
}
