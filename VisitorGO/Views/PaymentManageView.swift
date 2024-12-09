//
//  PaymentManageView.swift
//  VisitorGO
//
//  Created by shusuke imamura on 2024/11/26.
//

import SwiftUI

struct PaymentManageView: View {
    @Binding var payments: [Payment]
    @State var title: String = ""
    @State var date: Date = .now
    @State var cost: Int = 0

    var groupedPayments: [Date: [Payment]] {
        Dictionary(grouping: payments, by: { $0.date })
    }

    var dates: [Date] {
        groupedPayments.map { $0.key }.sorted(by: <)
    }

    func delete(date: Date, index: IndexSet) {
        withAnimation {
            if let index = index.first {
                let payment = groupedPayments[date]![index]
                print(payment)
                payments.remove(at: payments.firstIndex(where: { $0 == payment })!)
            }
        }
    }

    var body: some View {
        VStack {
            VStack {
                TextField("チケット代", text: $title)
                    .textFieldStyle(.roundedBorder)

                HStack {
                    DatePicker("", selection: $date, displayedComponents: [.date])
                        .environment(\.locale, Locale(identifier: "ja_JP"))
                        .pickerStyle(.inline)
                        .labelsHidden()

                    HStack(alignment: .bottom) {
                        TextField("3000", value: $cost, format: .number)
                            .textFieldStyle(.roundedBorder)
                        Text("円")
                    }

                    Button("追加") {
                        if !title.isEmpty && cost != 0 {
                            withAnimation {
                                let payment = Payment(title: title, date: date, cost: cost)
                                self.payments.append(payment)
                            }
                            title = ""
                            cost = 0
                        }
                    }.buttonStyle(.borderedProminent)
                }
            }
            .padding()

            List {
                ForEach(dates, id: \.self) { key in
                    let payments = groupedPayments[key]

                    Section {
                        ForEach(payments!, id: \.self) { payment in
                            HStack {
                                Text(payment.title)
                                Spacer()
                                Text("\(payment.cost)円")
                            }
                        }
                        .onDelete { index in
                            self.delete(date: key, index: index)
                        }
                    } header: {
                        HStack {
                            Text(key.toString())
                            Spacer()
                            Text("\(Payment.calcSum(payments!))円")
                        }
                    }
                }
            }
        }
    }
}

#Preview {
    @Previewable @State var payments: [Payment] = []
    PaymentManageView(payments: $payments)
}
