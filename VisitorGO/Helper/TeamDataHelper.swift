//
//  TeamDataHelper.swift
//  VisitorGO
//
//  Created by shusuke imamura on 2024/12/04.
//

import SwiftUI

struct Response: Decodable {
    let result: Bool
}

class TeamDataHelper: ObservableObject {
    static let shared = TeamDataHelper()
    let url = baseURL

    @Published var teamData: TeamData? = nil
    @Published var selectedSports: SportsData?
    @Published var selectedLeague: String = "全て"
    @Published var favoriteTeams: [Team] = []
    @Published var allData: SportsData? = nil

    init() {
        URLSession.shared.dataTask(with: URL(string: url)!) { (data, response, error) in
            let jsonData = try! JSONDecoder().decode(TeamData.self, from: data!)
            DispatchQueue.main.async {
                self.selectedSports = jsonData.data.first!
                self.teamData = jsonData
                self.allData = SportsData(sports: "推しチーム", icon: "heart", team: [], ignore: true)
                self.teamData!.data.insert(self.allData!, at: 0)
                self.createAllData()
            }
        }.resume()
    }

    func createAllData() {
        var leagues: [League] = []
        for sports in teamData!.data {
            if !sports.ignore {
                var teams: [Team] = []
                for league in sports.team {
                    for team in league.teams {
                        if team.isFavorite { teams.append(team) }
                    }
                }
                leagues.append(.init(league: sports.sports, teams: teams))
            }
        }
        let allData = SportsData(sports: "推しチーム", icon: "heart", team: leagues, ignore: true)
        self.teamData!.data.replace(pos: 0, data: allData)
    }

    func toggle(team: Team) {
        if let index = favoriteTeams.firstIndex(where: { $0.name == team.name }) {
            favoriteTeams.remove(at: index)
        } else {
            favoriteTeams.append(team)
        }
        postFavorite(team: team)
    }

    func postFavorite(team: Team) {
        var request = URLRequest(url: URL(string: "\(baseURL)/favorite")!)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = try! JSONEncoder().encode(team)
        URLSession.shared.dataTask(with: request) { data, response, error in
            guard let data = data, let _ = response, error == nil else {
                print("Something went wrong: error: \(error?.localizedDescription ?? "unknown error")")
                return
            }

            let res = try! JSONDecoder().decode(Response.self, from: data)
            if res.result {
                DispatchQueue.main.async {
                    withAnimation {
                        team.isFavorite.toggle()
                        self.createAllData()
                    }
                }
            }
        }.resume()
    }

    func getSportsBySportsName() -> SportsData {
        for sports in self.teamData!.data {
            if sports.sports == selectedSports?.sports {
                return sports
            }
        }
        return self.teamData!.data.first!
    }

    func getLeaguesBySportsName() -> [League] {
        let sports = getSportsBySportsName()
        var leagues: [League] = []
        for league in sports.team { leagues.append(league) }
        return leagues
    }

    func getTeamsByLeague() -> [Team] {
        let leagues = getSportsBySportsName().team
        var teams: [Team] = []
        for league in leagues {
            if selectedLeague == "全て" || league.league == selectedLeague {
                for team in league.teams {
                    teams.append(team)
                }
            }
        }
        return teams
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

struct League: Identifiable, Codable {
    var id = UUID()
    let league: String
    let teams: [Team]

    private enum CodingKeys: String, CodingKey {
        case league
        case teams
    }
}

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
