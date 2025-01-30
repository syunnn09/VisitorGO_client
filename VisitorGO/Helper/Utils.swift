//
//  Utils.swift
//  VisitorGO
//
//  Created by shusuke imamura on 2024/11/28.
//

import MapKit
import SwiftUI
import Foundation

extension Date {
    static var defaultFormat: String = "yyyy年M月d日"

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

extension UUID {
    static func prefix(_ length: Int) -> String {
        let id = UUID().uuidString
        return String(id.prefix(length))
    }
}

extension String {
    func toDate() -> String {
        return ISO8601DateFormatter().date(from: self)?.toString() ?? ""
    }
}

extension Date {
    func toISOString() -> String {
        return ISO8601DateFormatter().string(from: self)
    }
}

extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
            case 3:
                (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
            case 6:
                (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
            case 8:
                (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
            default:
                (a, r, g, b) = (1, 1, 1, 0)
        }
        
        self.init(.sRGB, red: Double(r) / 255, green: Double(g) / 255, blue:  Double(b) / 255, opacity: Double(a) / 255)
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

let colorGradient = LinearGradient(gradient: Gradient(colors: [
    Color.yellow,
    Color.yellow.opacity(0.75),
    Color.yellow.opacity(0.5),
    Color.yellow.opacity(0.2),
    .clear]),
    startPoint: .leading, endPoint: .trailing)

struct LoadingButton: View {
    @Binding var isLoading: Bool
    var text: String
    var color: Color = .green

    @MainActor var action: () -> Void
    @State var currentDegrees: Double = 0.0

    var body: some View {
        Button {
            currentDegrees = 0
            feedbackGenerator.impactOccurred()
            action()
        } label: {
            if isLoading {
                Circle()
                    .trim(from: 0.0, to: 0.85)
                    .stroke(colorGradient, style: StrokeStyle(lineWidth: 4))
                    .frame(width: 20, height: 20)
                    .rotationEffect(Angle(degrees: currentDegrees))
                    .onAppear {
                        Timer.scheduledTimer(withTimeInterval: 0.05, repeats: true) { _ in
                            withAnimation {
                                if isLoading {
                                    self.currentDegrees += 10
                                }
                            }
                        }
                    }
            } else {
                Text(text)
                    .font(.system(size: 17))
            }
        }
        .buttonStyle(BigButtonStyle(color: color))
    }
}

#Preview {
    @Previewable @State var isLoading = false
    LoadingButton(isLoading: $isLoading, text: "登録") {
        isLoading.toggle()
    }.padding()
}
