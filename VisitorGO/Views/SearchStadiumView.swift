//
//  SearchStadiumView.swift
//  VisitorGO
//
//  Created by shusuke imamura on 2025/01/22.
//

import SwiftUI

struct SearchStadiumView: View {
    @State var keyword: String = ""
    @State var stadiums: [StadiumResponseBody] = []

    var body: some View {
        NavigationStack {
            HStack {
                TextField("キーワード", text: $keyword)
                    .textFieldStyle(.roundedBorder)

                Button("検索") {
                    feedbackGenerator.impactOccurred()
                    APIHelper.shared.searchStadium(keyword: keyword) { data in
                        self.stadiums = data ?? []
                    }
                }
            }
            .padding([.top, .horizontal])

            List {
                ForEach(self.stadiums, id: \.self) { stadium in
                    NavigationLink {
                        StadiumView(stadiumId: stadium.id)
                    } label: {
                        Text(stadium.name)
                    }
                    .listRowBackground(Color.gray.opacity(0.09))
                }
            }
            .scrollContentBackground(.hidden)
            .navigationTitle("スタジアム検索")
        }
    }
}

#Preview {
    SearchStadiumView()
}
