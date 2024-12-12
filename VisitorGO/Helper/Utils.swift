//
//  Utils.swift
//  VisitorGO
//
//  Created by shusuke imamura on 2024/11/28.
//

import SwiftUI
import Foundation

extension Date {
    static var defaultFormat: String = "yyyy年MM月dd日"

    func toString() -> String {
        let formatter: DateFormatter = DateFormatter()
        formatter.calendar = Calendar(identifier: .gregorian)
        formatter.dateFormat = Date.defaultFormat
        return formatter.string(from: self)
    }
}

extension Array where Element: Equatable {
    mutating func replace(pos: Int, data: Array.Element) {
        self = self.map { (self.firstIndex(of: $0) == pos) ? data : $0 }
    }
}

struct HeaderView: View {
    let text: String

    var body: some View {
        ZStack(alignment: .center) {
            Text(text)
                .font(.system(size: 20))
                .padding()
            
            Rectangle()
                .foregroundStyle(.gray.opacity(0.2))
        }
        .frame(height: 55)
    }
}
