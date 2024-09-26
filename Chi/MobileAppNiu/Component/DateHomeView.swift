//
//  DateHomeView.swift
//  MobileAppNiu
//
//  Created by 关昊 on 22/9/2024.
//

import SwiftUI

import SwiftUI

struct DateHomeView: View {
    let date = Date()
    let dateFormatter: DateFormatter
    let weekDayFormatter = DateFormatter()
    
    init() {
        dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MMMM dd"
        weekDayFormatter.dateFormat = "EEEE"
    }
    
    // 根据当前时间返回问候语
    func greeting() -> String {
        let hour = Calendar.current.component(.hour, from: date)
        switch hour {
        case 5..<12:
            return "Morning"
        case 12..<17:
            return "Afternoon"
        case 17..<21:
            return "Evening"
        default:
            return "Night"
        }
    }
    
    var body: some View {
        VStack(alignment: .leading) {
            let monthAndDay = dateFormatter.string(from: date)
            let weekDay = weekDayFormatter.string(from: date)
            
            // 显示日期和星期
            Text(monthAndDay + ",")
                .font(.system(size: 12))
                .foregroundColor(Constants.gray2)
            
            Text(weekDay)
                .font(.system(size: 12))
                .foregroundColor(Constants.gray2)
            
            // 显示问候语
            Text(greeting()+",")
                .font(.system(size: 48))
                .fontWeight(.bold)
                .foregroundColor(Constants.gray2)
        }
        .padding()
    }
}

#Preview {
    DateHomeView() // 示例数据
}

