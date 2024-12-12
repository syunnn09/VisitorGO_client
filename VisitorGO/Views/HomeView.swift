//
//  HomeView.swift
//  VisitorGO
//
//  Created by shusuke imamura on 2024/11/18.
//

import SwiftUI

struct HomeView: View {
    @State var count: Int = 10

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    ForEach(1...count, id: \.self) { number in
                        let view = PostRowView(heart: number)
                        NavigationLink {
                            view
                        } label: {
                            view
                        }.buttonStyle(.plain)
                        Divider()
                    }
                }
            }
            .refreshable {
                try! await Task.sleep(nanoseconds: 1_000_000_000)
                count += 5
            }
            .navigationTitle("ホーム")
        }
    }
}

#Preview {
    HomeView()
}
