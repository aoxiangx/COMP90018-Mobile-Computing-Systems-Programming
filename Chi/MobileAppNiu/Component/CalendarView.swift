//
//  CalendarView.swift
//  MobileAppNiu
//
//  Created by 关昊 on 20/9/2024.
//

import SwiftUI

// MARK: - CalendarView
struct CalendarView: View {
    @Binding var selectedDate: Date? // 当前选定的日期绑定
    @State private var date = Date()
    @State private var selectedMonth: Int = Calendar.current.component(.month, from: Date()) // 当前选定的月份
    let daysOfWeek = Date.capitalizedFirstLettersOfWeekdays // 星期几的名称
    let columns = Array(repeating: GridItem(.flexible(), spacing: 0), count: 7) // 日历的网格列
    @State private var days: [Date] = [] // 当前月份的日期数组

    var body: some View {
        VStack {
            HStack {
                Text("Calendar")
                    .font(.system(size: 24))
                    .foregroundColor(Constants.gray2)
                
                Spacer()
                
                // 选择月份的下拉菜单
                Menu {
                    ForEach(1...12, id: \.self) { month in
                        Button(action: {
                            selectedMonth = month
                            updateDays() // 选择新月份时更新日期
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
                // 日历网格的背景
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color.white)
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(Constants.gray3, lineWidth: 1)
                    )
                
                VStack(spacing: 0) {
                    // 显示星期几作为标题
                    HStack(spacing: 0) {
                        ForEach(daysOfWeek.indices, id: \.self) { index in
                            Text(daysOfWeek[index])
                                .font(.system(size: 12))
                                .foregroundColor(Constants.gray2)
                                .frame(maxWidth: .infinity)
                        }
                    }
                    .padding(.bottom, 5)
                    
                    // 分隔线
                    Rectangle()
                        .fill(Constants.gray2)
                        .frame(height: 0.7)
                    
                    // 显示日期的网格
                    LazyVGrid(columns: columns, spacing: 0) {
                        ForEach(days, id: \.self) { day in
                            if day.monthInt != selectedMonth {
                                Text("")
                                    .font(.system(size: 12))
                                    .frame(maxWidth: .infinity, minHeight: 40)
                                    .border(Color.clear) // 隐藏不属于当前月份的日期
                            } else {
                                Text(day.formatted(.dateTime.day()))
                                    .font(.system(size: 12))
                                    .foregroundColor(
                                        isSelected(day: day) ? Color.white : Constants.gray3
                                    )
                                    .frame(maxWidth: .infinity, minHeight: 40)
                                    .background(
                                        Circle()
                                            .foregroundColor(
                                                isSelected(day: day) ? Color.yellow :
                                                (Calendar.current.isDateInToday(day) && selectedDate == nil ? Constants.Blue2 : Color.white)
                                            )
                                    )
                                    .onTapGesture {
                                        selectedDate = Calendar.current.startOfDay(for: day) // 选择日期时标准化
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
            updateDays() // 视图出现时初始化日期
        }
        .onChange(of: selectedMonth) { _ in
            updateDays() // 选择新月份时更新日期
        }
    }

    // 检查某个日期是否被选中
    private func isSelected(day: Date) -> Bool {
        guard let selectedDate = selectedDate else { return false }
        return Calendar.current.isDate(selectedDate, inSameDayAs: day)
    }

    // 根据选定的月份更新日期数组
    private func updateDays() {
        let calendar = Calendar.current
        let year = calendar.component(.year, from: date)
        guard let monthDate = calendar.date(from: DateComponents(year: year, month: selectedMonth)) else { return }
        days = monthDate.calendarDisplayDays.map { Calendar.current.startOfDay(for: $0) } // 标准化所有日期
    }
}

#Preview {
    CalendarView(selectedDate: .constant(nil))
}
