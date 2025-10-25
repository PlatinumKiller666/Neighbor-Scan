//
//  DeviceDetailView.swift
//  Neighbor Scan
//
//  Created by Kirill Zolotarev on 25.10.2025.
//


import SwiftUI

struct DeviceDetailView: View {
	let device: Device
	
	var body: some View {
		List {
			Section("Основная информация") {
				DetailRow(title: "Тип", value: device.type.displayName)
				DetailRow(title: "Имя", value: device.name ?? "Неизвестно")
				DetailRow(title: "Время обнаружения", value: formattedDate(device.timestamp))
			}
			
			if device.type == .bluetooth {
				Section("Bluetooth информация") {
					DetailRow(title: "UUID", value: device.uuid ?? "N/A")
					if let rssi = device.rssi {
						DetailRow(title: "Уровень сигнала", value: "\(rssi) dBm")
					}
					DetailRow(title: "Статус", value: device.status ?? "Неизвестно")
				}
			} else {
				Section("Сетевая информация") {
					DetailRow(title: "IP адрес", value: device.ipAddress ?? "N/A")
					DetailRow(title: "MAC адрес", value: device.macAddress ?? "N/A")
				}
			}
		}
		.navigationTitle("Детали устройства")
		.listStyle(GroupedListStyle())
	}
	
	private func formattedDate(_ date: Date) -> String {
		let formatter = DateFormatter()
		formatter.dateStyle = .medium
		formatter.timeStyle = .medium
		return formatter.string(from: date)
	}
}

struct DetailRow: View {
	let title: String
	let value: String
	
	var body: some View {
		HStack {
			Text(title)
				.foregroundColor(.secondary)
			Spacer()
			Text(value)
				.multilineTextAlignment(.trailing)
		}
	}
}
