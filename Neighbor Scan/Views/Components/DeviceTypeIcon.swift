//
//  DeviceTypeIcon.swift
//  Neighbor Scan
//
//  Created by Kirill Zolotarev on 25.10.2025.
//


import SwiftUI

struct DeviceTypeIcon: View {
	let type: DeviceType
	
	var body: some View {
		Image(systemName: type.iconName)
			.font(.title3)
			.foregroundColor(type == .bluetooth ? .purple : .green)
			.frame(width: 24)
	}
}
