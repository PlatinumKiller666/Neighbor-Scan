//
//  DeviceRow.swift
//  Neighbor Scan
//
//  Created by Kirill Zolotarev on 25.10.2025.
//


import SwiftUI

struct DeviceRow: View {
	let device: Device
	let showDeviceType: Bool
	let sortOrder: SortOrder
	
	var body: some View {
		HStack(spacing: 12) {
			DeviceTypeIcon(type: device.type)
			
			VStack(alignment: .leading, spacing: 4) {
				HStack {
					Text(device.name ?? "Неизвестное устройство")
						.font(.headline)
						.lineLimit(1)
					
					if showDeviceType {
						DeviceTypeBadge(type: device.type)
					}
				}
				
				HStack {
					deviceInfoText
						.font(.caption)
					
					Spacer()
					
					if let rssi = device.rssi {
						SignalStrengthView(rssi: rssi)
					}
					
					timestampView
				}
				.font(.caption)
				.foregroundColor(.secondary)
			}
			
			Spacer()
		}
		.padding(.vertical, 4)
		.contentShape(Rectangle())
	}
	
	private var deviceInfoText: Text {
		if device.type == .bluetooth {
			return Text(device.uuid?.prefix(8) ?? "N/A")
		} else {
			return Text(device.ipAddress ?? "N/A")
		}
	}
	
	private var timestampView: some View {
		VStack(alignment: .trailing, spacing: 2) {
			Text(relativeTime)
				.font(.system(.caption, design: .monospaced))
				.foregroundColor(sortOrder == .descending ? .primary : .secondary)
			
			Text(formattedTime)
				.font(.system(.caption2, design: .monospaced))
				.foregroundColor(.secondary)
		}
	}
	
	private var relativeTime: String {
		let formatter = RelativeDateTimeFormatter()
		formatter.unitsStyle = .abbreviated
		return formatter.localizedString(for: device.timestamp, relativeTo: Date())
	}
	
	private var formattedTime: String {
		let formatter = DateFormatter()
		if Calendar.current.isDateInToday(device.timestamp) {
			formatter.dateStyle = .none
			formatter.timeStyle = .short
		} else {
			formatter.dateStyle = .short
			formatter.timeStyle = .short
		}
		return formatter.string(from: device.timestamp)
	}
}

struct DeviceTypeBadge: View {
	let type: DeviceType
	
	var body: some View {
		Text(type == .bluetooth ? "BT" : "LAN")
			.font(.system(size: 10, weight: .bold))
			.foregroundColor(.white)
			.padding(.horizontal, 6)
			.padding(.vertical, 2)
			.background(type == .bluetooth ? Color.purple : Color.green)
			.cornerRadius(4)
	}
}
