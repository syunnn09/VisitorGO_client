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

    func onError(_ reason: String, _ completion: @escaping @MainActor (Bool, UserData?) -> Void) {
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
            if error != nil { self.onError(String(describing: error), completion); return }

            guard let decodeData = try? JSONDecoder().decode(Response.self, from: data!) else { self.onError("decode error", completion); return }
            if decodeData.success {
                self.setToken(token: decodeData.data!.token)
            }
            print(decodeData.message)
            completion(decodeData.success)
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
                print("sample@gmail.com")
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
            guard let response = response as? HTTPURLResponse else { self.onError("response error", completion); return }
            print(response.statusCode)
            print(decodeData.success)
            print(decodeData.message)
            completion(decodeData.success)
        }.resume()
    }

    func uploadImage(_ image: UIImage, folder: String = "folder") {
        guard let token = loginToken else { print("verify token error"); return }
        guard let imageData = image.jpegData(compressionQuality: 1.0) else { print("image error"); return }

        let boundary = UUID().uuidString

        let url = getURL("api/upload/images")
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue("multipart/form-data", forHTTPHeaderField: "Content-Type")
        request.addValue("accept", forHTTPHeaderField: "application/json")
        request.setValue("\(token)", forHTTPHeaderField: "Authorization")

        var data = Data()
        data.append("\r\n--\(boundary)\r\n\r\n".data(using: .utf8)!)
        data.append(imageData)
        print(imageData)

        URLSession.shared.uploadTask(with: request, from: data) { data, response, error in
            if error != nil {
                print("request error")
                print(error!)
                return
            }
            guard let response = response as? HTTPURLResponse else { print("response error"); return }
            print(response.statusCode)
        }.resume()
    }

    func getUserData(completion: @escaping @MainActor (Bool, UserData?) -> Void) {
        struct Response: Codable {
            var success: Bool
            var message: String
            var data: UserData?
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
            print(decodeData.message)
            print(decodeData.success)
            Task {
                await completion(decodeData.success, decodeData.data)
            }
        }.resume()
    }
}

#Preview {
    @Previewable @State var selectedPhoto: PhotosPickerItem?
    @Previewable @State var profileString: String = ""

    VStack {
        Text(profileString)
        Button("Profile API") {
            APIHelper.shared.getUserData() { status, profile in
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
            guard let image = selectedPhoto else { return }
            Task {
                guard let data = try? await image.loadTransferable(type: Data.self) else { return }
                guard let uiImage = UIImage(data: data) else { return }
                APIHelper.shared.uploadImage(uiImage, folder: "folder")
            }
        }
    }
}
