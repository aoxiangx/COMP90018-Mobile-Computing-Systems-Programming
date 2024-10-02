//
//  ProfileView.swift
//  MobileAppNiu
//
//  Created by Jun Zhu on 1/10/2024.
//

import SwiftUI

struct ProfileView: View {
    @State private var isNotificationsEnabled = true
    var body: some View {
        ZStack {
            BackgroundView()
            ScrollView{
                VStack(alignment: .leading) {
                    HStack {
                        Text("Settings")
                            .font(.system(size: 48))
                            .fontWeight(.bold)
                            .foregroundColor(Constants.gray2)
                    }
                    .padding(.bottom,16)
                    
                    VStack(alignment: .leading, spacing: 8) {
                        // Body Text
                        Text("Personal Information")
                            .font(Constants.body)
                            .foregroundColor(Constants.gray2)
                          .frame(maxWidth: .infinity, alignment: .topLeading)
                        VStack(alignment: .leading, spacing: 0) {
                            HStack(alignment: .center) {
                                Text("About You")
                                  .font(Font.custom("Roboto", size: 16))
                                  .foregroundColor(Color(red: 0.22, green: 0.23, blue: 0.23))
                              Spacer()
                                Image(systemName: "chevron.right") // Using SF Symbol here
                                .foregroundColor(Color(red: 0.22, green: 0.23, blue: 0.23))
                            }
                            .padding(.horizontal, 16)
                            .padding(.vertical, 16)
                            .frame(maxWidth: .infinity, alignment: .center)
                            .background(Constants.white)
                            .cornerRadius(12)
                            .overlay(
                                Rectangle() // 在底部绘制一条线
                                    .frame(height: 0.3) // 线的高度
                                    .foregroundColor(Color.gray), // 线的颜色
                                alignment: .bottom // 对齐到底部
                            )
                            HStack(alignment: .center) {
                                Text("Your Objectives")
                                  .font(Font.custom("Roboto", size: 16))
                                  .foregroundColor(Color(red: 0.22, green: 0.23, blue: 0.23))
                              Spacer()
                                Image(systemName: "chevron.right") // Using SF Symbol here
                                .foregroundColor(Color(red: 0.22, green: 0.23, blue: 0.23))
                            }
                            .padding(.horizontal, 16)
                            .padding(.vertical, 16)
                            .frame(maxWidth: .infinity, alignment: .center)
                            .background(Constants.white)
                            .cornerRadius(12)
                            .overlay(
                                Rectangle() // 在底部绘制一条线
                                    .frame(height: 0.3) // 线的高度
                                    .foregroundColor(Color.gray), // 线的颜色
                                alignment: .bottom // 对齐到底部
                            )
                            HStack(alignment: .center) {
                                Text("About You")
                                  .font(Font.custom("Roboto", size: 16))
                                  .foregroundColor(Color(red: 0.22, green: 0.23, blue: 0.23))
                              Spacer()
                                Image(systemName: "chevron.right") // Using SF Symbol here
                                .foregroundColor(Color(red: 0.22, green: 0.23, blue: 0.23))
                            }
                            .padding(.horizontal, 16)
                            .padding(.vertical, 16)
                            .frame(maxWidth: .infinity, alignment: .center)
                            .background(Constants.white)
                            .cornerRadius(12)
                        }
                        .padding(0)
                        .frame(maxWidth: .infinity, alignment: .topLeading)
                        .cornerRadius(12)
                        .overlay(
                          RoundedRectangle(cornerRadius: 12)
                            .inset(by: -0.2)
                            .stroke(Constants.gray4, lineWidth: 0.4)
                        )
                        .padding(.bottom, 8)
                        
                        VStack(alignment: .leading, spacing: 8) {
                            // Body Text
                            Text("App Preference")
                                .font(Constants.body)
                                .foregroundColor(Constants.gray2)
                                .frame(maxWidth: .infinity, alignment: .topLeading)
                            HStack(alignment: .center) {
                                Text("System Notification")
                                  .font(Font.custom("Roboto", size: 16))
                                  .foregroundColor(Color(red: 0.22, green: 0.23, blue: 0.23))
                              Spacer()
                                Toggle("", isOn: $isNotificationsEnabled)
                                                       .labelsHidden()
                                                       .tint(Constants.Yellow1)
                                                       
                                
                            }
                            .padding(.horizontal, 16)
                            .padding(.vertical, 12)
                            .frame(maxWidth: .infinity, alignment: .center)
                            .background(Constants.white)
                            .cornerRadius(12)
                            .overlay(
                              RoundedRectangle(cornerRadius: 12)
                                .inset(by: -0.2)
                                .stroke(Constants.gray4, lineWidth: 0.4)
                            )
                        }
                    }
                    .padding(0)
                    .frame(width: 361, alignment: .topLeading)
                    
                }
                .padding(.top, 23)
                .padding(16)
            }

        }
        
        
    }
}

#Preview {
    ProfileView()
}
