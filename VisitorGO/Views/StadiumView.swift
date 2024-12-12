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

    var showNavigation: Bool {
        maxY < 90
    }

    var body: some View {
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
//                                    .padding(4)
//                                    .background(.black)
                                
                                Spacer()
                                
                                NavigationLink("追加") {
                                    CreatePostView(sports: $sports)
                                }
                                .buttonStyle(.borderedProminent)
                                .clipShape(RoundedRectangle(cornerRadius: 20))
                            }
                            .padding(.horizontal)
//                            .background(.black)
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

                    VStack(spacing: 20) {
                        Picker("", selection: $pickerTab) {
                            Text(ShowingType.list.rawValue).tag(ShowingType.list)
                            Text(ShowingType.around.rawValue).tag(ShowingType.around)
                        }.pickerStyle(.segmented)
                            .padding(.horizontal)
                        
                        if pickerTab == ShowingType.list {
                            ForEach(1...5, id: \.self) { _ in
                                PostRowView()
                                Divider()
                            }
                        } else if pickerTab == ShowingType.around {
                            Text("周辺施設")
                        }
                    }
                }
            }
            .ignoresSafeArea(edges: .top)
            .toolbar(showNavigation ? .visible : .hidden)
            .toolbar {
                ToolbarItem(placement: .principal) {
                    Text("京セラドーム")
                }
            }
        }
    }
}

#Preview {
    StadiumView()
}
