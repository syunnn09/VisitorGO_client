//
//  Payment.swift
//  VisitorGO
//
//  Created by shusuke imamura on 2024/11/29.
//

import SwiftUI

struct Payment: Identifiable, Hashable, Codable {
    var id = UUID()
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

struct PaymentRequest: Codable {
    var title: String
    var date: String
    var cost: Int

    init(_ payment: Payment) {
        self.title = payment.title
        self.date = payment.date.toISOString()
        self.cost = payment.cost
    }
}

extension PaymentRequest {
    static func convert(payments: [Payment]) -> [PaymentRequest] {
        var paymentRequests: [PaymentRequest] = []
        for payment in payments {
            paymentRequests.append(PaymentRequest(payment))
        }
        return paymentRequests
    }
}
