//
//  SetPasswordView.swift
//  VisitorGO
//
//  Created by shusuke imamura on 2024/12/10.
//

import SwiftUI

struct SetPasswordView: View {
    @State var password: String = ""
    @State var confirm: String = ""

    var body: some View {
        NavigationStack {
            VStack {
                HStack {
                    Text("ビジター GO")
                        .font(.system(size: 22))
                    Spacer()
                }
                .padding(.horizontal)

                HeaderView(text: "パスワード設定")
                
                VStack(alignment: .leading, spacing: 20) {
                    VStack(alignment: .leading) {
                        Text("パスワード")
                        SecureField("パスワードを入力してください", text: $password)
                            .textFieldStyle(.roundedBorder)
                    }

                    VStack(alignment: .leading) {
                        Text("確認用パスワード")
                        SecureField("確認用パスワードを入力してください", text: $confirm)
                            .textFieldStyle(.roundedBorder)
                    }

                    Button("設定する") {
                        
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
    SetPasswordView()
}
