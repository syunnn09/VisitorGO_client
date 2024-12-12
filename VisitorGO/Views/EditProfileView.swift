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
    @State var uiImage: UIImage?
    @State var profileImage: UIImage?
    @State var editImage = false
    let imageUrl = URL(string: "\(baseURL)/icon")

    var body: some View {
        NavigationStack {
            ScrollView(showsIndicators: false) {
                VStack(spacing: 24) {
                    HeaderView(text: "プロフィール編集")

                    VStack {
                        if profileImage != nil {
                            Image(uiImage: uiImage!)
                                .resizable()
                                .frame(width: 120, height: 120)
                                .clipShape(Circle())
                        } else {
                            AsyncImage(url: imageUrl) { image in
                                image.resizable()
                                    .clipShape(Circle())
                            } placeholder: {
                                Circle()
                            }
                            .frame(width: 120, height: 120)
                        }

                        PhotosPicker(selection: $pickerItem) {
                            Text("写真を編集")
                                .foregroundStyle(.black)
                                .padding(.vertical, 10)
                                .padding(.horizontal, 20)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 7)
                                        .stroke(.black.opacity(0.4), lineWidth: 1)
                                )
                        }.onChange(of: pickerItem) {
                            Task {
                                if let image = pickerItem {
                                    guard let data = try? await image.loadTransferable(type: Data.self) else { return }
                                    uiImage = UIImage(data: data)
                                }
                            }
                        }.onChange(of: uiImage) {
                            if uiImage != nil {
//                                editImage = true
                                profileImage = uiImage
                            }
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
                                    VStack(alignment: .leading) {
                                        if !sports.ignore && !sports.favoriteTeams.isEmpty {
                                            HStack {
                                                Image(systemName: sports.icon)
                                                    .foregroundStyle(.green)

                                                Text(sports.sports).bold()
                                                Spacer()
                                            }
                                            ForEach(sports.favoriteTeams) { team in
                                                Text(team.name)
                                                    .padding(.leading, 12)
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
                    .padding([.horizontal, .bottom])
                }
            }
            .onAppear {
                reloadTeamData()
            }
        }
        .sheet(isPresented: $editImage) {
            ZStack {
                Image(uiImage: uiImage!)
                    .resizable()
                    .scaledToFit()

                Circle()
                    .frame(width: 100, height: 100)
            }
            .onDisappear {
                pickerItem = nil
            }
        }
    }

    private func reloadTeamData() {
        DispatchQueue.main.async {
            teamDataHelper.objectWillChange.send()
        }
    }
}

#Preview {
    EditProfileView()
}
