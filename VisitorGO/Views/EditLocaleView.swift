//
//  EditLocateView.swift
//  VisitorGO
//
//  Created by shusuke imamura on 2024/11/18.
//

import MapKit
import SwiftUI

let colors: [[Color]] = [
    [.red, .pink, .orange, .yellow, .green],
    [.teal, .mint, .cyan, .blue, .indigo],
    [.purple, .gray, .brown]
]

struct CircleColor: View {
    @Binding var selectedColor: Color
    let color: Color

    var body: some View {
        Button {
            withAnimation {
                selectedColor = color
            }
        } label: {
            ZStack {
                if selectedColor == color {
                    Circle()
                        .frame(width: 50)
                        .foregroundStyle(.gray)
                    
                    Circle()
                        .frame(width: 45)
                        .foregroundStyle(.white)
                }

                Circle()
                    .frame(width: 40)
                    .foregroundStyle(color)
            }
            .frame(width: 50, height: 50)
        }
        .buttonStyle(.plain)
    }
}

struct EditLocaleView: View {
    @Binding var locate: Locate?
    @Binding var alias: String
    @State var selectedColor: Color = colors.first!.first!
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack {
                    VStack(alignment: .leading) {
                        Text("場所名").bold()

                        TextField("", text: $alias)
                            .textFieldStyle(.roundedBorder)

                        Text("ピンアイコン").bold()
                            .padding(.top, 20)
                    }

                    HStack {
                        Spacer()
                        ZStack {
                            Circle()
                                .frame(width: 50)
                                .foregroundStyle(selectedColor)

                            Image(systemName: "mappin")
                                .imageScale(.large)
                                .foregroundStyle(.white)
                        }
                        Spacer()
                    }
                    .padding()
                    .background(.white)
                    .clipShape(RoundedRectangle(cornerRadius: 10))

                    VStack {
                        Grid {
                            ForEach(colors, id: \.self) { color in
                                GridRow {
                                    ForEach(color, id: \.self) { c in
                                        CircleColor(selectedColor: $selectedColor, color: c)
                                    }
                                }
                            }
                        }
                    }
                    .padding()
                    .background(.white)
                    .clipShape(RoundedRectangle(cornerRadius: 10))
                }
                .padding()
            }
            .background(.gray.opacity(0.2))
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .principal) {
                    Text(locate!.name)
                }
            }
        }
    }
}

#Preview {
    @Previewable @State var alias = "東京ドーム"
    @Previewable @State var locate: Locate? = .sample
    EditLocaleView(locate: $locate, alias: $alias)
}
