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
    let baseURL = "https://go-app-bm43.onrender.com"
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

    func login(email: String, password: String, completion: @escaping (Bool) -> Void) {
        struct Request: Encodable {
            var email: String
            var password: String
        }
        struct Data: Decodable {
            var token: String
        }
        struct Response: Decodable {
            var data: Data?
            var message: String
            var success: Bool
        }

        let requestData = Request(email: email, password: password)

        let url = getURL("api/auth/login")
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")

        request.httpBody = try? JSONEncoder().encode(requestData)
        URLSession.shared.dataTask(with: request) { data, response, error in
            if error != nil {
                self.onError(String(describing: error), completion);
                SnackBarManager.shared.error()
                return
            }

            guard let decodeData = try? JSONDecoder().decode(Response.self, from: data!) else { self.onError("decode error", completion); return }
            if decodeData.success {
                self.setToken(token: decodeData.data!.token)
                UserData.shared.getProfile()
            }
            DispatchQueue.main.async {
                self.isLoggedIn = decodeData.success
                completion(decodeData.success)
            }
        }.resume()
    }

    func getProtectedHelloWorld() {
        struct Response: Decodable {
            var success: Bool?
            var message: String
        }

        let url = getURL("api/sample/protectedHelloWorld")
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        request.setValue("\(loginToken!)", forHTTPHeaderField: "Authorization")
        URLSession.shared.dataTask(with: request) { data, response, error in
            if error != nil {
                return
            }

            guard let response = response as? HTTPURLResponse else { print("Response Error"); return }
            print(response.statusCode)
            guard let decodeData = try? JSONDecoder().decode(Response.self, from: data!) else { print("decode error"); return }
            print(decodeData.message)
        }.resume()
    }

    func regist(password: String, name: String, bio: String, completion: @escaping (Bool) -> Void) {
        struct Request: Codable {
            var name: String
            var token: String
            var password: String
            var description: String
            var profileImage: String?
        }
        struct Response: Codable {
            var message: String
            var success: Bool
        }

        guard let token = verifyToken else { print("verify token error"); return }

        let requestData = Request(name: name, token: token, password: password, description: bio, profileImage: "http://172.20.10.8:58285/icon")

        let url = getURL("api/auth/register")
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")

        request.httpBody = try? JSONEncoder().encode(requestData)
        URLSession.shared.dataTask(with: request) { data, response, error in
            if error != nil { self.onError(String(describing: error), completion); return }

            guard let decodeData = try? JSONDecoder().decode(Response.self, from: data!) else { self.onError("decode error", completion); return }
            completion(decodeData.success)
        }.resume()
    }

    func uploadImage(_ images: [UIImage], folder: String = "folder", completion: @escaping @MainActor (Bool, [String]?) -> Void) {
        struct Body: Codable {
            let urls: [String]
        }
        struct Response: Codable {
            let message: String
            let success: Bool
            let data: Body?
        }

        guard let token = loginToken else { print("verify token error"); return }

        let boundary = UUID().uuidString

        let url = getURL("api/upload/images?folder=\(folder)")
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("\(token)", forHTTPHeaderField: "Authorization")
        request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")

        var body = Data()

        for image in images {
            guard let imageData = image.jpegData(compressionQuality: 0.6) else { print("image error"); return }
            body.append("--\(boundary)\r\n".data(using: .utf8)!)
            body.append("Content-Disposition: form-data; name=\"images\"; filename=\"\(UUID.prefix(10)).jpg\"\r\n".data(using: .utf8)!)
            body.append("Content-Type: image/jpeg\r\n\r\n".data(using: .utf8)!)
            body.append(imageData)
            body.append("\r\n".data(using: .utf8)!)
        }
        body.append("--\(boundary)--\r\n".data(using: .utf8)!)
        request.httpBody = body

        URLSession.shared.dataTask(with: request) { data, response, error in
            if error != nil {
                print("request error")
                print(error!)
                return
            }
            guard let decodeData = try? JSONDecoder().decode(Response.self, from: data!) else { print("decode error"); return }
            Task {
                await completion(decodeData.success, decodeData.data?.urls)
            }
        }.resume()
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

            guard let decodeData = try? JSONDecoder().decode(Response.self, from: data!) else { print("decode error"); return }

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
        }

        struct Response: Codable {
            var success: Bool
            var message: String
            var data: Profile?
        }

        guard let token = loginToken else { print("token not found"); return }
        guard let profile = UserData.shared.userProfile else { print("user not found"); return }

        @MainActor func onUpload(success: Bool, images: [String]?) {
            guard let images = images else { print("Error"); return }
            guard images.first != nil else { print("image error"); completion(false); return }
            let image = images.first!

            let url = getURL("api/user/update/\(profile.id)")
            var request = URLRequest(url: url)
            request.httpMethod = "PUT"
            request.addValue("application/json", forHTTPHeaderField: "Content-Type")
            request.setValue("\(token)", forHTTPHeaderField: "Authorization")

            let body = Request(description: bio, name: name, profileImage: image)
            request.httpBody = try? JSONEncoder().encode(body)

            URLSession.shared.dataTask(with: request) { data, response, error in
                if error != nil { print(error!); return }

                guard let decodeData = try? JSONDecoder().decode(Response.self, from: data!) else { print("decode error"); return }
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
