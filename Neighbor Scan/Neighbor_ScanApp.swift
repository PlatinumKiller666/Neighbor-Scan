//
//	Neighbor_ScanApp.swift
//	Neighbor Scan
//
//	Created by Kirill Zolotarev on 25.10.2025.
//

import SwiftUI

@main
struct Neighbor_ScanApp: App {
	@StateObject private var appCoordinator = AppCoordinator()
	
	var body: some Scene {
		WindowGroup {
			appCoordinator.makeMainView()
				.environmentObject(appCoordinator)
				.environmentObject(appCoordinator.getScannerViewModel())
				.environmentObject(appCoordinator.getHistoryViewModel())
		}
	}
}
