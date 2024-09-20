//
//  CalendarView.swift
//  MobileAppNiu
//
//  Created by 关昊 on 20/9/2024.
//

import SwiftUI

struct CalendarView: View {
    @State private var date = Date.now
    @State private var selectedMonth: Int = Calendar.current.component(.month, from: Date())
    @State private var selectedDate: Date?
    let daysOfWeek = Date.capitalizedFirstLettersOfWeekdays
    let columns = Array(repeating: GridItem(.flexible(), spacing: 0), count: 7)
    @State private var days: [Date] = []

    var body: some View {
        VStack {
            HStack {
                Text("Calendar")
                    .font(.system(size: 24))
                    .foregroundColor(Constants.gray2)

                Spacer()

                // 月份选择下拉框
                Menu {
                    ForEach(1...12, id: \.self) { month in
                        Button(action: {
                            selectedMonth = month
                            updateDays()
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
//                    .padding(10) // 添加内边距
                    .background(RoundedRectangle(cornerRadius: 48) // 胶囊背景
                                    .fill(Color.white)
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: 20) // 添加边框
                            .stroke(Constants.gray2, lineWidth: 1)
                    )
                }

            }
//            .padding()

            // 大长方形背景
            ZStack {
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color.white)
                    .shadow(radius: 1)
                
                VStack(spacing: 0) {
                    // 星期标题
                    HStack(spacing: 0) {
                        ForEach(daysOfWeek.indices, id: \.self) { index in
                            Text(daysOfWeek[index])
                                .font(.system(size: 12))
                                .foregroundColor(Constants.gray2)
                                .frame(maxWidth: .infinity)
                        }
                    }
                    .padding(.bottom, 0)

                    // 日历网格
                    LazyVGrid(columns: columns, spacing: 0) {
                        ForEach(days, id: \.self) { day in
                            if day.monthInt != selectedMonth {
                                Text("")
                                    .font(.system(size: 12))
                                    .frame(maxWidth: .infinity, minHeight: 40)
                                    .border(Color.clear) // 不显示边框
                            } else {
                                Text(day.formatted(.dateTime.day()))
                                    .font(.system(size: 12))
                                    .foregroundColor(Constants.gray3)
                                    .frame(maxWidth: .infinity, minHeight: 40)
                                    .background(
                                        Circle()
                                            .foregroundStyle(
                                                selectedDate == day ? Constants.Blue3 :
                                                    (Calendar.current.isDateInToday(day) ? Constants.Blue2 : Color.white)
                                            )
                                    )
                                    .onTapGesture {
                                        selectedDate = day // 选择日期
                                    }
                            }
                        }
                    }
                }
            }
            .frame(height: 272)
//            .padding(.horizontal)
        }
        .padding()
        .onAppear {
            updateDays()
        }
        .onChange(of: selectedMonth) { _ in
            updateDays()
        }
    }

    private func updateDays() {
        let calendar = Calendar.current
        let year = calendar.component(.year, from: date)
        let monthDate = calendar.date(from: DateComponents(year: year, month: selectedMonth))!
        days = monthDate.calendarDisplayDays
    }
}

#Preview {
    CalendarView()
}
