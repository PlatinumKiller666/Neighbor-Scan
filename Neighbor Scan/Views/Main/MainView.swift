//
//  MainView.swift
//  Neighbor Scan
//
//  Created by Kirill Zolotarev on 25.10.2025.
//


import SwiftUI

struct MainView: View {
	@ObservedObject var coordinator: AppCoordinator
	
	var body: some View {
		TabView {
			coordinator.makeDevicesTabView()
				.tabItem {
					Image(systemName: "network")
					Text("Сканирование")
				}
				.tag(0)
			
			coordinator.makeHistoryView()
				.tabItem {
					Image(systemName: "clock")
					Text("История")
				}
				.tag(1)
		}
		.accentColor(.blue)
	}
}
