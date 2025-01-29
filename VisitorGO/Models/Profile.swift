//
//  UserData.swift
//  VisitorGO
//
//  Created by shusuke imamura on 2024/12/17.
//

import Foundation

struct Profile: Codable {
    var id: Int
    var email: String
    var name: String
    var description: String
    var profileImage: String
    var fileId: String
    var username: String
}

struct UserDataResponse: Codable {
    var id: Int
    var email: String
    var name: String
    var username: String
    var profileImage: String
    var fileId: String
    var description: String
    var expeditions: [Expedition]
    var likedExpeditions: [Expedition]
    var favoriteTeams: [FavoriteTeamResponse]
}

struct FavoriteTeamResponse: Codable {
    var id: Int
    var leagueName: String
    var sportName: String
    var teamId: Int
    var teamName: String
}
