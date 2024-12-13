//
//  ProfileView.swift
//  VisitorGO
//
//  Created by shusuke imamura on 2024/12/03.
//

import SwiftUI

struct ProfileView: View {
    var helper: APIHelper = .shared

    var body: some View {
        NavigationStack {
            NavigationLink("プロフィール編集") {
                EditProfileView()
            }

            if !helper.isLoggedIn {
                NavigationLink("ログイン") {
                    LoginView()
                }
            } else {
                Button("ログアウト") {
                    helper.logout()
                }.buttonStyle(.borderedProminent)
            }
        }
    }
}

#Preview {
    ProfileView()
}
