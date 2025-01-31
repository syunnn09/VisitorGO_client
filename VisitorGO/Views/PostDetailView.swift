//
//  PostDetailView.swift
//  VisitorGO
//
//  Created by shusuke imamura on 2025/01/20.
//

import SwiftUI
import MapKit

struct PostDetailView: View {
    var expedition: Expedition
    @State var expeditionDetail: ExpeditionDetail?

    @State var isFavorite: Bool = false
    @State var favoriteCount: Int = 0

    var body: some View {
        NavigationStack {
            ZStack(alignment: .bottom) {
                ScrollView {
                    VStack(alignment: .leading) {
                        Text(expedition.title)
                            .bold()
                            .font(.system(size: 24))

                        Text(expeditionDetail?.memo ?? "")

                        if let imagePath = expedition.images.first {
                            AsyncImage(url: URL(string: imagePath)) { image in
                                image.resizable()
                                    .scaledToFit()
                            } placeholder: {
                                ProgressView()
                                    .scaledToFit()
                            }
                        }

                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack {
                                ForEach(expedition.images, id: \.self) { image in
                                    AsyncImage(url: URL(string: image)) { image in
                                        image.resizable()
                                            .scaledToFit()
                                            .clipShape(RoundedRectangle(cornerRadius: 10))
                                    } placeholder: {
                                        ProgressView()
                                    }
                                }
                            }
                        }
                        .frame(height: 70)

                        if let expeditionDetail = expeditionDetail {
                            NavigationLink {
                                StadiumView(stadiumId: expedition.stadiumId)
                            } label: {
                                HStack {
                                    Image(systemName: "mappin")
                                    Text(expedition.stadiumName)
                                    Image(systemName: "chevron.right")
                                }.foregroundStyle(.gray)
                            }
                            .padding(.top, 20)

                            if let visitedFacilities = expeditionDetail.visitedFacilities {
                                NavigationLink {
                                    Map {
                                        ForEach(visitedFacilities, id: \.self) { facility in
                                            Marker(facility.customName, systemImage: facility.icon, coordinate: facility.coordinate)
                                                .tint(Color(hex: facility.color))
                                        }
                                    }
                                } label: {
                                    Map {
                                        ForEach(visitedFacilities, id: \.self) { facility in
                                            Marker(facility.customName, systemImage: facility.icon, coordinate: facility.coordinate)
                                                .tint(Color(hex: facility.color))
                                        }
                                    }
                                    .scaledToFit()
                                }
                            }
                        } else {
                            ProgressView()
                        }
                    }
                    .padding()
                }
                .padding(.bottom, 70)

                HStack {
                    NavigationLink {
                        ProfileView(userId: expedition.userId)
                    } label: {
                        AsyncImage(url: URL(string: expedition.userIcon)) { image in
                            image
                                .resizable()
                                .frame(width: 50, height: 50)
                                .clipShape(RoundedRectangle(cornerRadius: 50))
                        } placeholder: {
                            ProgressView()
                        }

                        VStack(alignment: .leading) {
                            Text(expedition.userName).bold()
                            Text("\(expedition.startDate.toDate()) ~ \(expedition.endDate.toDate())")
                        }
                        .lineLimit(1)
                        .minimumScaleFactor(0.1)
                    }.buttonStyle(.plain)

                    Spacer()

                    if let detail = expeditionDetail {
                        HStack(spacing: 0) {
                            Button("", systemImage: "heart") {
                                feedbackGenerator.impactOccurred()
                                APIHelper.shared.likeExpedition(expeditionId: detail.id) { data in
                                    if let data = data {
                                        self.isFavorite = data.isLiked
                                        self.favoriteCount = data.likesCount
                                    }
                                }
                            }
                            .foregroundStyle(.pink)
                            .symbolVariant(isFavorite ? .fill : .none)

                            Text("\(favoriteCount)")
                                .frame(minWidth: 30)
                                .contentTransition(.numericText())
                        }.font(.system(size: 22))
                    }
                }
                .padding()
                .background(.white)
            }
        }
        .onAppear {
            APIHelper.shared.getExpeditionDetail(expeditionId: expedition.id) { data in
                if let data = data {
                    self.expeditionDetail = data
                    self.isFavorite = data.isLiked
                    self.favoriteCount = data.likesCount
                }
            }
        }
    }
}
