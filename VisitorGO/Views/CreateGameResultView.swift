//
//  CreateGameResultView.swift
//  VisitorGO
//
//  Created by shusuke imamura on 2024/11/18.
//

import SwiftUI

struct CreateGameResultView: View {
    @State var date: Date = .now
    @State var firstTeam: String = ""
    @State var firstPoint: Int = 0
    @State var secondTeam: String = ""
    @State var secondPoint: Int = 0
    @State var item: Int = 0
    @State var isPresented: Bool = false
    @Binding var offset: CGFloat

    var body: some View {
        VStack {
            HStack {
                CustomDatePicker(selection: $date)

                Spacer()
            }
            
            HStack {
                Text("先攻")
                TextField("", text: $firstTeam)
                    .textFieldStyle(.roundedBorder)

                Button {
                    withAnimation(.linear) {
                        offset = 0
                    }
                } label: {
                    Text("\(firstPoint)点")
                }.buttonStyle(.plain)
            }
            .padding(.horizontal)
            
            HStack {
                Text("後攻")
                TextField("", text: $secondTeam)
                    .textFieldStyle(.roundedBorder)

                Button {
                    withAnimation(.linear) {
                        offset = 0
                    }
                } label: {
                    Text("\(secondPoint)点")
                }.buttonStyle(.plain)
            }
            .padding(.horizontal)
        }
    }
}

struct NumberPicker: View {
    @Binding var item: Int
    @Binding var item2: Int
    @Binding var offset: CGFloat

    var body: some View {
        VStack(spacing: 0) {
            Spacer()
            
            HStack {
                Spacer()
                Button("確定") {
                    withAnimation(.linear) {
                        offset = 350
                    }
                }
            }.padding()

            HStack {
                Spacer()
                Text("先攻")
                Spacer()
                Spacer()
                Text("後攻")
                Spacer()
            }
            .padding(.top, 8)
            .background(.gray.opacity(0.2))

            HStack {
                Picker("", selection: $item) {
                    ForEach(0...100, id: \.self) { num in
                        Text("\(num)")
                    }
                }.pickerStyle(.wheel)

                Picker("", selection: $item2) {
                    ForEach(0...100, id: \.self) { num in
                        Text("\(num)")
                    }
                }.pickerStyle(.wheel)
            }
            .frame(height: 200)
            .background(.gray.opacity(0.1))
        }
    }
}

#Preview {
    CreateGameResultView(offset: .constant(0))
}

