//
//  PostDetailView.swift
//  VisitorGO
//
//  Created by shusuke imamura on 2025/01/20.
//

import SwiftUI

struct PostDetailView: View {
    var id: Int
    @State var expeditionDetail: ExpeditionDetail?

    var body: some View {
        ScrollView {
            if expeditionDetail != nil {
                let expedition = expeditionDetail!

                VStack(alignment: .leading) {
                    Text(expedition.title).bold()
                }

                ForEach(expedition.payments, id: \.self) { payment in
                    VStack {
                        Text(payment.title)

                        if let date = ISO8601DateFormatter().date(from: payment.date) {
                            Text(date.toString())
                        }

                        Text("\(payment.cost)")
                    }
                }
            } else {
                ProgressView()
            }
        }
        .onAppear {
            APIHelper.shared.getExpeditionDetail(expeditionId: id) { data in
                self.expeditionDetail = data
            }
        }
    }
}

#Preview {
    PostDetailView(id: 6)
}
