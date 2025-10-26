//
//  ScannerViewModel.swift
//  Neighbor Scan
//
//  Created by Kirill Zolotarev on 25.10.2025.
//

import Foundation
import Combine
import SwiftUI

@MainActor
final class ScannerViewModel: ObservableObject {
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
	
	var allDevices: [Device] {
		return bluetoothDevices + lanDevices
	}
	
	init() {
		setupBindings()
	}
	
	private func setupBindings() {
		bluetoothService.$discoveredDevices
			.receive(on: DispatchQueue.main)
			.sink { [weak self] devices in
				Task { @MainActor in
					self?.bluetoothDevices = devices
					await self?.saveDevicesToSession(devices)
				}
			}
			.store(in: &cancellables)
		
		lanScanService.$discoveredDevices
			.receive(on: DispatchQueue.main)
			.sink { [weak self] devices in
				Task { @MainActor in
					self?.lanDevices = devices
					await self?.saveDevicesToSession(devices)
				}
			}
			.store(in: &cancellables)
		
		bluetoothService.$isScanning
			.combineLatest(lanScanService.$isScanning)
			.receive(on: DispatchQueue.main)
			.map { $0 || $1 }
			.sink { [weak self] isScanning in
				self?.isScanning = isScanning
				if !isScanning && self?.currentSession != nil {
					Task { @MainActor in
						await self?.completeScanningSession()
					}
				}
			}
			.store(in: &cancellables)
		
		lanScanService.$progress
			.receive(on: DispatchQueue.main)
			.assign(to: \.scanProgress, on: self)
			.store(in: &cancellables)
		
		Publishers.Merge(
			bluetoothService.$errorMessage,
			lanScanService.$errorMessage
		)
		.compactMap { $0 }
		.receive(on: DispatchQueue.main)
		.sink { [weak self] error in
			if !error.isEmpty {
				self?.errorMessage = error
				self?.showAlert = true
			}
		}
		.store(in: &cancellables)
		
		Publishers.CombineLatest($bluetoothDevices, $lanDevices)
			.receive(on: DispatchQueue.main)
			.map { $0.count + $1.count }
			.assign(to: \.foundDevicesCount, on: self)
			.store(in: &cancellables)
	}
	
	func startScanning() {
		Task { @MainActor in
			currentSession = realmService.createSession()
			debugPrint("Создана новая сессия: \(currentSession?.id ?? "unknown")")
			
			bluetoothService.startScanning()
			lanScanService.startScanning()
		}
	}
	
	func stopScanning() {
		bluetoothService.stopScanning()
		lanScanService.stopScanning()
	}
	
	func clearCurrentScanResults() {
		bluetoothDevices.removeAll()
		lanDevices.removeAll()
	}
	
	private func saveDevicesToSession(_ devices: [Device]) async {
		guard let session = currentSession else {
			debugPrint("Ошибка: нет активной сессии для сохранения устройств")
			return
		}
		await realmService.saveDevicesToSession(devices, session: session)
	}
	
	private func completeScanningSession() async {
		guard let session = currentSession else { return }
		realmService.completeSession(session)
		debugPrint("Сессия завершена: \(session.id), устройств: \(session.devices.count)")
		currentSession = nil
		showCompletionAlert = true
	}
	
	func getDevices(for filter: DeviceTypeFilter) -> [Device] {
		switch filter {
		case .all: return allDevices
		case .bluetooth: return bluetoothDevices
		case .lan: return lanDevices
		}
	}
}

