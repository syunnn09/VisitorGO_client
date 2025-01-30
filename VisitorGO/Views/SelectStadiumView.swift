//
//  SelectStadiumView.swift
//  VisitorGO
//
//  Created by shusuke imamura on 2025/01/29.
//

import SwiftUI

struct SelectStadiumView: View {
    @Environment(\.dismiss) var dismiss
    @Binding var stadium: StadiumResponseBody?

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
            
            List(self.stadiums, id: \.self) { stadium in
                Text(stadium.name)
                    .listRowBackground(Color.gray.opacity(0.09))
                    .onTapGesture {
                        self.stadium = stadium
                        dismiss()
                    }
            }
            .scrollContentBackground(.hidden)
            .navigationTitle("スタジアム検索")
        }
    }
}

#Preview {
    SelectStadiumView(stadium: .constant(nil))
}
