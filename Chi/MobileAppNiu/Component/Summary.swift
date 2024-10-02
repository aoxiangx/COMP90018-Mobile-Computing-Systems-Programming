//
//  Summary.swift
//  MobileAppNiu
//
//  Created by Tori Li on 19/9/2024.
//

import SwiftUI

struct Summary: View {
    var body: some View {
        VStack(spacing:16){
            LandscapeInfoCard(activity: "Daylight Time",iconName: .sunLightIcon)
            LandscapeInfoCard(activity: "Green Space Time",iconName: .sunLightIcon)
            LandscapeInfoCard(activity: "Noise Level",iconName: .sunLightIcon)
            LandscapeInfoCard(activity: "Sleep Time",iconName: .sunLightIcon)
        }
    }
}

#Preview {
    Summary().environmentObject(HealthManager())
}
