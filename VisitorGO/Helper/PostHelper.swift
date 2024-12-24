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

    @Published var firstPoint: [Int] = []
    @Published var secondPoint: [Int] = []
    @Published var date: [Date] = []

    convenience init() {
        self.init(1)
    }

    init(_ games: Int) {
        for _ in 0..<games {
            self.append()
        }
    }

    func append() {
        games += 1
        firstPoint.append(0)
        secondPoint.append(0)
        date.append(.now)
    }

    func update(_ index: Int) {
        for i in index..<games {
            firstPoint[i] = firstPoint[i+1]
            secondPoint[i] = secondPoint[i+1]
            date[i] = date[i+1]
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
        }
    }
}
