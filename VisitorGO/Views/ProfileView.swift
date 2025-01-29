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

struct ProfileView: View {
    var userId: Int

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

    @State var profile: UserDataResponse? = nil

    @ViewBuilder
    func body(tabType: TabType) -> some View {
        switch tabType {
            case .mine: ExpeditionsListView(expeditions: .init(
                get: { profile?.expeditions ?? [] },
                set: { profile?.expeditions = $0 }
            ))
            case .good: ExpeditionsListView(expeditions: .init(
                get: { profile?.likedExpeditions ?? [] },
                set: { profile?.likedExpeditions = $0 }
            ))
        }
    }

    func onUpdateOffset(before: CGFloat, new: CGFloat) {
        if defaultPos == nil { defaultPos = before; pos = 0 }
        offset = defaultPos! - new
    }

    var topHeight: CGFloat {
        return headerHeight + tabBarHeight
    }

    var body: some View {
        NavigationStack {
            ZStack(alignment: .top) {
                VStack {
                    Text("").frame(height: 30)

                    tabView
                }
                .zIndex(index)

                VStack {
                    header
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
                    .offset(y: offset >= topHeight - 38 ? -topHeight + 38 : -offset)
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
                .mask(Rectangle().padding(.bottom, offset >= topHeight - 20 ? -topHeight + 20 : offset))
            }
        }
        .onAppear {
            Task {
                APIHelper.shared.getUserDataById(userId: userId) { success, data in
                    profile = data
                }
            }
        }
    }

    @ViewBuilder
    private var tabView: some View {
        TabView(selection: $selectedTab) {
            ForEach(TabType.allCases, id: \.self) { type in
                ScrollView {
                    self.body(tabType: type)
                        .background(.white)
                        .padding(.top, topHeight)
                        .background {
                            GeometryReader { geo in
                                Color.clear.onChange(of: geo.frame(in: .global).minY) { before, new in
                                    onUpdateOffset(before: before, new: new)
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

    @ViewBuilder
    private var header: some View {
        VStack {
            HStack {
                VStack(alignment: .leading, spacing: 24) {
                    HStack(alignment: .center) {
                        HStack(alignment: .bottom) {
                            AsyncImage(url: URL(string: profile?.profileImage ?? "")) { image in
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
                                Text(profile?.name ?? "")
                                    .bold()
                                    .font(.title)

                                Text("@\(profile?.username ?? "")")
                                    .font(.caption)
                                    .foregroundStyle(.gray)
                            }
                            .padding(8)
                        }

                        Spacer()

                        if userData.userProfile?.id == profile?.id {
                            Menu {
                                Button("ログアウト", action: {
                                    helper.logout()
                                    userData.setProfile(success: true, profile: nil)
                                })
                                NavigationLink("プロフィール編集", destination: EditProfileView())
                            } label: {
                                Image(systemName: "ellipsis.circle")
                                    .imageScale(.large)
                            }
                        }
                    }

                    Text(profile?.description ?? "")

                    if userData.userProfile?.id == profile?.id {
                        HStack {
                            NavigationLink("プロフィール編集") {
                                EditProfileView()
                            }
                            .buttonStyle(.plain)
                            .padding(.horizontal)
                            .padding(.vertical, 8)
                            .overlay(RoundedRectangle(cornerRadius: 7).stroke(.black, lineWidth: 1))

                            if helper.isLoggedIn {
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
                }
                .background(.white)
                .padding(.horizontal)

                Spacer()
            }
        }
        .background {
            GeometryReader { geometry in
                Color.clear.onChange(of: geometry.frame(in: .global)) { _, new in
                    self.headerHeight = new.height
                }
            }
        }
    }
}

struct ExpeditionsListView: View {
    @Binding var expeditions: [Expedition]

    var body: some View {
        VStack(spacing: 20) {
            ForEach(expeditions, id: \.self) { expedition in
                ExpeditionNavigationView(expedition: expedition, ignoreType: .profile)
            }
        }
    }
}

#Preview {
    ProfileView(userId: 8)
}
