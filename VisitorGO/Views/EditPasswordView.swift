//
//  EditPasswordView.swift
//  VisitorGO
//
//  Created by shusuke imamura on 2025/02/14.
//

import SwiftUI

struct EditPasswordView: View {
    @Environment(\.dismiss) var dismiss

    @State var beforePassword: String = ""
    @State var newPassword: String = ""
    @State var isLoading: Bool = false
    @State var message: String = ""

    var body: some View {
        ScrollView(showsIndicators: false) {
            HeaderView(text: "パスワード変更")

            VStack(spacing: 24) {
                VStack(alignment: .leading) {
                    Text("旧パスワード")
                    TextField("旧パスワード", text: $beforePassword)
                        .textFieldStyle(.roundedBorder)
                }
                
                VStack(alignment: .leading) {
                    Text("新パスワード")
                    TextField("新パスワード", text: $newPassword)
                        .textFieldStyle(.roundedBorder)
                }

                Text(message)
                    .foregroundStyle(.red)

                LoadingButton(isLoading: $isLoading, text: "変更") {
                    self.message = ""
                    self.isLoading = true
                    feedbackGenerator.impactOccurred()

                    APIHelper.shared.updatePassword(beforePassword: beforePassword, newPassword: newPassword) { success, message in
                        Task {
                            self.isLoading = false
                            if success {
                                dismiss()
                                SnackBarManager.shared.show("パスワードが更新されました", .success)
                            } else {
                                self.message = message
                            }
                        }
                    }
                }
            }
            .padding()
        }
    }
}

#Preview {
    EditPasswordView()
}
