//
//  DeviceType.swift
//  Neighbor Scan
//
//  Created by Kirill Zolotarev on 25.10.2025.
//


import Foundation
import RealmSwift

enum DeviceType: String, PersistableEnum, CaseIterable {
	case bluetooth
	case lan
}

extension DeviceType {
	var iconName: String {
		switch self {
		case .bluetooth: return "dot.radiowaves.left.and.right"
		case .lan: return "network"
		}
	}
	
	var displayName: String {
		switch self {
		case .bluetooth: return "Bluetooth"
		case .lan: return "LAN"
		}
	}
	
	var colorName: String {
		switch self {
		case .bluetooth: return "purple"
		case .lan: return "green"
		}
	}
}
