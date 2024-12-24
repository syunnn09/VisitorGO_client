//
//  PostRowView.swift
//  VisitorGO
//
//  Created by shusuke imamura on 2024/12/10.
//

import SwiftUI

struct PostRowView: View {
    @State var isFavorite: Bool = false
    @State var heart: Int = 1

    var count: Int {
        heart + (isFavorite ? 1 : 0)
    }

    var body: some View {
        NavigationStack {
            VStack(alignment: .leading) {
                HStack {
                    Image(systemName: "baseball")
                        .foregroundStyle(.green)

                    Text("福岡への遠征記録").bold()
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
                        Text("楽天イーグルス")
                        Text("VS")
                        Text("ソフトバンクホークス")
                    }
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
                            Text("nakaya").bold()
                            Text("2023/11/04 ~ 2023/11/07")
                        }
                        
                        Spacer()
                    }.buttonStyle(.plain)

                    HStack(spacing: 2) {
                        Button("", systemImage: "heart") {
                            withAnimation {
                                feedbackGenerator.impactOccurred()
                                isFavorite.toggle()
                            }
                        }
                        .foregroundStyle(.pink)
                        .symbolVariant(isFavorite ? .fill : .none)
                        
                        Text("\(count)")
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

#Preview {
    PostRowView()
}
