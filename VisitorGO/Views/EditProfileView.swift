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
    @ObservedObject var userData: UserData
    @ObservedObject var apiHelper: APIHelper = .shared

    @State var name: String = ""
    @State var bio: String = ""
    @State var pickerItem: PhotosPickerItem?
    @State var uiImage: UIImage?
    @State var profileImage: UIImage?
    @State var editImage = false
    @State var imageUrl: URL?
    @State var changeProfileImage = false
    @State var isUpdating = false

    init() {
        userData = .shared
    }

    var body: some View {
        NavigationStack {
            ScrollView(showsIndicators: false) {
                VStack(spacing: 24) {
                    HeaderView(text: "プロフィール編集")

                    VStack(spacing: 24) {
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
                                ZStack {
                                    ProgressView()
                                    Circle()
                                        .fill(Color.black.opacity(0.1))
                                }
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
                                    changeProfileImage = true
                                }
                            }
                        }.onChange(of: uiImage) {
                            if uiImage != nil {
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
                                    if !sports.ignore && !sports.favoriteTeams.isEmpty {
                                        VStack(alignment: .leading) {
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

                        LoadingButton(isLoading: $isUpdating, text: "更新") {
                            isUpdating = true
                            feedbackGenerator.impactOccurred()

                            apiHelper.updateProfile(bio: bio, name: name, updateImage: changeProfileImage, image: uiImage) { result in
                                if result {
                                    SnackBarManager.shared.show("プロフィールが更新されました", .success)
                                    dismiss()
                                } else {
                                    isUpdating = false
                                    SnackBarManager.shared.show("プロフィールの更新に失敗しました", .error)
                                }
                            }
                        }
                    }
                    .padding([.horizontal, .bottom])
                }
            }
            .onAppear {
                reloadTeamData()
                userData.getProfile { profile in
                    if let profile = profile {
                        name = profile.name
                        bio = profile.description
                        imageUrl = URL(string: profile.profileImage)
                    }
                }
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
