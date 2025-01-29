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

    func getURL(_ url: String) -> URL {
        return URL(string: "\(baseURL)/\(url)")!
    }

    func getStatusCode(response: URLResponse?) -> Int {
        guard let response = response as? HTTPURLResponse else { return 0 }
        return response.statusCode
    }

    func printStatusCode(response: URLResponse?) {
        print(getStatusCode(response: response))
    }

    func onError(_ reason: String, _ completion: @escaping (Bool) -> Void) {
        print(reason)
        SnackBarManager.shared.show("エラーが発生しました。\n\(reason)", .error)
        completion(false)
    }

    func onError(_ reason: String, _ completion: @escaping (Bool, String) -> Void, _ showSnackBar: Bool = true) {
        print(reason)
        if showSnackBar {
            SnackBarManager.shared.error("エラーが発生しました。\n\(reason)")
        }
        completion(false, reason)
    }

    func onError(_ reason: String, _ completion: @escaping @MainActor (Bool, Profile?) -> Void, _ showSnackBar: Bool = true) {
        if showSnackBar {
            print(reason)
            SnackBarManager.shared.error("エラーが発生しました。\n\(reason)")
        }
        Task {
            await completion(false, nil)
        }
    }

    func onError(_ reason: String, _ completion: @escaping ([Expedition]?) -> Void) {
        print(reason)
        SnackBarManager.shared.error("エラーが発生しました。\n\(reason)")
        completion(nil)
    }

    func onError(_ reason: String, _ completion: @escaping (ExpeditionDetail?) -> Void) {
        print(reason)
        SnackBarManager.shared.error("投稿取得に失敗しました。\n\(reason)")
        completion(nil)
    }

    func onError(_ reason: String, _ completion: @escaping (LikeResponse?) -> Void) {
        print(reason)
        SnackBarManager.shared.error("いいねに失敗しました。")
        completion(nil)
    }

    func onError(_ reason: String, _ completion: @escaping (StadiumResponseBody?) -> Void) {
        print(reason)
        SnackBarManager.shared.error("スタジアム情報取得に失敗しました。")
        completion(nil)
    }

    func onError(_ reason: String, _ completion: @escaping @MainActor ([StadiumResponseBody]?) -> Void) {
        print(reason)
        SnackBarManager.shared.error("スタジアム情報取得に失敗しました。")
        Task {
            await completion([])
        }
    }

    func onError(_ reason: String, _ completion: @escaping @MainActor (Bool, UserDataResponse?) -> Void) {
        print(reason)
        SnackBarManager.shared.error("エラーが発生しました。\n\(reason)")
        Task {
            await completion(false, nil)
        }
    }
}

#Preview {
    @Previewable @State var selectedPhoto: [PhotosPickerItem] = []
    @Previewable @State var profileString: String = ""

    VStack {
        Text(profileString)

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
