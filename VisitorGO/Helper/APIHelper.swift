//
//  APIHelper.swift
//  VisitorGO
//
//  Created by shusuke imamura on 2024/12/12.
//

import SwiftUI

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

        let url = URL(string: "\(baseURL)/api/auth/login")!
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

        let url = URL(string: "\(baseURL)/api/sample/protectedHelloWorld")!
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

        let url = URL(string: "\(baseURL)/api/auth/register")!
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
}
