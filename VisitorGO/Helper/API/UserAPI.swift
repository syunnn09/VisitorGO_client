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
            var message: String
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

                guard let decodeData = try? JSONDecoder().decode(Response.self, from: data!) else { print("\(#function) decode error"); return }
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
