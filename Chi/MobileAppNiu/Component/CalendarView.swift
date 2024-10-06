//
//  CalendarView.swift
//  MobileAppNiu
//
//  Created by 关昊 on 20/9/2024.
//

import SwiftUI

// MARK: - CalendarView
struct CalendarView: View {
    @Binding var selectedDate: Date? // Binding to the currently selected date
    @State private var date = Date.now
    @State private var selectedMonth: Int = Calendar.current.component(.month, from: Date()) // Holds the currently selected month
    let daysOfWeek = Date.capitalizedFirstLettersOfWeekdays // Days of the week
    let columns = Array(repeating: GridItem(.flexible(), spacing: 0), count: 7) // Define grid columns for the calendar
    @State private var days: [Date] = [] // Array to store days of the selected month

    var body: some View {
        VStack {
            HStack {
                Text("Calendar")
                    .font(.system(size: 24))
                    .foregroundColor(Constants.gray2)
                
                Spacer()
                
                // Dropdown menu for selecting a month
                Menu {
                    ForEach(1...12, id: \ .self) { month in
                        Button(action: {
                            selectedMonth = month
                            updateDays() // Update the calendar days when a new month is selected
                        }) {
                            Text("\(DateFormatter().monthSymbols[month - 1])")
                                .font(.system(size: 12))
                                .foregroundColor(Constants.gray3)
                        }
                    }
                } label: {
                    HStack {
                        Text(DateFormatter().monthSymbols[selectedMonth - 1])
                            .font(.system(size: 12))
                            .foregroundColor(Constants.gray3)
                        Image(systemName: "chevron.down")
                            .foregroundColor(.gray)
                    }
                    .frame(width: 103, height: 26)
                    .background(RoundedRectangle(cornerRadius: 48)
                                    .fill(Color.white))
                    .overlay(
                        RoundedRectangle(cornerRadius: 20)
                            .stroke(Constants.gray2, lineWidth: 1)
                    )
                }
            }
            
            ZStack {
                // Background for the calendar grid
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color.white)
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(Constants.gray3, lineWidth: 1)
                    )
                
                VStack(spacing: 0) {
                    // Display days of the week as headers
                    HStack(spacing: 0) {
                        ForEach(daysOfWeek.indices, id: \ .self) { index in
                            Text(daysOfWeek[index])
                                .font(.system(size: 12))
                                .foregroundColor(Constants.gray2)
                                .frame(maxWidth: .infinity)
                        }
                    }
                    .padding(.bottom, 5)
                    
                    // Horizontal line separator
                    Rectangle()
                        .fill(Constants.gray2)
                        .frame(height: 0.7)
                    
                    // Display calendar days in a grid
                    LazyVGrid(columns: columns, spacing: 0) {
                        ForEach(days, id: \ .self) { day in
                            if day.monthInt != selectedMonth {
                                Text("")
                                    .font(.system(size: 12))
                                    .frame(maxWidth: .infinity, minHeight: 40)
                                    .border(Color.clear) // Hide days that are not part of the current month
                            } else {
                                Text(day.formatted(.dateTime.day()))
                                    .font(.system(size: 12))
                                    .foregroundColor(Constants.gray3)
                                    .frame(maxWidth: .infinity, minHeight: 40)
                                    .background(
                                        Circle()
                                            .foregroundStyle(
                                                selectedDate == day ? Constants.Blue3 :
                                                    (Calendar.current.isDateInToday(day) && selectedDate == nil ? Constants.Blue2 : Color.white)
                                            )
                                    )
                                    .onTapGesture {
                                        selectedDate = day // Update selected date when a day is tapped
                                    }
                            }
                        }
                    }
                }
            }
            .frame(height: 272)
        }
        .padding()
        .onAppear {
            updateDays() // Initialize days when the view appears
        }
        .onChange(of: selectedMonth) { _ in
            updateDays() // Update days when the selected month changes
        }
    }

    // Function to update the days array based on the selected month
    private func updateDays() {
        let calendar = Calendar.current
        let year = calendar.component(.year, from: date)
        let monthDate = calendar.date(from: DateComponents(year: year, month: selectedMonth))!
        days = monthDate.calendarDisplayDays
    }
}

#Preview {
    CalendarView(selectedDate: .constant(nil))
}


