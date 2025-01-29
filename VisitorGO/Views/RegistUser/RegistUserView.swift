//
//  RegistUserView.swift
//  VisitorGO
//
//  Created by shusuke imamura on 2024/12/10.
//

import SwiftUI

struct RegistUserView: View {
    @Environment(\.dismiss) var dismiss
    @State var mail: String = ""
    @State var sent: Bool = false
    @State var isLoading: Bool = false
    @State var messages: [String] = [""]

    var valid: Bool {
        !mail.isEmpty
    }

    var color: Color {
        valid ? .green : .gray
    }

    var body: some View {
        NavigationStack {
            VStack {
                HStack {
                    Text("ビジター GO")
                        .font(.system(size: 22))
                    Spacer()
                }
                .padding(.horizontal)

                HeaderView(text: "ユーザー登録")

                VStack(alignment: .leading) {
                    Text("メールアドレス")
                    TextField("", text: $mail)
                        .textFieldStyle(.roundedBorder)

                    Text(messages[0])
                        .foregroundStyle(.red)
                        .font(.system(size: 14))
                        .padding(.bottom, 16)

                    LoadingButton(isLoading: $isLoading, text: "ユーザー登録", color: color) {
                        if valid {
                            isLoading = true
                            feedbackGenerator.impactOccurred()
                            APIHelper.shared.sendMail(mail: mail) { result, messages in
                                self.isLoading = false
                                self.sent = result
                                self.messages = messages
                            }
                        }
                    }
                    .padding(.bottom, 40)

                    VStack(alignment: .leading) {
                        Text("すでに登録済みの方は、")
                        HStack(spacing: 0) {
                            Button("こちらからログイン") {
                                dismiss()
                            }
                            .buttonStyle(.plain)
                            .foregroundStyle(.blue)
                            Text("してください")
                            Spacer()
                        }
                    }
                }
                .padding(.horizontal, 40)

                Spacer()
            }
            .navigationDestination(isPresented: $sent) {
                VerificationView(mail: mail)
            }
        }
    }
}

#Preview {
    RegistUserView()
}
