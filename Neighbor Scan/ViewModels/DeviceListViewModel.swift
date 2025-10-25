//
//  DeviceListViewModel.swift
//  Neighbor Scan
//
//  Created by Kirill Zolotarev on 25.10.2025.
//

/*
 import Foundation
 import RealmSwift
 import Combine

 class DeviceListViewModel: ObservableObject {
	 @Published var filteredDevices: [Device] = []
	 @Published var isLoading = false
	 
	 private let realmService = RealmService.shared
	 private var notificationToken: NotificationToken?
	 
	 init() {
		 setupRealmObserver()
	 }
	 
	 deinit {
		 notificationToken?.invalidate()
	 }
	 
	 private func setupRealmObserver() {
		 guard let allDevices = realmService.getAllDevices() else { return }
		 
		 notificationToken = allDevices.observe { [weak self] changes in
			 switch changes {
			 case .initial(let results):
				 self?.filteredDevices = Array(results)
			 case .update(let results, _, _, _):
				 self?.filteredDevices = Array(results)
			 case .error(let error):
				 print("Ошибка наблюдения за устройствами: \(error)")
			 }
		 }
	 }
	 
	 func applyFilters(deviceType: DeviceTypeFilter, dateRange: ClosedRange<Date>, sortOrder: SortOrder) {
		 isLoading = true
		 
		 DispatchQueue.global(qos: .userInitiated).async {
			 var results: Results<Device>?
			 
			 results = self.realmService.getDevices(in: dateRange, sortOrder: sortOrder)
			 
			 if deviceType != .all {
				 let typeFilter: DeviceType = (deviceType == .bluetooth) ? .bluetooth : .lan
				 results = results?.filter("type == %@", typeFilter.rawValue)
			 }
			 
			 DispatchQueue.main.async {
				 if let finalResults = results {
					 self.filteredDevices = Array(finalResults)
				 }
				 self.isLoading = false
			 }
		 }
	 }
 }
 */

import Foundation
import RealmSwift
import Combine

class DeviceListViewModel: ObservableObject {
	@Published var filteredDevices: [Device] = []
	@Published var isLoading = false
	@Published var errorMessage: String?
	
	private let realmService = RealmService()
	private var notificationToken: NotificationToken?
	private var cancellables = Set<AnyCancellable>()
	
	init() {
		setupRealmObserver()
	}
	
	deinit {
		notificationToken?.invalidate()
	}
	
	private func setupRealmObserver() {
		realmService.getAllDevices { [weak self] results in
			guard let results = results else { return }
			
			self?.notificationToken = results.observe { [weak self] changes in
				switch changes {
				case .initial(let devices):
					self?.filteredDevices = Array(devices)
				case .update(let devices, _, _, _):
					self?.filteredDevices = Array(devices)
				case .error(let error):
					self?.errorMessage = "Ошибка наблюдения за устройствами: \(error.localizedDescription)"
				}
			}
		}
	}
	
	func applyFilters(deviceType: DeviceTypeFilter, dateRange: ClosedRange<Date>, sortOrder: SortOrder) {
		isLoading = true
		errorMessage = nil
		
		realmService.getDevices(in: dateRange, sortOrder: sortOrder) { [weak self] results in
			guard let self = self, let results = results else {
				DispatchQueue.main.async {
					self?.isLoading = false
				}
				return
			}
			
			var filteredResults = results
			
			if deviceType != .all {
				let typeFilter: DeviceType = (deviceType == .bluetoothOnly) ? .bluetooth : .lan
				filteredResults = filteredResults.filter("type == %@", typeFilter.rawValue)
			}
			
			DispatchQueue.main.async {
				self.filteredDevices = Array(filteredResults)
				self.isLoading = false
			}
		}
	}
	
	func refreshData() {
		applyFilters(deviceType: .all,
					dateRange: Date().addingTimeInterval(-7 * 24 * 3600)...Date(),
					sortOrder: .descending)
	}
}
