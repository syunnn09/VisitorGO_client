//
//  EditProfileView.swift
//  VisitorGO
//
//  Created by shusuke imamura on 2024/12/03.
//

import SwiftUI
import PhotosUI

struct BigButtonStyle: ButtonStyle {
    var color: Color = .green

    init() { }

    init(color: Color) {
        self.color = color
    }

    func makeBody(configuration: Configuration) -> some View {
        HStack {
            Spacer()
            configuration.label.bold()
            Spacer()
        }
            .padding(10)
            .background(color)
            .foregroundStyle(.white)
            .clipShape(RoundedRectangle(cornerRadius: 5))
    }
}

struct EditProfileView: View {
    @Environment(\.dismiss) var dismiss
    @StateObject var teamDataHelper: TeamDataHelper = .shared

    @State var name: String = ""
    @State var bio: String = ""
    @State var pickerItem: PhotosPickerItem?
    let imageUrl = URL(string: "\(baseURL)/icon")

    var body: some View {
        NavigationStack {
            ScrollView(showsIndicators: false) {
                VStack(spacing: 24) {
                    ZStack(alignment: .center) {
                        Text("プロフィール編集")
                            .font(.system(size: 20))
                            .padding()

                        Rectangle()
                            .foregroundStyle(.gray.opacity(0.2))
                    }
                    .onDisappear {
                        print("disappear")
                    }

                    VStack {
                        AsyncImage(url: imageUrl) { image in
                            image.resizable()
                                .clipShape(Circle())
                        } placeholder: {
                            Circle()
                        }
                        .frame(width: 120, height: 120)

                        PhotosPicker(selection: $pickerItem) {
                            Text("写真を編集")
                                .foregroundStyle(.black)
                                .padding(.vertical, 10)
                                .padding(.horizontal, 20)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 7)
                                        .stroke(.black.opacity(0.4), lineWidth: 1)
                                )
                        }
                        
                        VStack(alignment: .leading) {
                            Text("ニックネーム")
                            TextField("ニックネーム", text: $name)
                                .textFieldStyle(.roundedBorder)
                        }
                        
                        VStack(alignment: .leading) {
                            Text("紹介文")
                            TextEditor(text: $bio)
                                .frame(minHeight: 100)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 7)
                                        .stroke(.gray.opacity(0.4), lineWidth: 0.5)
                                        .overlay(alignment: .topLeading) {
                                            if bio.isEmpty {
                                                Text("紹介文")
                                                    .foregroundStyle(.gray.opacity(0.5))
                                                    .padding(8)
                                            }
                                        }
                                )
                                .padding(.horizontal, 1)
                        }
                        
                        NavigationLink {
                            EditFavoriteTeamView(teamDataHelper: teamDataHelper)
                        } label: {
                            Image(systemName: "pencil")
                            Text("推しチームを編集")
                        }
                        .buttonStyle(BigButtonStyle(color: .mint))

                        if teamDataHelper.teamData != nil {
                            VStack(alignment: .leading, spacing: 20) {
                                ForEach(teamDataHelper.teamData!.data) { sports in
                                    let favoriteTeams = sports.favoriteTeams

                                    VStack {
                                        if !sports.ignore && !favoriteTeams.isEmpty {
                                            HStack {
                                                if !sports.ignore {
                                                    Image(systemName: sports.icon)
                                                        .foregroundStyle(.green)
                                                    
                                                    Text(sports.sports).bold()
                                                    Spacer()
                                                }
                                            }
                                            ForEach(favoriteTeams) { team in
                                                HStack {
                                                    Text(team.name)
                                                        .padding(.leading, 12)
                                                    Spacer()
                                                }
                                            }
                                        }
                                    }
                                }
                            }
                        }

                        Button("更新") {
                            dismiss()
                        }.buttonStyle(BigButtonStyle())
                    }
                    .padding()
                }
            }
        }
    }
}

#Preview {
    EditProfileView()
}
