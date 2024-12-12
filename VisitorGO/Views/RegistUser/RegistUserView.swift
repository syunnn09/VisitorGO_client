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

                    NavigationLink("ユーザー登録") {
                        VerificationView(mail: mail)
                    }
                    .buttonStyle(BigButtonStyle(color: color))
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
            .navigationBarBackButtonHidden()
        }
    }
}

#Preview {
    RegistUserView()
}
