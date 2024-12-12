//
//  EditFavoriteTeamView.swift
//  VisitorGO
//
//  Created by shusuke imamura on 2024/12/03.
//

import SwiftUI

struct LeagueSelector: View {
    @StateObject var teamDataHelper = TeamDataHelper.shared
    let text: String

    var body: some View {
        Text(text)
            .padding(.horizontal, 20)
            .padding(.vertical, 8)
            .background(.white)
            .clipShape(RoundedRectangle(cornerRadius: 30))
            .overlay {
                if teamDataHelper.selectedLeague == text {
                    RoundedRectangle(cornerRadius: 20)
                        .strokeBorder(.green, lineWidth: 1)
                }
            }
            .onTapGesture {
                withAnimation {
                    teamDataHelper.selectedLeague = text
                }
            }
    }
}

struct TeamSelector: View {
    @ObservedObject var team: Team

    var image: String {
        self.team.isFavorite ? "checkmark.circle" : "circle"
    }

    var body: some View {
        HStack {
            Text(team.name)
                .font(.system(size: 16))

            Spacer()

            Button {
                withAnimation {
                    feedbackGenerator.impactOccurred()
                    TeamDataHelper.shared.toggle(team: team)
                }
            } label: {
                Image(systemName: image)
                    .imageScale(.large)
                    .foregroundStyle(.green)
                    .frame(width: 20, height: 20)
            }
            .buttonStyle(.plain)
        }
        .padding()
        .background(.white)
    }
}

struct SportsPicker: View {
    @StateObject var teamDataHelper = TeamDataHelper.shared
    @Binding var selection: SportsData?

    @State var isOpen = false

    var body: some View {
        HStack {
            Image(systemName: selection!.icon)
                .foregroundStyle(.green)

            Text(selection!.sports)
            Spacer()
            Image(systemName: "arrowtriangle.down.fill")
                .resizable()
                .frame(width: 14, height: 10)
        }
        .padding(12)
        .background(isOpen ? .gray.opacity(0.1) : .white)
        .onTapGesture {
            withAnimation {
                isOpen.toggle()
            }
        }
        .popover(isPresented: $isOpen, arrowEdge: .top) {
            VStack(alignment: .leading, spacing: 8) {
                ForEach(teamDataHelper.teamData!.data) { team in
                    HStack {
                        Image(systemName: team.icon)
                            .foregroundStyle(.green)
                        Text(team.sports)
                            .bold(team.sports == selection!.sports)
                    }
                    .onTapGesture {
                        withAnimation {
                            selection = team
                            isOpen = false
                            teamDataHelper.selectedLeague = "全て"
                        }
                    }
                }
            }
            .padding(.vertical, 12)
            .padding(.horizontal, 36)
            .presentationCompactAdaptation(.popover)
        }
    }
}

struct EditFavoriteTeamView: View {
    @ObservedObject var teamDataHelper: TeamDataHelper

    var body: some View {
        ZStack {
            Color.gray.opacity(0.1)
                .ignoresSafeArea()

            ScrollView {
                VStack(spacing: 16) {
                    if (teamDataHelper.teamData != nil && teamDataHelper.selectedSports != nil) {
                        VStack(alignment: .leading) {
                            Text("競技を選択")
                            SportsPicker(selection: $teamDataHelper.selectedSports)
                        }

                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 12) {
                                LeagueSelector(text: "全て")

                                ForEach(teamDataHelper.getLeaguesBySportsName()) { league in
                                    LeagueSelector(text: league.league)
                                }
                            }
                        }

                        VStack(spacing: 2) {
                            ForEach(teamDataHelper.getTeamsByLeague()) { team in
                                TeamSelector(team: team)
                            }
                        }
                    }
                }
                .padding(.horizontal)
                .padding(.bottom, 12)
            }
        }
    }
}

#Preview {
    @Previewable @State var teamDataHelper = TeamDataHelper.shared
    EditFavoriteTeamView(teamDataHelper: teamDataHelper)
}
