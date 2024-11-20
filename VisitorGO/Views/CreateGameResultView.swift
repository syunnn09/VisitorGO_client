//
//  CreateGameResultView.swift
//  VisitorGO
//
//  Created by shusuke imamura on 2024/11/18.
//

import SwiftUI

struct CreateGameResultView: View {
    @Binding var stadiums: [String]
    @State var stadium: String = ""
    @State var date: Date = .now
    
    var body: some View {
        HStack {
            CustomDatePicker(selection: $date)
            
            Spacer()
            
            Picker("球場", selection: $stadium) {
                if stadiums.isEmpty {
                    Text("会場を選択してください").tag("")
                }
                ForEach(stadiums, id: \.self) { stadium in
                    Text(stadium)
                        .lineLimit(1)
                        .minimumScaleFactor(0.1)
                }
            }.pickerStyle(.menu)
        }
    }
}

#Preview {
    CreateGameResultView(stadiums: .constant(["京セラドーム大阪", "みずほPayPayドーム福岡"]))
}

