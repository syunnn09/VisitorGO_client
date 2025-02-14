//
//  SportsSelectView.swift
//  VisitorGO
//
//  Created by shusuke imamura on 2024/11/18.
//

import SwiftUI

struct SportsImage: View {
    @Binding var selection: Sports?
    @Binding var selectSports: Bool

    let sports: Sports
    let name: String
    var comingSoon = false

    var text: String {
        return comingSoon ? "Coming Soon..." : sports.rawValue
    }

    var body: some View {
        Button {
            if !comingSoon {
                selection = sports
                selectSports = false
            }
        } label: {
            ZStack(alignment: .center) {
                Image(name)
                    .resizable()
                    .scaledToFit()
                    .clipShape(RoundedRectangle(cornerRadius: 10))

                Text(text)
                    .foregroundStyle(.white)
            }
        }
    }
}

struct SportsSelectView: View {
    @Binding var selection: Sports?
    @Binding var selectSports: Bool

    var body: some View {
        NavigationStack {
            VStack {
                Text("遠征を記録")
                    .font(.system(size: 30))
                    .bold()

                HStack {
                    SportsImage(selection: $selection, selectSports: $selectSports, sports: .baseball, name: "baseball")
                    SportsImage(selection: $selection, selectSports: $selectSports, sports: .soccer, name: "soccer")
                }

                HStack {
                    SportsImage(selection: $selection, selectSports: $selectSports, sports: .basketball, name: "basketball", comingSoon: true)
                    SportsImage(selection: $selection, selectSports: $selectSports, sports: .volleyball, name: "volleyball", comingSoon: true)
                }
            }
            .padding()
        }
    }
}

#Preview {
    SportsSelectView(selection: .constant(.baseball), selectSports: .constant(false))
}
