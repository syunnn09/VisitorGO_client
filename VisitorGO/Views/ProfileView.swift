//
//  ProfileView.swift
//  VisitorGO
//
//  Created by shusuke imamura on 2024/12/03.
//

import SwiftUI

enum TabType: String, CaseIterable {
    case mine = "記録"
    case good = "いいね"
}

struct Header: View {
    @ObservedObject var helper: APIHelper = .shared
    @ObservedObject var userData: UserData = .shared
    @Binding var selectedTab: TabType
    @Binding var height: CGFloat

    var body: some View {
        VStack {
            HStack {
                VStack(alignment: .leading, spacing: 24) {
                    HStack(alignment: .bottom) {
                        AsyncImage(url: URL(string: userData.userProfile?.profileImage ?? "")) { image in
                            image.resizable()
                                .clipShape(Circle())
                                .frame(width: 90, height: 90)
                        } placeholder: {
                            ZStack {
                                ProgressView()
                                Circle()
                                    .fill(Color.black.opacity(0.1))
                                    .frame(width: 90, height: 90)
                            }
                        }

                        VStack(alignment: .leading) {
                            Text(userData.userProfile?.name ?? "")
                                .font(.title)

                            Text("@syunnn0909___september")
                                .font(.caption)
                                .foregroundStyle(.gray)
                        }
                        .padding(8)
                    }

                    Text(userData.userProfile?.description ?? "")

                    HStack {
                        NavigationLink("プロフィール編集") {
                            EditProfileView()
                        }
                        .buttonStyle(.plain)
                        .padding(.horizontal)
                        .padding(.vertical, 8)
                        .overlay(RoundedRectangle(cornerRadius: 7).stroke(.black, lineWidth: 1))

                        if !helper.isLoggedIn {
                            NavigationLink("ログイン") {
                                LoginView()
                            }
                            .buttonStyle(.plain)
                            .padding(.horizontal)
                            .padding(.vertical, 8)
                            .overlay(RoundedRectangle(cornerRadius: 7).stroke(.black, lineWidth: 1))
                        } else {
                            Button("ログアウト") {
                                helper.logout()
                                userData.setProfile(success: true, profile: nil)
                            }
                            .buttonStyle(.plain)
                            .padding(.horizontal)
                            .padding(.vertical, 8)
                            .overlay(RoundedRectangle(cornerRadius: 7).stroke(.black, lineWidth: 1))
                        }
                    }
                }
                .padding(.horizontal)

                Spacer()
            }
        }
        .background {
            GeometryReader { geometry in
                Color.clear.onChange(of: geometry.frame(in: .global)) { _, new in
                    self.height = new.height
                }
            }
        }
    }
}

struct ProfileView: View {
    @ObservedObject var helper: APIHelper = .shared
    @ObservedObject var userData: UserData = .shared
    @State var selectedTab: TabType = .mine
    @State var headerHeight: CGFloat = 0
    @State var tabBarHeight: CGFloat = 0
    @State var offset: CGFloat = 0
    @State var defaultPos: CGFloat? = nil
    @State var pos: CGFloat = 0
    @State var beforeOffset: CGFloat = 0
    @State var index: Double = 1
    @Namespace var ns

    func onUpdateOffset(new: CGFloat) {
        if defaultPos == nil { defaultPos = new; pos = 0 }
        offset = defaultPos! - new
    }

    var topHeight: CGFloat {
        return headerHeight + tabBarHeight
    }

    var body: some View {
        NavigationStack {
            ZStack(alignment: .top) {
                VStack {
                    Text("").frame(height: 20)

                    tabView
                }
                .zIndex(index)

                VStack {
                    Header(selectedTab: $selectedTab, height: $headerHeight)
                        .offset(y: -offset)

                    VStack(alignment: .leading, spacing: 0) {
                        HStack {
                            ForEach(TabType.allCases, id: \.self) { type in
                                VStack(spacing: 0) {
                                    Text(type.rawValue)
                                        .font(.system(size: 22))
                                        .onTapGesture { withAnimation { selectedTab = type } }

                                    if selectedTab == type {
                                        Text(type.rawValue)
                                            .opacity(0)
                                            .frame(height: 1)
                                            .padding(.horizontal, 8)
                                            .border(.green)
                                            .matchedGeometryEffect(id: "border", in: ns, properties: .position)
                                    } else {
                                        Text(type.rawValue)
                                            .opacity(0)
                                            .frame(height: 1)
                                            .padding(.horizontal, 8)
                                    }
                                }
                            }
                        }.padding(.horizontal)

                        Divider()
                    }
                    .padding(.vertical)
                    .coordinateSpace(name: "header")
                    .offset(y: offset >= topHeight - 30 ? -topHeight + 30 : -offset)
                    .background {
                        GeometryReader { geometry in
                            Color.clear.onChange(of: geometry.frame(in: .named("header"))) { _, new in
                                tabBarHeight = new.height
                            }
                        }
                    }
                }
                .zIndex(2)
                .onChange(of: selectedTab) {
                    withAnimation {
                        let temp = offset
                        offset = beforeOffset
                        beforeOffset = temp
                    }
                }
            }
        }
        .refreshable {
            UserData.shared.getProfile()
        }
    }

    @ViewBuilder
    private var tabView: some View {
        TabView(selection: $selectedTab) {
            ForEach(TabType.allCases, id: \.self) { type in
                ScrollView {
                    VStack(spacing: 20) {
                        ForEach(1...5, id: \.self) { _ in
                            PostRowView()
                            Divider()
                        }
                    }
                    .background(.white)
                    .padding(.top, topHeight)
                    .background {
                        GeometryReader { geo in
                            Color.clear.onChange(of: geo.frame(in: .global).minY) { _, new in
                                onUpdateOffset(new: new)
                            }
                            Color.clear.onChange(of: geo.frame(in: .global).minX) { _, new in
                                index = new == 0 ? 1 : 3
                            }
                        }
                    }
                }
            }
        }
        .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
    }
}

#Preview {
    ProfileView()
}
