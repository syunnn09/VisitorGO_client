//
//  ContentView.swift
//  VisitorGO
//
//  Created by shusuke imamura on 2024/11/18.
//

import SwiftUI

enum SelectTab: String {
    case home = "ホーム"
    case post = "投稿"
    case prof = "プロフィール"
    case snack = "スナックバー"

    var icon: String {
        switch (self) {
            case .home: return "house"
            case .post: return "pencil"
            case .prof: return "person.crop.circle"
            case .snack: return "snowboard"
        }
    }
}

let baseURL = "https://visitor-temp-server.onrender.com"
let feedbackGenerator = UIImpactFeedbackGenerator(style: .medium)

struct ContentView: View {
    @State var selectSports = false
    @State var selectedTab: SelectTab = .home
    @State var beforeTab: SelectTab = .home
    @State var selectedSports: Sports? = nil

    var body: some View {
        ZStack {
            TabView(selection: $selectedTab) {
                HomeView()
                    .tabItem {
                        HStack {
                            Image(systemName: SelectTab.home.icon)
                            Text("ホーム")
                        }
                    }
                    .tag(SelectTab.home)

                if selectedSports != nil {
                    CreatePostView(sports: $selectedSports)
                        .tabItem {
                            HStack {
                                Image(systemName: SelectTab.post.icon)
                                Text("投稿")
                            }
                        }
                        .tag(SelectTab.post)
                } else {
                    Color.gray
                        .ignoresSafeArea(edges: .all)
                        .tabItem {
                            HStack {
                                Image(systemName: SelectTab.post.icon)
                                Text("投稿")
                            }
                        }
                        .tag(SelectTab.post)
                }

                ProfileView(userId: UserData.shared.userProfile?.id ?? 0)
                    .tabItem {
                        HStack {
                            Image(systemName: SelectTab.prof.icon)
                            Text("プロフィール")
                        }
                    }
                    .tag(SelectTab.prof)
            }
            .zIndex(100)
            .onChange(of: selectedTab) { _, new in
                feedbackGenerator.impactOccurred()
                if selectedTab == SelectTab.post {
                    selectSports = true
                } else {
                    beforeTab = new
                }
            }
            .sheet(isPresented: $selectSports, onDismiss: {
                if selectedSports == nil {
                    selectedTab = beforeTab
                }
            }) {
                SportsSelectView(selection: $selectedSports, selectSports: $selectSports)
                    .presentationDetents([.medium])
                    .presentationDragIndicator(.visible)
            }

            Snackbar()
                .zIndex(101)
        }
    }
}

#Preview {
    ContentView()
}
