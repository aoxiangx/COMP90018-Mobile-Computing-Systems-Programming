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
        }
        .padding()
    }
}



#Preview {
    DateHomeView() // 示例数据
}
