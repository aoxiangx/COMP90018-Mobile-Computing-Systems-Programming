//
//  HomeView.swift
//  MobileAppNiu
//
//  Created by 关昊 on 14/9/2024.
//

import SwiftUI
import Firebase
import FirebaseAuth

struct HomeView: View {
    @EnvironmentObject var manager : HealthManager
    @AppStorage("log_Status") private var logStatus: Bool = false
    
    var body: some View {
        
        ZStack (alignment: .topLeading){
            
            BackgroundView()
            
            ScrollView{
                VStack(alignment: .leading){
                    // Date view
                    DateHomeView()
                    
                    PieHomeView(percentages: [35, 50, 65, 75, 85, 90, 55]).padding(.leading, 15)
                    
                    Button("logOut") {
                        try? Auth.auth().signOut()
                        logStatus = false
                    }
                    
                    
                    VStack(alignment: .center){
                        ScoreEmoji(score:89)
                    }
                    ObjectiveNotification()
                        .padding(16)
                    SummaryBoxesView().environmentObject(HealthManager())
                }
            }
            
            

        }
    }
}


#Preview {
    HomeView()
        .environmentObject(HealthManager())
}
