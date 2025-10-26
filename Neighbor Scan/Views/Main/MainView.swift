//
//  MainView.swift
//  Neighbor Scan
//
//  Created by Kirill Zolotarev on 25.10.2025.
//


import SwiftUI

struct MainView: View {
	@ObservedObject var coordinator: AppCoordinator
	
	@State var hideLaunch = false
	
	var body: some View {
		
		if !hideLaunch {
			HStack {
				Text("no time to make".localized())
					.foregroundStyle(.blue)
			}
			.scaledToFill()
			.background(.white)
			.task(delayLaunch)
		}
		else {
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
	
	@Sendable private func delayLaunch() async {
		//(1 second = 1_000_000_000 nanoseconds)
		try? await Task.sleep(nanoseconds: 2_000_000_000)
		hideLaunch = true
	}
}
