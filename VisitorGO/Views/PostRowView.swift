//
//  PostRowView.swift
//  VisitorGO
//
//  Created by shusuke imamura on 2024/12/10.
//

import SwiftUI

struct PostRowView: View {
    var expedition: Expedition
    @State var isFavorite: Bool
    @State var favoriteCount: Int

    init(expedition: Expedition) {
        self.expedition = expedition
        self.isFavorite = expedition.isLiked
        self.favoriteCount = expedition.likesCount
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

                Image("fighters")
                    .resizable()
                    .scaledToFit()

                ScrollView(.horizontal, showsIndicators: false) {
                    HStack {
                        let images = ["eagles", "hawks", "buffaloes", "fighters"]
                        ForEach(images, id: \.self) { image in
                            Image(image)
                                .resizable()
                                .scaledToFit()
                                .clipShape(RoundedRectangle(cornerRadius: 10))
                        }
                    }.frame(height: 70)
                }

                VStack(alignment: .leading, spacing: 2) {
                    NavigationLink {
                        StadiumView()
                    } label: {
                        HStack {
                            Image(systemName: "mappin")
                            Text("京セラドーム大阪")
                        }.foregroundStyle(.gray)
                    }.buttonStyle(.plain)

                    HStack {
                        Text(expedition.team1Name)
                        Text("VS")
                        Text(expedition.team2Name)
                    }
                    .lineLimit(1)
                }

                HStack(alignment: .center) {
                    NavigationLink {
                        ProfileView()
                    } label: {
                        Image("nakaya")
                            .resizable()
                            .frame(width: 50, height: 50)
                            .clipShape(RoundedRectangle(cornerRadius: 50))
                        
                        VStack(alignment: .leading) {
                            Text(expedition.userName).bold()
                            Text("\(expedition.startDate.toDate()) ~ \(expedition.endDate.toDate())")
                        }
                        
                        Spacer()
                    }.buttonStyle(.plain)

                    HStack(spacing: 2) {
                        Button("", systemImage: "heart") {
                            feedbackGenerator.impactOccurred()
                            APIHelper.shared.likeExpedition(expeditionId: expedition.id) { data in
                                if let data = data {
                                    self.isFavorite = data.isLike
                                    self.favoriteCount = data.likesCount
                                }
                            }
                        }
                        .foregroundStyle(.pink)
                        .symbolVariant(expedition.isLiked ? .fill : .none)
                        
                        Text("\(expedition.likesCount)")
                            .frame(minWidth: 30)
                            .contentTransition(.numericText())
                    }.font(.system(size: 22))
                }

                Spacer()
            }
            .padding(.horizontal, 8)
        }
    }
}
