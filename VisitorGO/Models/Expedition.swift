//
//  Expedition.swift
//  VisitorGO
//
//  Created by shusuke imamura on 2025/01/16.
//

import SwiftUI

struct Expedition: Identifiable, Codable {
    var id: Int
    var title: String
    var userid: Int
    var userName: String
    var startDate: String
    var endDate: String
    var sportsId: Int
    var sportsName: String
    var team1Name: String
    var team2Name: String
    var userIcon: String
    var images: [String]
    var likesCount: Int
}

struct ExpeditionDetail: Codable {
    var id: Int
    var title: String
    var endDate: String
    var startDate: String
    var memo: String
    var sportsId: Int
    var sportsName: String
    var stadiumId: Int
    var stadiumName: String
    var isPublic: Bool
    var games: [Games]
    var payments: [Payment]
    var expeditionImages: [ExpeditionImage]

    var userid: Int
    var likesCount: Int
    var userName: String
    var userIcon: String
}

struct Games: Codable {
    var date: String
    var id: Int
    var scores: [Scores]
    var team1Id: Int
    var team1Name: String
    var team2Id: Int
    var team2Name: String
}

struct Scores: Codable {
    var id: Int
    var order: Int
    var score: Int
    var teamId: Int
    var teamName: String
}

struct ExpeditionImage: Codable {
    var id: Int
    var image: String
    var fileId: String
}
