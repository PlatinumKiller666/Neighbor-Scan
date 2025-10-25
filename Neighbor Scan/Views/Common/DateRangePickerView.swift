//
//  DateRangePickerView.swift
//  Neighbor Scan
//
//  Created by Kirill Zolotarev on 25.10.2025.
//


import SwiftUI

struct DateRangePickerView: View {
	@Binding var startDate: Date
	@Binding var endDate: Date
	
	var body: some View {
		VStack(spacing: 12) {
			HStack {
				Text("Период:")
					.font(.headline)
					.foregroundColor(.primary)
				
				Spacer()
				
				Text("\(formattedDateRange)")
					.font(.subheadline)
					.foregroundColor(.secondary)
			}
			
			VStack(spacing: 8) {
				DatePicker("С:", selection: $startDate, in: ...endDate, displayedComponents: [.date, .hourAndMinute])
					.labelsHidden()
				
				DatePicker("По:", selection: $endDate, in: startDate..., displayedComponents: [.date, .hourAndMinute])
					.labelsHidden()
			}
			.font(.caption)
		}
		.padding()
		.background(Color(.systemGray6))
		.cornerRadius(10)
	}
	
	private var formattedDateRange: String {
		let formatter = DateFormatter()
		formatter.dateStyle = .short
		formatter.timeStyle = .short
		return "\(formatter.string(from: startDate)) - \(formatter.string(from: endDate))"
	}
}
