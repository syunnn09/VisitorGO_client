//
//  LoginView.swift
//  VisitorGO
//
//  Created by shusuke imamura on 2024/12/09.
//

import SwiftUI

struct LoginView: View {
    @State var mail: String = ""
    @State var password: String = ""
    @State var isCreate = false
    @State var doLogin = false
    @State var success = false
    @State var isError = false

    var valid: Bool {
        !mail.isEmpty && !password.isEmpty
    }

    var color: Color {
        valid ? .green : .gray
    }

    func onLogin(result: Bool) {
        doLogin = false
        if result {
            success = true
        } else {
            isError = true
        }
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

                HeaderView(text: "ログイン")

                Text(isError ? "メールアドレスまたはパスワードが間違っています" : "")
                    .foregroundStyle(.red)
                    .frame(height: 30)

                VStack(alignment: .leading) {
                    Text("メールアドレス")
                    TextField("", text: $mail)
                        .textFieldStyle(.roundedBorder)
                        .padding(.bottom, 16)

                    Text("パスワード")
                    SecureField("", text: $password)
                        .textFieldStyle(.roundedBorder)
                        .padding(.bottom, 16)

                    LoadingButton(isLoading: $doLogin, text: "ログイン", color: color) {
                        if valid {
                            isError = false
                            doLogin = true
                            APIHelper.shared.login(email: mail, password: password, completion: onLogin)
                        }
                    }
                    .padding(.bottom, 40)

                    VStack(alignment: .leading) {
                        Text("まだユーザー登録していない方は")
                        HStack(spacing: 0) {
                            NavigationLink("こちらから登録") {
                                RegistUserView()
                            }
                            Text("してください")
                            Spacer()
                        }
                    }
                }
                .padding(.horizontal, 40)

                Spacer()
            }
            .navigationDestination(isPresented: $success) {
                ContentView()
                    .navigationBarBackButtonHidden()
            }
        }
    }
}

#Preview {
    LoginView()
}
