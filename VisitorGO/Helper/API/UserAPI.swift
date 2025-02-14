//
//  UserAPI.swift
//  VisitorGO
//
//  Created by shusuke imamura on 2025/01/21.
//

import Foundation
import SwiftUI

extension APIHelper {
    func isUnique(username: String, completion: @escaping (Bool, String) -> Void) {
        struct Data: Codable {
            var message: String
            var isUnique: Bool
        }

        struct Response: Codable {
            var messages: [String]
            var success: Bool
            var data: Data
        }

        let url = getURL("api/user/isUnique/\(username)")
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")

        URLSession.shared.dataTask(with: request) { data, response, error in
            if error != nil { self.onError(String(describing: error), completion); return }
            
            guard let decodeData = try? JSONDecoder().decode(Response.self, from: data!) else { self.onError("\(#function) decode error", completion); return }
            completion(decodeData.data.isUnique, decodeData.data.message)         
        }.resume()
    }

    func getUserData(completion: @escaping @MainActor (Bool, Profile?) -> Void) {
        struct Response: Codable {
            var success: Bool
            var messages: [String]
            var data: Profile?
        }

        guard let token = loginToken else { self.onError("token not found", completion, false); return }

        let url = getURL("api/user/logined")
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("\(token)", forHTTPHeaderField: "Authorization")

        URLSession.shared.dataTask(with: request) { data, response, error in
            if error != nil { self.onError(String(describing: error!), completion); return }

            guard let decodeData = try? JSONDecoder().decode(Response.self, from: data!) else { self.onError("\(#function) decode error", completion); return }

            guard decodeData.success else { self.onError(decodeData.messages.joined(separator: "\n"), completion); return }

            Task {
                await completion(decodeData.success, decodeData.data)
            }
        }.resume()
    }

    func getUserDataById(userId: Int, completion: @escaping @MainActor (Bool, UserDataResponse?) -> Void) {
        struct Response: Codable {
            var success: Bool
            var messages: [String]
            var data: UserDataResponse?
        }

        guard let token = loginToken else { self.onError("token not found", completion); return }

        let url = getURL("api/user/userId/\(userId)")
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("\(token)", forHTTPHeaderField: "Authorization")

        URLSession.shared.dataTask(with: request) { data, response, error in
            if error != nil { self.onError(String(describing: error!), completion); return }

            guard let decodeData = try? JSONDecoder().decode(Response.self, from: data!) else { self.onError("\(#function) decode error", completion); return }

            guard decodeData.success else { self.onError("ユーザーデータの取得に失敗しました。\n\(decodeData.messages)", completion); return }

            Task {
                await completion(decodeData.success, decodeData.data)
            }
        }.resume()
    }

    @MainActor func updateProfile(username: String, name: String, bio: String, updateImage: Bool, image: UIImage?, favoriteTeams: [Int], completion: @escaping @MainActor (Bool, String) -> Void) {
        struct Request: Encodable {
            var username: String
            var name: String
            var description: String
            var profileImage: String
            var favoriteTeams: [Int]
        }

        struct Response: Codable {
            var success: Bool
            var messages: [String]
            var data: Profile?
        }

        guard let token = loginToken else { self.onError("token not found", completion); return }
        guard let profile = UserData.shared.userProfile else { self.onError("user not found", completion); return }

        @MainActor func onUpload(success: Bool, images: [String]?) {
            guard let images = images else { self.onError("\(#function) Error", completion); return }
            guard let image = images.first else { self.onError("image error", completion); return }

            let url = getURL("api/user/update")
            var request = URLRequest(url: url)
            request.httpMethod = "PUT"
            request.addValue("application/json", forHTTPHeaderField: "Content-Type")
            request.setValue("\(token)", forHTTPHeaderField: "Authorization")

            let body = Request(username: username, name: name, description: bio, profileImage: image, favoriteTeams: favoriteTeams)
            request.httpBody = try? JSONEncoder().encode(body)

            URLSession.shared.dataTask(with: request) { data, response, error in
                guard error == nil else { self.mainActorOnError(String(describing: error), completion); return }

                guard let decodeData = try? JSONDecoder().decode(Response.self, from: data!) else { self.mainActorOnError("\(#function) decode error", completion); return }
                DispatchQueue.main.async {
                    if let data = decodeData.data {
                        UserData.shared.userProfile = data
                    }
                }

                Task {
                    await completion(decodeData.success, decodeData.messages.joined(separator: "\n"))
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
