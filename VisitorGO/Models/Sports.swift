//
//  Sports.swift
//  VisitorGO
//
//  Created by shusuke imamura on 2024/11/18.
//

import Foundation

enum Sports: String, CaseIterable {
    case baseball = "野球"
    case soccer   = "サッカー"
    case volleyball = "バレーボール"
    case basketball = "バスケットボール"
    
    var icon: String {
        switch (self) {
        case .baseball: return "baseball"
        case .soccer: return "soccerball"
        case .volleyball: return "volleyball"
        case .basketball: return "basketball"
        }
    }
}
