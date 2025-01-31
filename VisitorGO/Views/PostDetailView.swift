//
//  PostDetailView.swift
//  VisitorGO
//
//  Created by shusuke imamura on 2025/01/20.
//

import SwiftUI
import MapKit

struct PostDetailView: View {
    var id: Int
    @State var expeditionDetail: ExpeditionDetail?

    @State var isFavorite: Bool = false
    @State var favoriteCount: Int = 0

    var body: some View {
        NavigationStack {
            ZStack(alignment: .bottom) {
                ScrollView {
                    VStack(alignment: .leading) {
                        if let expedition = expeditionDetail {
                            Text(expedition.title)
                                .bold()
                                .font(.system(size: 24))

                            Text(expedition.memo)

                            if let expeditionImages = expedition.expeditionImages {
                                if let imagePath = expeditionImages.first {
                                    AsyncImage(url: URL(string: imagePath.image)) { image in
                                        image.resizable()
                                            .scaledToFit()
                                    } placeholder: {
                                        ProgressView()
                                            .scaledToFit()
                                    }
                                }

                                ScrollView(.horizontal, showsIndicators: false) {
                                    HStack {
                                        ForEach(expeditionImages, id: \.self) { image in
                                            AsyncImage(url: URL(string: image.image)) { image in
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
                            }

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

                            if let visitedFacilities = expedition.visitedFacilities {
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

                if let detail = expeditionDetail {
                    HStack {
                        AsyncImage(url: URL(string: detail.userIcon)) { image in
                            image
                                .resizable()
                                .frame(width: 50, height: 50)
                                .clipShape(RoundedRectangle(cornerRadius: 50))
                        } placeholder: {
                            ProgressView()
                        }
                        
                        VStack(alignment: .leading) {
                            Text(detail.username).bold()
                            Text("\(detail.startDate.toDate()) ~ \(detail.endDate.toDate())")
                        }
                        .lineLimit(1)
                        .minimumScaleFactor(0.1)
                        
                        Spacer()
                        
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
                    .padding()
                    .background(.white)
                }
            }
        }
        .onAppear {
            APIHelper.shared.getExpeditionDetail(expeditionId: id) { data in
                if let data = data {
                    self.expeditionDetail = data
                    self.isFavorite = data.isLiked
                    self.favoriteCount = data.likesCount
                }
            }
        }
    }
}

#Preview {
    PostDetailView(id: 20)
}
