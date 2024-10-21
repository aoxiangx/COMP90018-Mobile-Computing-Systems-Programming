//
//  CalendarView.swift
//  MobileAppNiu
//
//  Created by 关昊 on 20/9/2024.
//

import SwiftUI

// MARK: - CalendarView
struct CalendarView: View {
    @Binding var selectedDate: Date? // Current selected date binding
    @State private var date = Date()
    @State private var selectedMonth: Int = Calendar.current.component(.month, from: Date()) // Current selected month
    let daysOfWeek = Date.capitalizedFirstLettersOfWeekdays // Weekday names
    let columns = Array(repeating: GridItem(.flexible(), spacing: 0), count: 7) // Calendar grid columns
    @State private var days: [Date] = [] // Array of dates for current month

    var body: some View {
        VStack {
            HStack {
                Text("Calendar")
                    .font(.system(size: 24))
                    .foregroundColor(Constants.gray2)
                
                Spacer()
                
                // Month selection dropdown menu
                Menu {
                    ForEach(1...12, id: \.self) { month in
                        Button(action: {
                            selectedMonth = month
                            updateDays() // Update dates when new month is selected
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
                // Calendar grid background
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color.white)
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(Constants.gray3, lineWidth: 1)
                    )
                
                VStack(spacing: 0) {
                    // Display weekdays as headers
                    HStack(spacing: 0) {
                        ForEach(daysOfWeek.indices, id: \.self) { index in
                            Text(daysOfWeek[index])
                                .font(.system(size: 12))
                                .foregroundColor(Constants.gray2)
                                .frame(maxWidth: .infinity)
                        }
                    }
                    .padding(.bottom, 5)
                    
                    // Divider line
                    Rectangle()
                        .fill(Constants.gray2)
                        .frame(height: 0.7)
                    
                    // Date grid display
                    LazyVGrid(columns: columns, spacing: 0) {
                        ForEach(days, id: \.self) { day in
                            if day.monthInt != selectedMonth {
                                Text("")
                                    .font(.system(size: 12))
                                    .frame(maxWidth: .infinity, minHeight: 40)
                                    .border(Color.clear) // Hide dates not in current month
                            } else {
                                Text(day.formatted(.dateTime.day()))
                                    .font(.system(size: 12))
                                    .foregroundColor(getDateColor(for: day))
                                    .frame(maxWidth: .infinity, minHeight: 40)
                                    .background(
                                        Circle()
                                            .foregroundColor(getBackgroundColor(for: day))
                                    )
                                    .onTapGesture {
                                        if !isFutureDate(day) {
                                            selectedDate = Calendar.current.startOfDay(for: day)
                                        }
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
            updateDays() // Initialize dates when view appears
        }
        .onChange(of: selectedMonth) { _ in
            updateDays() // Update dates when month changes
        }
    }

    // Get text color for date
    private func getDateColor(for day: Date) -> Color {
        if isFutureDate(day) {
            return Constants.gray3.opacity(0.3)
        } else if isSelected(day: day) {
            return Color.white
        } else {
            return Constants.gray3
        }
    }

    // Get background color for date
    private func getBackgroundColor(for day: Date) -> Color {
        if isSelected(day: day) {
            return Color.yellow
        } else if Calendar.current.isDateInToday(day) && selectedDate == nil {
            return Color.yellow
        } else {
            return Color.white
        }
    }

    // Check if a date is selected
    private func isSelected(day: Date) -> Bool {
        guard let selectedDate = selectedDate else { return false }
        return Calendar.current.isDate(selectedDate, inSameDayAs: day)
    }

    // Check if a date is in the future
    private func isFutureDate(_ date: Date) -> Bool {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        return calendar.compare(date, to: today, toGranularity: .day) == .orderedDescending
    }

    // Update date array based on selected month
    private func updateDays() {
        let calendar = Calendar.current
        let year = calendar.component(.year, from: date)
        guard let monthDate = calendar.date(from: DateComponents(year: year, month: selectedMonth)) else { return }
        days = monthDate.calendarDisplayDays.map { Calendar.current.startOfDay(for: $0) }
    }
}

// MARK: - Date Extension for Formatting
extension Date {
    /// Formats the date to a string (e.g., "2024-10-17")
    func toString() -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter.string(from: self)
    }
    
    /// Initializes a Date from a string formatted as "yyyy-MM-dd"
    static func fromString(_ dateString: String) -> Date? {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter.date(from: dateString)
    }
}

// MARK: - FileManager Extension for Image Storage
extension FileManager {
    /// Returns the URL to the app's Documents directory
    static var documentsDirectory: URL {
        return Self.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
    }
    
    /// Saves a UIImage to the Documents directory with a unique filename
    static func saveImage(_ image: UIImage) -> String? {
        let uuid = UUID().uuidString
        let filename = "\(uuid).png"
        let url = documentsDirectory.appendingPathComponent(filename)
        if let data = image.pngData() {
            do {
                try data.write(to: url)
                return filename
            } catch {
                print("Error saving image: \(error)")
                return nil
            }
        }
        return nil
    }
    
    /// Loads a UIImage from the Documents directory given a filename
    static func loadImage(named filename: String) -> UIImage? {
        let url = documentsDirectory.appendingPathComponent(filename)
        return UIImage(contentsOfFile: url.path)
    }
}

#Preview {
    CalendarView(selectedDate: .constant(nil))
}
