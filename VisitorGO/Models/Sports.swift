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

    var id: Int {
        switch self {
            case .soccer: return 1
            case .baseball: return 2
            case .basketball: return 3
            case .volleyball: return 4
        }
    }
    
    var icon: String {
        switch (self) {
            case .baseball: return "baseball"
            case .soccer: return "soccerball"
            case .volleyball: return "volleyball"
            case .basketball: return "basketball"
        }
    }
}
