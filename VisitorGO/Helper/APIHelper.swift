//
//  APIHelper.swift
//  VisitorGO
//
//  Created by shusuke imamura on 2024/12/12.
//

import SwiftUI
import PhotosUI

class APIHelper: ObservableObject {
    static let shared = APIHelper()
    let baseURL = "https://go-app-g06d.onrender.com"
    var loginToken: String? = nil
    var verifyToken: String? = nil
    @Published var isLoggedIn = false

    init() {
        loadToken()
        if self.loginToken != nil && self.loginToken != "" {
            isLoggedIn = true
        }
        print(loginToken ?? "token not found")
    }

    func loadToken() {
        self.loginToken = UserDefaults.standard.string(forKey: "token")
    }

    func setToken(token: String) {
        UserDefaults.standard.set(token, forKey: "token")
        self.loginToken = token
    }

    func logout() {
        UserDefaults.standard.set(nil, forKey: "token")
        self.isLoggedIn = false
    }

    func onError(_ reason: String, _ completion: @escaping (Bool) -> Void) {
        print(reason)
        SnackBarManager.shared.show("エラーが発生しました。\n\(reason)", .error)
        completion(false)
    }

    func onError(_ reason: String, _ completion: @escaping @MainActor (Bool, Profile?) -> Void) {
        print(reason)
        Task {
            await completion(false, nil)
        }
    }

    func getURL(_ url: String) -> URL {
        return URL(string: "\(baseURL)/\(url)")!
    }
}

#Preview {
    @Previewable @State var selectedPhoto: [PhotosPickerItem] = []
    @Previewable @State var profileString: String = ""

    VStack {
        Text(profileString)
        Button("Profile API") {
            APIHelper.shared.getUserData { status, profile in
                feedbackGenerator.impactOccurred()
                if profile != nil {
                    profileString = profile!.description
                }
            }
        }.buttonStyle(.borderedProminent)

        PhotosPicker(selection: $selectedPhoto, matching: .images) {
            Text("Picker open")
        }
        .onChange(of: selectedPhoto) {
            if selectedPhoto.isEmpty { return }
            Task {
                var images: [UIImage] = []
                for image in selectedPhoto {
                    guard let data = try? await image.loadTransferable(type: Data.self) else { return }
                    guard let uiImage = UIImage(data: data) else { return }
                    images.append(uiImage)
                }
                APIHelper.shared.uploadImage(images, folder: "folder") { _, _ in }
            }
        }
    }
}
