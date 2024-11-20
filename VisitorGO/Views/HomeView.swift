//
//  HomeView.swift
//  VisitorGO
//
//  Created by shusuke imamura on 2024/11/18.
//

import SwiftUI

struct HomeView: View {
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading) {
                    ForEach(1...10, id: \.self) { number in
                        Text("Hello \(number)")
                    }
                }
            }
            .navigationTitle("ビジターGO")
        }
    }
}

#Preview {
    HomeView()
}
