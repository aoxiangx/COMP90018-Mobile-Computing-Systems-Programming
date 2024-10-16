//
//  Insights.swift
//  MobileAppNiu
//
//  Created by Jun Zhu on 17/9/2024.
//

import SwiftUI

struct Insights: View {
    @EnvironmentObject var healthManager: HealthManager
    @State private var score: Double = 75.0
    
    var body: some View {
        NavigationView{
            ZStack{
                LinearGradient(gradient: Gradient(stops: [
                    .init(color: Color(hex: "FFF8C9"), location: 0.0),  // Start with FFF8C9
                    .init(color: Color(hex: "EDF5FF"), location: 0.6)   // End with EDF5FF
                ]),
                               startPoint: .topLeading,
                               endPoint: .bottomTrailing)
                .edgesIgnoringSafeArea(.all)  // To fill the entire screen
                

                
                ScrollView{
                    VStack(alignment: .leading){
                        Text("Insights")
                            .font(Constants.bigTitle)
                            .fontWeight(.bold)
                            .foregroundColor(Constants.gray2)
                            .padding(.leading, 16)
                            .padding(.top, 16)
                        
                        CircleChartView(score: $score)
                            .frame(maxWidth: .infinity, maxHeight: .infinity)
                            .multilineTextAlignment(.center)
                        
                        
                        SummaryBoxesView()
                    }
                    
                }
                
            }
            
        }
        
    }
}

struct Insights_Previews: PreviewProvider {
    static var previews: some View {
        Insights()
            .environmentObject(HealthManager()) // Assuming HealthManager is defined
    }
}
