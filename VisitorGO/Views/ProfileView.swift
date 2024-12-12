//
//  ProfileView.swift
//  VisitorGO
//
//  Created by shusuke imamura on 2024/12/03.
//

import SwiftUI

struct ProfileView: View {
    var body: some View {
        NavigationStack {
            NavigationLink("プロフィール編集") {
                EditProfileView()
            }

            NavigationLink("ログイン") {
                LoginView()
            }
        }
    }
}

#Preview {
    ProfileView()
}
