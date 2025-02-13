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
    var games: [GamesRequest]
    var imageUrls: [String]
    var payments: [PaymentRequest]
    var visitedFacilities: [VisitedFacilityRequest]

    var startDated: Date? {
        return ISO8601DateFormatter().date(from: startDate)
    }
    var endDated: Date? {
        return ISO8601DateFormatter().date(from: endDate)
    }
}

struct GamesRequest: Codable {
    var date: String
    var scores: [Score]
    var team1Id: Int
    var team2Id: Int
}

struct Score: Codable {
    var order: Int
    var team1Score: Int
    var team2Score: Int
}

extension GamesRequest {
    static func convert(postHelper: PostHelper) -> [GamesRequest] {
        var games: [GamesRequest] = []

        for i in 0..<postHelper.games {
            var scores: [Score] = []
            scores.append(Score(order: i, team1Score: postHelper.firstPoint[i], team2Score: postHelper.secondPoint[i]))
            games.append(GamesRequest(date: postHelper.date[i].toISOString(), scores: scores, team1Id: postHelper.firstTeam[i].id, team2Id: postHelper.secondTeam[i].id))
        }
        return games
    }
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

// games: [{
//      date: "2025-01-31T08:55:48Z",
//      scores: [{order: 0, score: 13, teamId: 61}, {order: 1, score: 6, teamId: 61}],
//      team1Id: 61,
//      team2Id: 61
// ]

