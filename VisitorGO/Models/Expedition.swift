//
//  Expedition.swift
//  VisitorGO
//
//  Created by shusuke imamura on 2025/01/16.
//

import SwiftUI

struct Expedition: Identifiable, Codable, Hashable {
    var id: Int
    var title: String
    var startDate: String
    var endDate: String
    var sportId: Int
    var sportName: String
    var userId: Int
    var userName: String
    var userIcon: String
    var likesCount: Int
    var images: [String]
    var team1Name: String
    var team2Name: String

    var isFavorite: Bool?
    var stadiumId: Int?
    var stadiumName: String?

    var startDated: Date? {
        return ISO8601DateFormatter().date(from: startDate)
    }
    var endDated: Date? {
        return ISO8601DateFormatter().date(from: endDate)
    }
}

struct ExpeditionDetail: Codable {
    var id: Int
    var userId: Int
    var sportId: Int
    var sportName: String
    var isPublic: Bool
    var title: String
    var startDate: String
    var endDate: String
    var stadiumId: Int
    var stadiumName: String
    var memo: String
    var username: String
    var userIcon: String
    var likesCount: Int
    var games: [Games]
    var payments: [PaymentResponse]
    var expeditionImages: [ExpeditionImage]
}

struct Games: Codable, Hashable {
    var date: String
    var id: Int
    var scores: [Scores]
    var team1Id: Int
    var team1Name: String
    var team2Id: Int
    var team2Name: String
}

struct Scores: Codable, Hashable {
    var id: Int
    var order: Int
    var score: Int
    var teamId: Int
    var teamName: String
}

struct ExpeditionImage: Codable, Hashable {
    var id: Int
    var image: String
    var fileId: String
}

struct PaymentResponse: Codable, Hashable {
    var id: Int
    var title: String
    var date: String
    var cost: Int
}
