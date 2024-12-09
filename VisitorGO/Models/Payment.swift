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
}

extension Payment {
    static func calcSum(_ payments: [Payment]) -> Int {
        return payments.map({ $0.cost }).reduce(0, +)
    }
}
