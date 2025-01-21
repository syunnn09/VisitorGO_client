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

    func getUserData(completion: @escaping @MainActor (Bool, Profile?) -> Void) {
        struct Response: Codable {
            var success: Bool
            var message: String
            var data: Profile?
        }

        guard let token = loginToken else { print("token not found"); return }

        let url = getURL("api/user/logined")
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("\(token)", forHTTPHeaderField: "Authorization")

        URLSession.shared.dataTask(with: request) { data, response, error in
            if error != nil { self.onError(String(describing: error!), completion); return }

            guard let decodeData = try? JSONDecoder().decode(Response.self, from: data!) else { print("\(#function) decode error"); return }

            if !decodeData.success {
                SnackBarManager.shared.error("ユーザーデータの取得に失敗しました。")
            }

            Task {
                await completion(decodeData.success, decodeData.data)
            }
        }.resume()
    }

    @MainActor func updateProfile(bio: String, name: String, updateImage: Bool, image: UIImage?, completion: @escaping @MainActor (Bool) -> Void) {
        struct Request: Encodable {
            var description: String
            var name: String
            var profileImage: String
            var username: String
        }

        struct Response: Codable {
            var success: Bool
            var message: String
            var data: Profile?
        }

        print()
        print(#function)

        guard let token = loginToken else { print("token not found"); return }
        guard let profile = UserData.shared.userProfile else { print("user not found"); completion(false); return }

        @MainActor func onUpload(success: Bool, images: [String]?) {
            guard let images = images else { print("Error"); return }
            guard images.first != nil else { print("image error"); completion(false); return }
            let image = images.first!

            let url = getURL("api/user/update/\(profile.id)")
            var request = URLRequest(url: url)
            request.httpMethod = "PUT"
            request.addValue("application/json", forHTTPHeaderField: "Content-Type")
            request.setValue("\(token)", forHTTPHeaderField: "Authorization")

            let body = Request(description: bio, name: name, profileImage: image, username: profile.username)
            request.httpBody = try? JSONEncoder().encode(body)

            URLSession.shared.dataTask(with: request) { data, response, error in
                if error != nil { print(error!); return }

                guard let response = response as? HTTPURLResponse else { return }
                print(response.statusCode)
                guard let decodeData = try? JSONDecoder().decode(Response.self, from: data!) else { print("\(#function) decode error"); return }
                print(decodeData.message)
                DispatchQueue.main.async {
                    UserData.shared.userProfile = decodeData.data
                }

                Task {
                    await completion(decodeData.success)
                }
            }.resume()
        }

        if let image = image {
            self.uploadImage([image], completion: onUpload)
        } else {
            onUpload(success: true, images: [profile.profileImage])
        }
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
