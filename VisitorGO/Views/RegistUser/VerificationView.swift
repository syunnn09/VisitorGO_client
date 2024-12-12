//
//  VerificationView.swift
//  VisitorGO
//
//  Created by shusuke imamura on 2024/12/10.
//

import SwiftUI

struct VerificationView: View {
    @Environment(\.dismiss) var dismiss
    var mail: String = "sample@gmail.com"

    var body: some View {
        NavigationStack {
            VStack {
                HStack {
                    Text("ビジター GO")
                        .font(.system(size: 22))
                    Spacer()
                }
                .padding(.horizontal)

                HeaderView(text: "本人確認")

                VStack(alignment: .leading, spacing: 40) {
                    Text("ご入力いただいたメールアドレス宛に本登録用のリンクを送信しました。\nメール内のリンクをクリックして、パスワードを設定し、ユーザー登録を完了してください。")

                    Text("メールアドレス: \(mail)").bold()

                    Button("メールを再送信する") {
                        dismiss()
                    }
                    .buttonStyle(BigButtonStyle(color: .green))
                    .padding(.bottom, 40)
                }
                .padding(20)

                Spacer()
            }
            .navigationBarBackButtonHidden()
        }
    }
}

#Preview {
    VerificationView()
}
