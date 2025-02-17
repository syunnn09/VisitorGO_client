//
//  RegistProfileView.swift
//  VisitorGO
//
//  Created by shusuke imamura on 2024/12/12.
//

import SwiftUI
import PhotosUI

struct RegistProfileView: View {
    @Environment(\.dismiss) var dismiss
    var helper: APIHelper = .shared
    var teamDataHelper: TeamDataHelper = .shared

    @State var username: String = ""
    @State var name: String = ""
    @State var bio: String = ""
    @State var pickerItem: PhotosPickerItem?
    @State var uiImage: UIImage?
    @State var password: String = ""
    @State var password2: String = ""
    @State var isLoading: Bool = false
    @State var completed: Bool = false

    @State var message: String = ""
    @State var color: Color = .red
    @State var isUniqueLoading: Bool = false
    @State var error: String = ""

    func onRegist(status: Bool) {
        if status {
            completed = true
            dismiss()
        } else {
            isLoading = false
        }
    }

    var body: some View {
        NavigationStack {
            ScrollView(showsIndicators: false) {
                VStack(spacing: 24) {
                    HeaderView(text: "プロフィール設定")

                    VStack(spacing: 12) {
                        if uiImage != nil {
                            Image(uiImage: uiImage!)
                                .resizable()
                                .frame(width: 120, height: 120)
                                .clipShape(Circle())
                        } else {
                            Circle()
                                .frame(width: 120, height: 120)
                                .foregroundStyle(.gray.opacity(0.5))
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
                        }

                        VStack(alignment: .leading) {
                            Text("ユーザーID")

                            HStack {
                                TextField("ユーザーID", text: $username)
                                    .textFieldStyle(.roundedBorder)

                                LoadingButton(isLoading: $isUniqueLoading, text: "チェック", color: .blue) {
                                    isUniqueLoading = true
                                    APIHelper.shared.isUnique(username: username) { result, message in
                                        self.color = result ? .green : .red
                                        self.message = message
                                        isUniqueLoading = false
                                    }
                                }
                                .frame(width: 100)
                            }

                            Text(message)
                                .font(.system(size: 14))
                                .foregroundStyle(color)
                        }

                        VStack(alignment: .leading) {
                            Text("パスワード")
                            SecureField("", text: $password)
                                .textFieldStyle(.roundedBorder)
                        }

                        VStack(alignment: .leading) {
                            Text("確認用パスワード")
                            SecureField("", text: $password2)
                                .textFieldStyle(.roundedBorder)
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
                            Text("推しチームを登録")
                        }
                        .buttonStyle(BigButtonStyle(color: .mint))
                        .padding(.vertical)

                        LoadingButton(isLoading: $isLoading, text: "登録") {
                            if password == password2 && !isLoading {
                                isLoading = true
                                APIHelper.shared.regist(username: username, password: password, name: name, bio: bio, profileImage: uiImage, favoriteTeamIds: teamDataHelper.favoriteTeamIds) { status, messages in
                                    onRegist(status: status)
                                    if !status {
                                        self.error = messages.joined(separator: "\n")
                                    }
                                }
                            }
                        }

                        Text(error)
                            .font(.system(size: 14))
                            .foregroundStyle(.red)
                            .padding(.bottom)

                        if !isLoading {
                            Button("戻る") {
                                dismiss()
                            }.buttonStyle(BigButtonStyle(color: .gray))
                        }
                    }
                    .padding([.horizontal, .bottom])
                }
            }
            .navigationBarBackButtonHidden()
        }
    }
}

#Preview {
    RegistProfileView()
}
