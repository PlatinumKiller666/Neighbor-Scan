//
//  SortOrder.swift
//  Neighbor Scan
//
//  Created by Kirill Zolotarev on 25.10.2025.
//


import Foundation

enum SortOrder {
	case ascending
	case descending
	
	var iconName: String {
		switch self {
		case .ascending: return "arrow.up"
		case .descending: return "arrow.down"
		}
	}
	
	var title: String {
		switch self {
		case .ascending: return "По возрастанию"
		case .descending: return "По убыванию"
		}
	}
	
	var realmSortAscending: Bool {
		switch self {
		case .ascending: return true
		case .descending: return false
		}
	}
	
	var displayName: String {
		switch self {
		case .ascending: return "Сначала старые"
		case .descending: return "Сначала новые"
		}
	}
}
