//
//  StadiumView.swift
//  VisitorGO
//
//  Created by shusuke imamura on 2024/12/10.
//

import SwiftUI

enum ShowingType: String {
    case list = "投稿一覧"
    case around = "周辺施設"
}

struct StadiumView: View {
    @State var pickerTab: ShowingType = .list
    @State var sports: Sports? = .baseball
    @State var maxY: CGFloat = 100
    var width = UIScreen.main.bounds.width

    var showNavigation: Bool {
        maxY < 90
    }

    var body: some View {
        GeometryReader { geometry in
            NavigationStack {
                ScrollView {
                    VStack {
                        Image("dome")
                            .resizable()
                            .scaledToFit()
                            .overlay(alignment: .bottomLeading) {
                                HStack {
                                    Text("京セラドーム大阪")
                                        .foregroundStyle(.white)
                                        .font(.system(size: 26))
                                    
                                    Spacer()
                                    
                                    NavigationLink("追加") {
                                        CreatePostView(sports: $sports)
                                    }
                                    .buttonStyle(.borderedProminent)
                                    .clipShape(RoundedRectangle(cornerRadius: 20))
                                }
                                .padding(.horizontal)
                            }
                            .coordinateSpace(name: "image")
                            .background {
                                GeometryReader { geometry in
                                    Color.clear.onChange(of: geometry.frame(in: .named("image")).maxY) { _, new in
                                        withAnimation {
                                            maxY = new
                                        }
                                    }
                                }
                            }
                        
                        HStack {
                            Button(ShowingType.list.rawValue) {
                                withAnimation {
                                    pickerTab = ShowingType.list
                                }
                            }.padding()
//                            .bold(pickerTab == ShowingType.list)
                            
                            Button(ShowingType.around.rawValue) {
                                withAnimation {
                                    pickerTab = ShowingType.around
                                }
                            }.padding()
//                                .bold(pickerTab == ShowingType.list)
                        }
                        .onChange(of: pickerTab) {
                            if pickerTab == ShowingType.list {
                                print(geometry.frame(in: .named("allView")).height)
                            } else {
                                print(geometry.frame(in: .named("aroundView")).height)
                            }
                        }
                        
                        HStack(alignment: .top) {
                            AllView()
                                .frame(width: width)
                                .coordinateSpace(name: "allView")
                            
                            AroundView()
                                .frame(width: width)
                                .coordinateSpace(name: "aroundView")
                        }
                        .frame(width: width)
                        .offset(x: (pickerTab == ShowingType.list ? width : -width) / 2)
                    }
                }
                .ignoresSafeArea(edges: .top)
                .toolbar(showNavigation ? .visible : .hidden)
                .toolbar {
                    ToolbarItem(placement: .principal) {
                        Text("京セラドーム \(pickerTab.rawValue)")
                    }
                }
            }
        }
    }
}

struct AllView: View {
    var body: some View {
        VStack(spacing: 20) {
            ForEach(1...5, id: \.self) { _ in
                PostRowView()
                Divider()
            }
        }
    }
}

struct AroundView: View {
    var body: some View {
        VStack {
            Text("周辺施設")
        }
    }
}

#Preview {
    StadiumView()
}
