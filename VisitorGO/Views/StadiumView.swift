//
//  StadiumView.swift
//  VisitorGO
//
//  Created by shusuke imamura on 2024/12/10.
//

import SwiftUI

enum ShowingType: String, CaseIterable {
    case all = "投稿一覧"
    case around = "周辺施設"
}

struct StadiumView: View {
    var stadiumId: Int

    @State var pickerTab: ShowingType = .all
    @State var sports: Sports? = .baseball
    @State var maxY: CGFloat = 100
    @State var defaultHeight: CGFloat? = nil
    @State var scaleSize: CGFloat = 1
    @State var top: CGFloat = 0
    @State var imageOffset: CGFloat = 0
    @State var headerHeight: CGFloat = 0
    @State var defaultOffset: CGFloat? = nil
    @State var offset: CGFloat = 0

    @State var data: StadiumResponseBody? = nil

    var width = UIScreen.main.bounds.width
    @Namespace var ns

    @ViewBuilder
    func body(showingType: ShowingType) -> some View {
        switch showingType {
            case .all: AllView(expeditions: .init(
                get: { data?.expeditions },
                set: { data?.expeditions = $0 ?? [] }
            ))
            case .around: AroundView()
        }
    }

    func updateOffset(before: CGFloat, new: CGFloat) {
        if defaultOffset == nil { defaultOffset = before }
        if defaultHeight == nil { defaultHeight = before }
        imageOffset = max(0, -(defaultHeight! - new - top))
        scaleSize = max(1, 1 - (defaultHeight! - new - top) * 0.005)
        self.offset = defaultOffset! - new
    }

    var body: some View {
        GeometryReader { geometry in
            NavigationStack {
                ZStack(alignment: .top) {
                    VStack {
                        TabView(selection: $pickerTab) {
                            ForEach(ShowingType.allCases, id: \.self) { type in
                                ScrollView {
                                    body(showingType: type)
                                        .padding(.top, headerHeight)
                                        .background {
                                            GeometryReader { geo in
                                                Color.clear.onChange(of: geo.frame(in: .global).minY) { before, new in
                                                    updateOffset(before: before, new: new)
                                                }
                                            }
                                        }
                                }
                            }
                        }
                        .tabViewStyle(.page(indexDisplayMode: .never))
                    }

                    header
                        .offset(y: -offset)
                }
                .mask(Rectangle().padding(.bottom, top))
            }
            .navigationBarTitleDisplayMode(.inline)
            .onAppear {
                top = geometry.safeAreaInsets.top
            }
            .toolbar {
                ToolbarItem(placement: .principal) {
                    Text(data?.name ?? "").bold()
                }

                ToolbarItem(placement: .topBarTrailing) {
                    NavigationLink("追加") {
                        CreatePostView(sports: $sports)
                    }
                }
            }
        }
        .onAppear {
            APIHelper.shared.getStadium(stadiumId: stadiumId) { result in
                self.data = result
            }
        }
    }

    @ViewBuilder
    private var header: some View {
        VStack {
            Image("dome")
                .resizable()
                .scaledToFit()
                .scaleEffect(scaleSize)
                .offset(y: -imageOffset)

            VStack(alignment: .leading, spacing: 0) {
                HStack {
                    ForEach(ShowingType.allCases, id: \.self) { type in
                        VStack(spacing: 0) {
                            Text(type.rawValue)
                                .font(.system(size: 22))
                                .onTapGesture { withAnimation { pickerTab = type } }

                            if pickerTab == type {
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
            .padding(.vertical, 14)
        }
        .background {
            GeometryReader { geometry in
                Color.clear.onChange(of: geometry.frame(in: .global)) { _, new in
                    headerHeight = new.height
                }
            }
        }
    }
}

struct AllView: View {
    @Binding var expeditions: [Expedition]?

    var body: some View {
        if let expeditions = expeditions {
            VStack(spacing: 20) {
                ForEach(expeditions, id: \.self) { expedition in
                    PostRowView(expedition: expedition)
                }
            }
        }
    }
}

let sampleData = ["桜島", "イオンタウン姶良", "鹿児島中央駅"]

struct AroundView: View {
    var body: some View {
        VStack(spacing: 20) {
            VStack(spacing: 0) {
                ForEach(sampleData, id: \.self) { data in
                    Button {
                        UIApplication.shared.open(URL(string: "https://www.google.com/maps/dir/?api=1&destination=\(data)&travelmode=train")!)
                    } label: {
                        HStack {
                            Image(systemName: "mappin")
                            VStack(alignment: .leading) {
                                Text(data)
                                Text("100人が訪れました")
                                    .font(.system(size: 13))
                                    .opacity(0.7)
                            }
                            .font(.title2)
                            .buttonStyle(.plain)
                            .padding(.vertical)

                            Spacer()
                            Image(systemName: "chevron.right")
                        }
                    }.buttonStyle(.plain)
                    Divider()
                }
            }
        }
        .padding(.horizontal)
    }
}

#Preview {
    StadiumView(stadiumId: 1)
}
