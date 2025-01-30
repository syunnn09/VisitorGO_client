//
//  EditLocateView.swift
//  VisitorGO
//
//  Created by shusuke imamura on 2024/11/18.
//

import MapKit
import SwiftUI

let colors: [String] = ["FF3A30", "FF2D54", "FF9400", "FFCC00", "33C85A", "3380C8", "00C8C0", "33AEE6", "007AFF", "5A57D7", "B051DE", "8F8F94", "A5855E"]

let symbolsDict: Dictionary<String, [String]> = [
    "マップ": ["mappin", "house", "sportscourt", "location", "map", "flag", "figure.walk", "cart", "suitcase", "bathtub", "fork.knife", "cup.and.saucer", "cup.and.heat.waves", "wineglass", "bed.double", "mountain.2", "snowflake", "drop", "flame", "leaf", "camera.macro", "tree", "balloon", "balloon.2", "popcorn", "fish", "building.columns", "building", "building.2", "sparkle", "sparkles", "moon", "moon.stars", "star", "fireworks", "camera", "photo"],
    "交通": ["car", "car.2", "road.lanes", "steeringwheel", "fuelpump", "bus", "tram", "cablecar", "train.side.front.car", "bicycle", "motorcycle.fill", "sailboat", "ferry", "airplane", "airplane.departure", "airplane.arrival"],
    "スポーツ": ["baseball", "baseball.fill", "figure.baseball", "baseball.diamond.bases", "hat.cap", "soccerball", "soccerball.inverse", "figure.indoor.soccer", "basketball", "basketball.fill", "figure.basketball", "volleyball", "volleyball.fill", "figure.volleyball"]
]

let symbolNames: [String] = ["マップ", "交通", "スポーツ"]
let symbols: [[String]] = symbolNames.compactMap { symbolsDict[$0] }

struct CircleColor: View {
    @Binding var selectedColor: Color
    @Binding var effect: Bool
    let color: Color

    var body: some View {
        Button {
            withAnimation {
                selectedColor = color
                effect.toggle()
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

struct BackgroundWhiteView<T: View> : View {
    @ViewBuilder let label: () -> T

    var body: some View {
        HStack {
            Spacer()
            label()
            Spacer()
        }
        .padding()
        .background(.white)
        .clipShape(RoundedRectangle(cornerRadius: 10))
    }
}

struct EditLocaleView: View {
    @Binding var locate: Locate?
    @Binding var alias: String
    @Binding var icon: String
    @Binding var color: String
    @State var effect = false
    @State var offset = 0.0

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

                    ZStack(alignment: .top) {
                        BackgroundWhiteView {
                            ZStack {
                                Circle()
                                    .frame(width: 50)
                                    .foregroundStyle(Color(hex: color))

                                Image(systemName: icon)
                                    .imageScale(.large)
                                    .foregroundStyle(.white)
                                    .symbolEffect(.bounce, value: effect)
                            }
                        }
                        .coordinateSpace(name: "stack")
                        .frame(height: 100)
                        .offset(y: offset)
                        .zIndex(10)
                        .background {
                            GeometryReader { geometry in
                                Color.clear.onChange(of: geometry.frame(in: .named("stack")).minY) { _, new in
                                    offset = max(0, -new + 100)
                                }
                            }
                        }

                        VStack {
                            BackgroundWhiteView {
                                LazyVGrid(columns: [GridItem(.adaptive(minimum: 40))], spacing: 15) {
                                    ForEach(colors, id: \.self) { color in
                                        CircleColor(selectedColor: .constant(Color(hex: color)), effect: $effect, color: Color(hex: color))
                                    }
                                }
                            }

                            BackgroundWhiteView {
                                VStack(spacing: 30) {
                                    ForEach(symbolNames.indices, id: \.self) { index in
                                        VStack(alignment: .leading, spacing: 4) {
                                            Section(header: Text(symbolNames[index]).bold()) {
                                                LazyVGrid(columns: [GridItem(.adaptive(minimum: 40))]) {
                                                    ForEach(symbols[index], id: \.self) { symbol in
                                                        Button {
                                                            withAnimation {
                                                                icon = symbol
                                                                effect.toggle()
                                                            }
                                                        } label: {
                                                            ZStack {
                                                                if icon == symbol {
                                                                    Rectangle()
                                                                        .frame(width: 35, height: 35)
                                                                        .clipShape(RoundedRectangle(cornerRadius: 5))
                                                                        .padding(5)
                                                                        .foregroundStyle(.gray.opacity(0.3))
                                                                }
                                                                
                                                                Image(systemName: symbol)
                                                                    .imageScale(.large)
                                                                    .frame(width: 45, height: 45)
                                                            }
                                                        }.buttonStyle(.plain)
                                                    }
                                                }
                                            }
                                        }
                                    }
                                }
                            }
                        }.padding(.top, 100)
                    }
                }
                .padding()
            }
            .background(.gray.opacity(0.2))
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .principal) {
                    Text(locate!.name)
                        .lineLimit(1)
                }
            }
        }
    }
}

#Preview {
    @Previewable @State var alias = "東京ドーム"
    @Previewable @State var locate: Locate? = .sample
    @Previewable @State var icon = "mappin"
    @Previewable @State var color: String = "FF3A30"
    EditLocaleView(locate: $locate, alias: $alias, icon: $icon, color: $color)
}
