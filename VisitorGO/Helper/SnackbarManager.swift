//
//  SnackbarManager.swift
//  VisitorGO
//
//  Created by shusuke imamura on 2024/12/19.
//

import SwiftUI

struct SnackBarColor {
    let foregroundColor: Color
    let backgroundColor: Color

    init(_ fg: Color, _ bg: Color) {
        self.foregroundColor = fg
        self.backgroundColor = bg
    }
}

enum SnackBarStatus: String, CaseIterable {
    case success = "success"
    case error = "error"
    case info = "info"
    case warn = "warn"

    var color: SnackBarColor {
        switch self {
            case .success: .init(.white, .green)
            case .error: .init(.white, .red)
            case .info: .init(.white, .mint)
            case .warn: .init(.black, .yellow)
        }
    }

    var image: String {
        switch self {
            case .success: return "checkmark.circle"
            case .error: return "x.circle"
            case .info: return "info.circle"
            case .warn: return "info.circle"
        }
    }
}

class SnackBarManager: ObservableObject {
    static let shared = SnackBarManager()

    @Published var text: String = ""
    @Published var offset: CGFloat = 100
    @Published var status: SnackBarStatus = .success
    var timer: Timer?

    func toggle(_ isPresented: Bool) {
        withAnimation {
            offset = isPresented ? 0 : 100
        }
    }

    func show(_ text: String, _ status: SnackBarStatus) {
        self.timer?.invalidate()
        self.offset = 100
        self.text = text
        self.status = status
        self.toggle(true)
        feedbackGenerator.impactOccurred()

        self.timer = Timer.scheduledTimer(withTimeInterval: 5.0, repeats: false) { _ in
            self.close()
        }
    }

    func error() {
        self.show("エラーが発生しました。", .error)
    }

    func error(_ message: String) {
        self.show(message, .error)
    }

    func close() {
        self.timer?.invalidate()
        self.timer = nil
        self.toggle(false)
    }
}

struct Snackbar: View {
    @ObservedObject var manager: SnackBarManager = .shared
    @State var color: Color = .red

    var body: some View {
        VStack {
            Spacer()
            
            manager.status.color.backgroundColor.frame(height: 100)
                .overlay(alignment: .topLeading) {
                    HStack {
                        Image(systemName: manager.status.image)
                        Text(manager.text)
                    }
                    .foregroundStyle(manager.status.color.foregroundColor)
                    .padding()
                }
                .offset(y: manager.offset)
        }
        .ignoresSafeArea()
        .onTapGesture {
            manager.toggle(false)
        }
    }
}

struct SnackBarPreview: View {
    @State var status: SnackBarStatus = .success

    var body: some View {
        VStack(spacing: 20) {
            Picker("", selection: $status) {
                ForEach(SnackBarStatus.allCases, id: \.self) { status in
                    Text(status.rawValue)
                        .foregroundStyle(status.color.foregroundColor)
                }
            }.pickerStyle(.segmented)

            Button("表示") {
                SnackBarManager.shared.show("プロフィールを更新しました", status)
            }
        }
    }
}

#Preview {
    ZStack {
        SnackBarPreview()

        Snackbar()
    }
}
