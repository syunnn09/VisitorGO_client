//
//  Team.swift
//  VisitorGO
//
//  Created by shusuke imamura on 2025/01/21.
//

import SwiftUI

class Team: Identifiable, Codable, ObservableObject {
    let id: Int
    let name: String
    @Published var isFavorite: Bool

    private enum CodingKeys: String, CodingKey {
        case id
        case name
        case isFavorite
    }

    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(Int.self, forKey: .id)
        name = try container.decode(String.self, forKey: .name)
        isFavorite = try container.decode(Bool.self, forKey: .isFavorite)
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(name, forKey: .name)
        try container.encode(isFavorite, forKey: .isFavorite)
    }
}

struct League: Identifiable, Codable {
    var id = UUID()
    let league: String
    let teams: [Team]
    
    private enum CodingKeys: String, CodingKey {
        case league
        case teams
    }
}

struct TeamData: Identifiable, Codable {
    var id = UUID()
    var data: [SportsData]
    
    private enum CodingKeys: String, CodingKey {
        case data
    }
}

struct SportsData: Identifiable, Codable, Equatable {
    var id = UUID()
    let sports: String
    let icon: String
    let team: [League]
    var ignore = false
    
    var favoriteTeams: [Team] {
        var teams: [Team] = []
        for league in team {
            for team in league.teams {
                if team.isFavorite {
                    teams.append(team)
                }
            }
        }
        return teams
    }
    
    private enum CodingKeys: String, CodingKey {
        case sports
        case icon
        case team
    }
    
    static func == (lhs: SportsData, rhs: SportsData) -> Bool {
        lhs.sports == rhs.sports
    }
}
