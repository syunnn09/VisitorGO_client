//
//  PostHelper.swift
//  VisitorGO
//
//  Created by shusuke imamura on 2024/12/19.
//

import SwiftUI

class PostHelper: ObservableObject {
    static let shared = PostHelper()

    @Published var games: Int = 0

    @Published var firstTeam: [TeamResponse] = []
    @Published var secondTeam: [TeamResponse] = []
    @Published var firstPoint: [Int] = []
    @Published var secondPoint: [Int] = []
    @Published var date: [Date] = []

    @Published var teamList: [TeamResponse] = []

    convenience init() {
        self.init(1)
    }

    init(_ games: Int) {
        for _ in 0..<games {
            self.initAppend()
        }
    }

    func setTeamList(_ teamList: [TeamResponse]) {
        DispatchQueue.main.async {
            self.firstTeam = []
            self.secondTeam = []
            self.teamList = teamList
            self.firstTeam.append(teamList.first!)
            self.secondTeam.append(teamList.first!)
        }
    }

    func initAppend() {
        games += 1
        firstPoint.append(0)
        secondPoint.append(0)
        date.append(.now)
    }

    func append() {
        games += 1
        firstPoint.append(0)
        firstTeam.append(teamList.first!)
        secondPoint.append(0)
        secondTeam.append(teamList.first!)
        date.append(.now)
    }

    func update(_ index: Int) {
        for i in index..<games {
            firstPoint[i] = firstPoint[i+1]
            secondPoint[i] = secondPoint[i+1]
            date[i] = date[i+1]
            firstTeam[i] = firstTeam[i+1]
            secondTeam[i] = secondTeam[i+1]
        }
    }

    func delete(_ index: Int) {
        withAnimation(completionCriteria: .removed) {
            games -= 1
            self.update(index)
        } completion: {
            self.firstPoint.remove(at: self.games-1)
            self.secondPoint.remove(at: self.games-1)
            self.date.remove(at: self.games-1)
            self.firstTeam.remove(at: self.games-1)
            self.secondTeam.remove(at: self.games-1)
        }
    }
}

struct GameRequest: Codable {
    let comment: String
    let date: String
    let scores: [GameScoreRequest]
    let team1Id: Int
    let team2Id: Int

    init(item: PostHelper, index: Int) {
        self.comment = ""
        self.date = item.date[index].toString()
        self.scores = GameScoreRequest.convert()
        self.team1Id = 1
        self.team2Id = 2
    }
}

extension GameRequest {
    static func convert(_ postHelperItems: [PostHelper]) -> [GameRequest] {
        var requests: [GameRequest] = []

        for (index, item) in postHelperItems.enumerated() {
            requests.append(GameRequest(item: item, index: index))
        }
        return requests
    }
}

struct GameScoreRequest: Codable {
    let order: Int
    let score: Int
    let teamId: Int

    init() {
        self.order = 1
        self.score = 3
        self.teamId = 1
    }
}

extension GameScoreRequest {
    static func convert() -> [GameScoreRequest] {
        return [GameScoreRequest(), GameScoreRequest()]
    }
}
