//
//  SummaryBoxView.swift
//  MobileAppNiu
//
//  Created by 关昊 on 20/9/2024.
//


import SwiftUI

struct SummeryBoxView: View {
    @EnvironmentObject var manager: HealthManager
    var color: Color = .white  // 默认背景颜色
    var icon: ImageResource = .sunLightIcon // 默认图标
    var title: String = "Noise Level" // 第一个文本
    var subtitle: String = "Step(s)" // 第二个文本
    var description: String = "Past 7 Days" // 第三个文本
    var paddingSpace: CGFloat = 50
    var activity: Activity = .sleep
    @State private var average: Double = 0.0

    var body: some View {
        VStack(alignment: .leading, spacing: 7) { // 上下排列，左对齐
            Image(icon)
                .resizable() // 使图片可调整大小
                .frame(width: 32, height: 32) // 设置大小为32x32
                .foregroundColor(.gray)
            // 标题
            Text(title)
                .font(.system(size: 16))
                .foregroundColor(Constants.gray3)
            // 显示平均值和副标题
            HStack(spacing: 4) {  // You can adjust the spacing as needed
                Text(String(format: "%.1f", average))
                    .font(.system(size: 24))
                    .lineLimit(1)
                    .foregroundColor(Constants.gray3)
                    .fixedSize(horizontal: true, vertical: true)

                Text(subtitle)
                    .font(Constants.caption)
                    .lineLimit(1)
                    .foregroundColor(Constants.gray3)
            }
            .frame(maxWidth: .infinity, alignment: .leading)

            // 过去7天
            Text(description)
                .font(.system(size: 12))
                .foregroundColor(Constants.gray3)
        }
        .padding(.leading, 16)
        .frame(width: 172, height: 142) // 设置固定宽度和高度
        .background(color) // 背景颜色
        .cornerRadius(12) // 圆角
        .overlay(
            RoundedRectangle(cornerRadius: 12) // 与背景一致的圆角
                .stroke(Constants.gray4, lineWidth: 1) // 灰色边框，宽度1
        )
        .shadow(radius: 1) // 阴影
        .onAppear {
            fetchAverage(activity: activity,period: TimePeriod.week)
        }
    }

    // 获取并存储当前活动的平均值
    private func fetchAverage(activity: Activity,period: TimePeriod) {
        manager.fetchAverage(endDate: Date(), activity: activity,period: period) { fetchedAverage in
            DispatchQueue.main.async {
                self.average = fetchedAverage
//                print("Average for \(activity.title): \(fetchedAverage)")
            }
        }
    }
}

struct SummeryBoxView_Previews: PreviewProvider {
    static var previews: some View {
        SummeryBoxView()
            .environmentObject(HealthManager())
    }
}
