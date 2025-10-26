//
//  AppCoordinator.swift
//  Neighbor Scan
//
//  Created by Kirill Zolotarev on 25.10.2025.
//


import Foundation
import SwiftUI

@MainActor
final class AppCoordinator: ObservableObject {
	private let scannerViewModel: ScannerViewModel
	private let historyViewModel: HistoryViewModel
	
	init() {
		self.scannerViewModel = ScannerViewModel()
		self.historyViewModel = HistoryViewModel()
	}
	
	// MARK: - Root Views
	
	func makeMainView() -> MainView {
		return MainView(coordinator: self)
	}
	
	func makeDevicesTabView() -> DevicesTabView {
		return DevicesTabView(coordinator: self)
	}
	
	func makeHistoryView() -> HistoryView {
		return HistoryView(coordinator: self)
	}
	
	// MARK: - View Models
	
	func getScannerViewModel() -> ScannerViewModel {
		return scannerViewModel
	}
	
	func getHistoryViewModel() -> HistoryViewModel {
		return historyViewModel
	}
}
