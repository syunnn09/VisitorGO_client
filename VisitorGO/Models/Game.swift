//
//  Game.swift
//  VisitorGO
//
//  Created by shusuke imamura on 2025/01/10.
//

import SwiftUI

struct Game: Codable {
    var isPublic: Bool
    var sportId: Int
    var stadiumId: Int
    var title: String
    var startDate: String
    var endDate: String
    var memo: String
    var games: [GameRequest]
    var imageUrls: [String]
    var payments: [Payment]
    var visitedFacilities: [VisitedFacilityRequest]
}


//{
//  "isPublic": true,
//  "sportId": 1,
//  "stadiumId": 1,
//  "title": "野球観戦の遠征記録",
//  "startDate": "2025-01-01T00:00:00Z",
//  "endDate": "2025-01-01T00:00:00Z",
//  "memo": "初めてのスタジアム訪問。とても楽しかった！",
//
//  "games": [
//    {
//      "date": "2025-01-01T00:00:00Z",
//      "scores": [
//        {
//          "order": 1,
//          "score": 1,
//          "teamId": 1
//        }
//      ],
//      "team1Id": 1,
//      "team2Id": 2
//    }
//  ],
//
//  "imageUrls": [
//      "https://ik.imagekit.io/your_imagekit_id/image.jpg"
//  ],
//
//  "payments": [
//    {
//      "cost": 5000,
//      "date": "2025-01-01T00:00:00Z",
//      "title": "チケット代"
//    }
//  ],
//
//  "visitedFacilities": [
//    {
//      "address": "東京都千代田区丸の内1-1-1",
//      "color": "#00FF00",
//      "icon": "train",
//      "latitude": 35.6812,
//      "longitude": 139.7671,
//      "name": "東京駅"
//    }
//  ]
//}

