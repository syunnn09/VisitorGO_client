//
//  PostRowView.swift
//  VisitorGO
//
//  Created by shusuke imamura on 2024/12/10.
//

import SwiftUI

enum IgnoreType: Equatable {
    case stadium
    case profile
}

struct ExpeditionNavigationView: View {
    var expedition: Expedition
    var ignoreType: IgnoreType?

    var body: some View {
        NavigationLink {
            PostDetailView(id: expedition.id)
        } label: {
            PostRowView(expedition: expedition, ignoreType: ignoreType)
        }.buttonStyle(.plain)
    }
}

struct PostRowView: View {
    var expedition: Expedition
    var ignoreType: IgnoreType?

    @State var isFavorite: Bool
    @State var favoriteCount: Int

    @State var isStadiumEnable: Bool
    @State var isProfileEnable: Bool

    init(expedition: Expedition, ignoreType: IgnoreType?) {
        self.expedition = expedition
        self.isFavorite = expedition.isLiked
        self.favoriteCount = expedition.likesCount

        self.ignoreType = ignoreType
        self.isStadiumEnable = ignoreType == .stadium
        self.isProfileEnable = ignoreType == .profile
    }

    var profile: some View {
        HStack {
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

            Spacer()
        }
    }

    var body: some View {
        NavigationStack {
            VStack(alignment: .leading) {
                HStack {
                    Image(systemName: "baseball")
                        .foregroundStyle(.green)

                    Text(expedition.title).bold()
                }
                .font(.system(size: 24))

                AsyncImage(url: URL(string: expedition.images.first ?? "")) { image in
                    image
                        .resizable()
                        .scaledToFit()
                } placeholder: {
                    ProgressView()
                }

                ScrollView(.horizontal, showsIndicators: false) {
                    HStack {
                        ForEach(expedition.images, id: \.self) { image in
                            AsyncImage(url: URL(string: image)) { image in
                                image
                                    .resizable()
                                    .scaledToFit()
                                    .clipShape(RoundedRectangle(cornerRadius: 10))
                            } placeholder: {
                                ProgressView()
                            }
                        }
                    }.frame(height: 70)
                }

                VStack(alignment: .leading, spacing: 2) {
                    if !isStadiumEnable {
                        NavigationLink {
                            StadiumView(stadiumId: expedition.stadiumId)
                        } label: {
                            HStack {
                                Image(systemName: "mappin")
                                Text(expedition.stadiumName)
                                Image(systemName: "chevron.right")
                            }.foregroundStyle(.gray)
                        }.buttonStyle(.plain)
                    } else {
                        HStack {
                            Image(systemName: "mappin")
                            Text(expedition.stadiumName)
                        }.foregroundStyle(.gray)
                    }

                    HStack {
                        Text(expedition.team1Name)
                        Text("VS")
                        Text(expedition.team2Name)
                    }
                    .lineLimit(1)
                }

                HStack(alignment: .center) {
                    if !isProfileEnable {
                        NavigationLink {
                            ProfileView(userId: expedition.userId)
                        } label: {
                            profile
                        }.buttonStyle(.plain)
                    } else {
                        profile
                    }

                    HStack(spacing: 2) {
                        Button("", systemImage: "heart") {
                            feedbackGenerator.impactOccurred()
                            APIHelper.shared.likeExpedition(expeditionId: expedition.id) { data in
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

                Spacer()
            }
            .padding(.horizontal, 8)

            Divider()
        }
    }
}
