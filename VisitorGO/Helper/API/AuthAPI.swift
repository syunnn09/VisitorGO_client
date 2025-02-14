//
//  AuthAPI.swift
//  VisitorGO
//
//  Created by shusuke imamura on 2025/01/21.
//

import SwiftUI
import Foundation

extension APIHelper {
    func sendMail(mail: String, completion: @escaping (Bool, [String]) -> Void, tokenType: String="register") {
        struct Response: Codable {
            var messages: [String]
            var success: Bool
        }

        let url = getURL("api/auth/emailVerification?email=\(mail)&tokenType=\(tokenType)")
        var request = URLRequest(url: url)
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("application/json", forHTTPHeaderField: "Accept")

        URLSession.shared.dataTask(with: request) { data, response, error in
            if error != nil { self.onError("error: \(String(describing: error))", completion); return }

            guard let data else { self.onError("data error", completion); return }
            guard let decodeData = try? JSONDecoder().decode(Response.self, from: data) else { self.onError("\(#function) decode error", completion); return }

            completion(decodeData.success, decodeData.messages)
        }.resume()
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
            var messages: [String]
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

            guard let decodeData = try? JSONDecoder().decode(Response.self, from: data!) else { self.onError("\(#function) decode error", completion); return }
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

    func regist(username: String, password: String, name: String, bio: String, profileImage: UIImage?, favoriteTeamIds: [Int], completion: @escaping (Bool, [String]) -> Void) {
        struct Request: Codable {
            var name: String
            var token: String
            var password: String
            var description: String
            var profileImage: String
            var username: String
            var favoriteTeamIds: [Int]
        }

        struct Response: Codable {
            var success: Bool
            var messages: [String]
            var data: Profile?
        }

        guard let profileImage = profileImage else { self.onError("プロフィール画像を設定してください", completion); return }
        guard let token = verifyToken else { self.onError("トークンが存在しません\nもう一度やり直してください", completion); return }

        func onUpload(success: Bool, images: [String]?) {
            let errorMessage = "画像アップロードに失敗しました"
            guard let images = images else { self.onError("\(errorMessage)", completion); return }
            guard let image = images.first else { self.onError("\(errorMessage)", completion); return }

            let url = getURL("api/auth/register")
            var request = URLRequest(url: url)
            request.httpMethod = "POST"
            request.addValue("application/json", forHTTPHeaderField: "Content-Type")

            let body = Request(name: name, token: token, password: password, description: bio, profileImage: image, username: username, favoriteTeamIds: favoriteTeamIds)
            request.httpBody = try? JSONEncoder().encode(body)
            
            URLSession.shared.dataTask(with: request) { data, response, error in
                if error != nil { self.onError(String(describing: error), completion); return }
                
                guard let decodeData = try? JSONDecoder().decode(Response.self, from: data!) else { self.onError("\(#function) decode error", completion); return }
                completion(decodeData.success, decodeData.messages)
            }.resume()
        }

        uploadImage([profileImage], completion: onUpload)
    }

    func updatePassword(beforePassword: String, newPassword: String, completion: @escaping @MainActor (Bool, String) -> Void) {
        struct Response: Codable {
            var success: Bool
            var messages: [String]
        }

        struct Request: Codable {
            var afterPassword: String
            var beforePassword: String
        }

        guard let token = loginToken else { print("token not found"); return }
        let url = getURL("api/auth/updatePass")
        let requestData = Request(afterPassword: newPassword, beforePassword: beforePassword)

        var request = URLRequest(url: url)
        request.httpMethod = "PUT"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("\(token)", forHTTPHeaderField: "Authorization")
        request.httpBody = try? JSONEncoder().encode(requestData)

        URLSession.shared.dataTask(with: request) { data, response, error in
            if error != nil { self.mainActorOnError(String(describing: error!), completion); return }

            guard let decodeData = try? JSONDecoder().decode(Response.self, from: data!) else { self.mainActorOnError("\(#function) decode error", completion); return }

            Task {
                await completion(decodeData.success, decodeData.messages.joined(separator: "\n"))
            }
        }.resume()
    }
}
