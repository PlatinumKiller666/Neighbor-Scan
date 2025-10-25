//
//  DeviceTypeFilter.swift
//  Neighbor Scan
//
//  Created by Kirill Zolotarev on 25.10.2025.
//


import Foundation

enum DeviceTypeFilter {
	case all
	case bluetooth
	case lan
	
	var title: String {
		switch self {
		case .all: return "Все устройства"
		case .bluetooth: return "Bluetooth устройства"
		case .lan: return "LAN устройства"
		}
	}
	
	var displayName: String {
		switch self {
		case .all: return "Все"
		case .bluetooth: return "Bluetooth"
		case .lan: return "LAN"
		}
	}
}

enum TimePeriodFilter {
	case last24Hours
	case lastWeek
	case customRange
	
	var title: String {
		switch self {
		case .last24Hours: return "За 24 часа"
		case .lastWeek: return "За неделю"
		case .customRange: return "Выбор периода"
		}
	}
	
	var displayName: String {
		switch self {
		case .last24Hours: return "24 часа"
		case .lastWeek: return "Неделя"
		case .customRange: return "Выбор даты"
		}
	}
}
