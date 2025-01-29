//
//  HomeView.swift
//  VisitorGO
//
//  Created by shusuke imamura on 2024/11/18.
//

import SwiftUI

struct HomeView: View {
    @State var expeditions: [Expedition] = []

    var body: some View {
        NavigationStack {
            ScrollView {
                LazyVStack(alignment: .leading, spacing: 20) {
                    ForEach(expeditions, id: \.self) { expedition in
                        ExpeditionNavigationView(expedition: expedition)
                    }
                }
            }
            .refreshable {
                APIHelper.shared.getExpeditionList { data in
                    if let data = data {
                        self.expeditions = data
                    }
                }
                try! await Task.sleep(nanoseconds: 1_000_000_000)
            }
            .navigationBarBackButtonHidden()
            .navigationTitle("ホーム")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    NavigationLink(destination: SearchStadiumView()) {
                        Image(systemName: "magnifyingglass")
                    }
                }
            }
        }
        .onAppear {
            APIHelper.shared.getExpeditionList { data in
                if let data = data {
                    self.expeditions = data
                }
            }
        }
    }
}

#Preview {
    HomeView()
}
