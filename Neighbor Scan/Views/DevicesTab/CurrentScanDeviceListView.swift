//
//  CurrentScanDeviceListView.swift
//  Neighbor Scan
//
//  Created by Kirill Zolotarev on 25.10.2025.
//


import SwiftUI

struct CurrentScanDeviceListView: View {
	@ObservedObject var coordinator: AppCoordinator
	let deviceTypeFilter: DeviceTypeFilter
	let sortOrder: SortOrder
	
	@EnvironmentObject var scannerViewModel: ScannerViewModel
	
	var body: some View {
		Group {
			if scannerViewModel.isScanning && filteredDevices.isEmpty {
				ScanningInProgressView()
			} else if filteredDevices.isEmpty {
				EmptyCurrentScanView(filter: deviceTypeFilter)
			} else {
//				EmptyView()
				List {
					Section {
						EmptyView()
						ForEach(sortedDevices) { device in
						 NavigationLink(destination: DeviceDetailView(device: device)) {
							 DeviceRow(
								 device: device,
								 showDeviceType: deviceTypeFilter == .all,
								 sortOrder: sortOrder
							 )
						 }
					 }
					} header: {
						CurrentScanHeaderView(
							deviceCount: filteredDevices.count,
							sortOrder: sortOrder,
							isScanning: scannerViewModel.isScanning
						)
					}
					
					EmptyView().frame(height: 25+24+16)
				}
				.listStyle(GroupedListStyle())
			}
		}
	}
	
	private var filteredDevices: [Device] {
		switch deviceTypeFilter {
		case .all: return scannerViewModel.allDevices
		case .bluetooth: return scannerViewModel.bluetoothDevices
		case .lan: return scannerViewModel.lanDevices
		}
	}
	
	private var sortedDevices: [Device] {
		return filteredDevices.sorted {
			sortOrder == .descending ? 
			$0.timestamp > $1.timestamp : 
			$0.timestamp < $1.timestamp
		}
	}
}
