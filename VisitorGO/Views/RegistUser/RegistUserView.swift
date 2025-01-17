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
                        .padding(.bottom, 16)

                    LoadingButton(isLoading: $isLoading, text: "ユーザー登録", color: color) {
                        if valid {
                            feedbackGenerator.impactOccurred()
                            isLoading = true
                            APIHelper.shared.sendMail(mail: mail) { result in
                                isLoading = false
                                sent = true
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
                .navigationDestination(isPresented: $sent) {
                    VerificationView(mail: mail)
                }

                Spacer()
            }
        }
    }
}

#Preview {
    RegistUserView()
}
