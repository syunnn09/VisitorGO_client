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
    @Binding var selectedTab: TabType
    @Binding var height: CGFloat

    var body: some View {
        VStack {
            HStack {
                VStack(alignment: .leading, spacing: 24) {
                    HStack(alignment: .bottom) {
                        Image("nakaya")
                            .resizable()
                            .frame(width: 90, height: 90)

                        Text("nakaya")
                            .font(.title)
                    }

                    Text("野球大好きです！\n\n⚾️推しチーム\n楽天\n阪神\nカープ")

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
    @State var selectedTab: TabType = .mine
    @State var headerHeight: CGFloat = 0
    @State var tabBarHeight: CGFloat = 0
    @State var offset: CGFloat = 0
    @State var defaultPos: CGFloat? = nil
    @State var pos: CGFloat = 0
    @Namespace var ns

    func onUpdateOffset(new: CGFloat) {
        if defaultPos == nil { defaultPos = new }
        offset = defaultPos! - new
    }

    var topHeight: CGFloat {
        return headerHeight + tabBarHeight
    }

    var body: some View {
        NavigationStack {
            ZStack(alignment: .top) {
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
                    .background {
                        GeometryReader { geometry in
                            Color.clear.onChange(of: geometry.frame(in: .named("header")).minY) { _, new in
                                print("new: \(-new)")
//                                pos = max(0, -new + 100)
                                pos = new
                                print("pos: \(pos)")
                                print("offset: \(offset)")
                            }
                            Color.clear.onChange(of: geometry.frame(in: .named("header"))) { _, new in
                                tabBarHeight = new.height
                            }
                        }
                    }
//                    .offset(y: pos)
                }

                tabView
            }
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
                    .background {
                        GeometryReader { geo in
                            Color.clear.onChange(of: geo.frame(in: .global).minY) { _, new in
                                onUpdateOffset(new: new)
                            }
                        }
                    }
                    .padding(.top, topHeight)
                }
            }
        }
        .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
    }
}

#Preview {
    ProfileView()
}
