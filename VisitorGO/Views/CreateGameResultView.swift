//
//  CreateGameResultView.swift
//  VisitorGO
//
//  Created by shusuke imamura on 2024/11/18.
//

import SwiftUI

struct CreateGameResultView: View {
    @State var firstTeam: String = ""
    @State var secondTeam: String = ""
    @State var item: Int = 0
    @State var isPresented: Bool = false

    @ObservedObject var postHelper: PostHelper
    @Binding var offset: CGFloat
    @State var index: Int
    @Binding var selectedIndex: Int

    @Binding var from: Date
    @Binding var to: Date

    var body: some View {
        VStack {
            HStack {
                CustomDatePicker(selection: $postHelper.date[index], closedRange: from...to)

                Spacer()

                if postHelper.games > 1 {
                    Button("", systemImage: "trash") {
                        withAnimation {
                            feedbackGenerator.impactOccurred()
                            selectedIndex = 0
                            postHelper.delete(index)
                        }
                    }
                }
            }
            .padding(.horizontal)

            HStack {
                Text("先攻")
                TextField("", text: $firstTeam)
                    .textFieldStyle(.roundedBorder)

                Button {
                    withAnimation(.linear) {
                        selectedIndex = index
                        offset = 0
                    }
                } label: {
                    Text("\(postHelper.firstPoint[index])点")
                }.buttonStyle(.plain)
            }
            .padding(.horizontal)

            HStack {
                Text("後攻")
                TextField("", text: $secondTeam)
                    .textFieldStyle(.roundedBorder)

                Button {
                    withAnimation(.linear) {
                        selectedIndex = index
                        offset = 0
                    }
                } label: {
                    Text("\(postHelper.secondPoint[index])点")
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
            }
            .padding()
            .background(.white)

            HStack {
                Spacer()
                Text("先攻")
                Spacer()
                Spacer()
                Text("後攻")
                Spacer()
            }
            .padding(.top, 8)
            .background(.white)

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
            .background(.white)
        }
    }
}

#Preview {
    @Previewable @State var postHelper: PostHelper = PostHelper()
    @Previewable @State var offset: CGFloat = 350
    @Previewable @State var date: Date = Date()

    ZStack {
        CreateGameResultView(postHelper: postHelper, offset: $offset, index: 0, selectedIndex: .constant(0), from: .constant(date), to: .constant(date))

        NumberPicker(item: $postHelper.firstPoint[0], item2: $postHelper.secondPoint[0], offset: $offset)
            .offset(y: offset)
    }
}

