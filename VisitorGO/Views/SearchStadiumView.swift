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
    @State var isLoading: Bool = false

    var body: some View {
        NavigationStack {
            HStack {
                TextField("キーワード", text: $keyword)
                    .textFieldStyle(.roundedBorder)

                Button("検索") {
                    self.isLoading = true
                    self.stadiums = []
                    feedbackGenerator.impactOccurred()
                    APIHelper.shared.searchStadium(keyword: keyword) { data in
                        self.stadiums = data ?? []
                        self.isLoading = false
                    }
                }
            }
            .padding([.top, .horizontal])
            .navigationTitle("スタジアム検索")

            if isLoading {
                ProgressView()
                Spacer()
            } else {
                List(self.stadiums, id: \.self) { stadium in
                    NavigationLink {
                        StadiumView(stadiumId: stadium.id)
                    } label: {
                        Text(stadium.name)
                    }
                    .listRowBackground(Color.gray.opacity(0.09))
                }
                .scrollContentBackground(.hidden)
            }
        }
    }
}

#Preview {
    SearchStadiumView()
}
