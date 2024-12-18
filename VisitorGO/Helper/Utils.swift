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

extension UUID {
    static func prefix(_ length: Int) -> String {
        let id = UUID().uuidString
        return String(id.prefix(length))
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
