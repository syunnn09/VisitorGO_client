//
//  Payment.swift
//  VisitorGO
//
//  Created by shusuke imamura on 2024/11/29.
//

import SwiftUI

struct Payment: Identifiable, Hashable {
    let id = UUID()
    let title: String
    let date: Date
    let cost: Int

    var day: String {
        let calendar = Calendar(identifier: .gregorian)
        let year = calendar.component(.year, from: date)
        let month = calendar.component(.month, from: date)
        let day = calendar.component(.day, from: date)
        return "\(year)年\(month)月\(day)日"
    }
}

extension Payment {
    static func calcSum(_ payments: [Payment]) -> Int {
        return payments.map({ $0.cost }).reduce(0, +)
    }
}
