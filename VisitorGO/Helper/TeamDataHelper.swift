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

    @Published var teamData: TeamData? = nil
    @Published var selectedSports: SportsData? = nil
    @Published var selectedLeague: String = "全て"
    @Published var favoriteTeams: [Team] = []
    @Published var allData: SportsData? = nil

    init() {
        let isLogin = APIHelper.shared.loginToken != nil
        let endpoint = isLogin ? "me" : "public"
        let url = APIHelper.shared.getURL("api/team/\(endpoint)")

        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        if isLogin {
            if let token = APIHelper.shared.loginToken {
                request.setValue("\(token)", forHTTPHeaderField: "Authorization")
            }
        }

        URLSession.shared.dataTask(with: request) { (data, response, error) in
            guard let jsonData = try? JSONDecoder().decode(TeamData.self, from: data!) else { print("\(#function) decode error!"); return }
            DispatchQueue.main.async {
                self.selectedSports = jsonData.data.first!
                self.teamData = jsonData
                self.allData = SportsData(sports: "推しチーム", icon: "heart", team: [], ignore: true)
                self.teamData!.data.insert(self.allData!, at: 0)
                self.createAllData()
            }
        }.resume()
    }

    var favoriteTeamIds: [Int] {
        return favoriteTeams.map({ $0.id })
    }

    func createAllData() {
        guard var teamData = teamData else { return }

        var leagues: [League] = []
        for sports in teamData.data {
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
        teamData.data.replace(pos: 0, data: allData)
        self.teamData = teamData
    }

    func toggle(team: Team) {
        if let index = favoriteTeams.firstIndex(where: { $0.id == team.id }) {
            favoriteTeams.remove(at: index)
        } else {
            favoriteTeams.append(team)
        }
        team.isFavorite.toggle()
        self.createAllData()
    }

    func getSportsBySportsName() -> SportsData {
        guard let teamData = teamData else { return SportsData(sports: "サッカー", icon: "soccerball", team: []) }

        for sports in teamData.data {
            if sports.sports == selectedSports?.sports {
                return sports
            }
        }
        return teamData.data.first!
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
