//
//  PostRowView.swift
//  VisitorGO
//
//  Created by shusuke imamura on 2024/12/10.
//

import SwiftUI

struct PostRowView: View {
    @Binding var expedition: Expedition

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
                            Text("\(expedition.startDated?.toString() ?? "") ~ \(expedition.endDated?.toString() ?? "")")
                        }
                        
                        Spacer()
                    }.buttonStyle(.plain)

                    HStack(spacing: 2) {
                        Button("", systemImage: "heart") {
                            withAnimation {
                                feedbackGenerator.impactOccurred()
                            }
                        }
                        .foregroundStyle(.pink)
//                        .symbolVariant(isFavorite ? .fill : .none)
                        
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

//#Preview {
//    @Previewable @State var expedition: expedition
//    PostRowView(expedition: $expedition)
//        .onAppear {
//            APIHelper.shared.getExpeditionList { expeditions in
//                if expeditions != nil {
//                    expedition = expeditions?.first
//                } else {
//                    print("nil")
//                }
//            }
//        }
//}
