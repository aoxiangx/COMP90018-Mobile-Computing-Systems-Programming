//
//  Insights.swift
//  MobileAppNiu
//
//  Created by Jun Zhu on 17/9/2024.
//

import SwiftUI

struct Insights: View {
    @EnvironmentObject var healthManager: HealthManager
    @StateObject private var objectiveViewModel = ObjectiveViewModel()
    @EnvironmentObject var sharedDataModel: SharedData
    @State private var insightScore: Double = 0.0
    
    var body: some View {
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
                        
                        CircleChartView(score: insightScore)
                            .frame(maxWidth: .infinity, maxHeight: .infinity)
                            .multilineTextAlignment(.center)
                        
                        
//                        SummaryBoxesView(period: .week).environmentObject(healthManager)
//                        Summary().frame(maxWidth: 360, maxHeight: .infinity)
                        Summary().padding(.leading, 16)
                            .padding(.top, -16)
                            .padding(.trailing,16)
                    }
                    
                }
            }.onAppear {
                fetchAveragePercentages()
            }
            
            
        }
    private func fetchAveragePercentages() {
//        let group = DispatchGroup()
//        var steps: [Double] = []
//        var daylight: [Double] = []
//        
//        // Fetch last 7 days steps
//        group.enter()
//        healthManager.fetchLast7DaysSteps { fetchedSteps in
//            steps = fetchedSteps.map { $0.1 }
////            print("7days steps: \(steps)")
//            group.leave()
//        }
//        
//        // Fetch last 7 days daylight
//        group.enter()
//        healthManager.fetchLast7DaysDaylight { fetchedDaylight in
//            daylight = fetchedDaylight.map { $0.1 }
//            print("7days daylight: \(daylight)")
//            group.leave()
//        }
//        
//        // Once both steps and daylight are fetched
//        group.notify(queue: .main) {
//            // Fetch green space times for last 7 days
//        
//    //            let greenSpace = locationManager.getGreenSpaceTimes(forLastNDays: 7)
//        let greenSpace = [1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0]
//        
//        // Retrieve user objectives
//        let objectives = self.objectiveViewModel.objectives
//        var total = 0.0
//        for day in 0..<7 {
//            let green = min(greenSpace[day] / Double(objectives.greenAreaActivityDuration), 1.0)
//            let sunlight = min(daylight[day] / Double(objectives.sunlightDuration), 1.0)
//            let stepCount = min(steps[day] / Double(objectives.stepCount), 1.0)
//            
//            print("green \(green), sunlight \(sunlight), stepCount \(stepCount)")
//            // Correctly grouping the addition
//            let percentage = (green + sunlight + stepCount) / 3.0 * 100.0
//            print("day \(day), percentage \(percentage)")
//            total += percentage
//            
//        }
//            insightScore = total / 7.0
//        
//        }
        let total = sharedDataModel.percentages.reduce(0, +)
        insightScore =  sharedDataModel.percentages.isEmpty ? 0 : total / Double(sharedDataModel.percentages.count)
    }
        
}
//#Preview {
//    Insights().environmentObject(HealthManager())
//}

//struct Insights_Previews: PreviewProvider {
//    static var previews: some View {
//        Insights()
//            .environmentObject(HealthManager()) // Assuming HealthManager is defined
//    }
//}
