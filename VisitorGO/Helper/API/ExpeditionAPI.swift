//
//  ExpeditionAPI.swift
//  VisitorGO
//
//  Created by shusuke imamura on 2025/01/16.
//

import SwiftUI

extension APIHelper {
    func createExpedition(game: Game, completion: @escaping (Bool) -> Void) {
        typealias Request = Game

        struct Response: Codable {
            var success: Bool
            var messages: [String]
            var data: Profile?
        }

        guard let token = loginToken else { print("token not found"); return }

        let url = getURL("api/expedition/create")
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("\(token)", forHTTPHeaderField: "Authorization")
        request.httpBody = try? JSONEncoder().encode(game)

        URLSession.shared.dataTask(with: request) { data, response, error in
            if error != nil { self.onError(String(describing: error!), completion); return }
            self.printStatusCode(response: response)

            guard let decodeData = try? JSONDecoder().decode(Response.self, from: data!) else { self.onError("\(#function) decode error", completion); return }

            if !decodeData.success { self.onError("投稿に失敗しました。\(decodeData.messages)", completion); return }

            completion(decodeData.success)
        }.resume()
    }

    func deleteExpedition(_ expeditionId: Int, completion: @escaping (Bool) -> Void) {
        struct Response: Codable {
            var success: Bool
            var messages: [String]
        }

        guard let token = loginToken else { print("token not found"); return }

        let url = getURL("api/expedition/delete/\(expeditionId)")
        var request = URLRequest(url: url)
        request.httpMethod = "DELETE"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("\(token)", forHTTPHeaderField: "Authorization")

        URLSession.shared.dataTask(with: request) { data, response, error in
            if error != nil { self.onError(String(describing: error!), completion); return }

            guard let decodeData = try? JSONDecoder().decode(Response.self, from: data!) else { self.onError("\(#function) decode error", completion); return }

            if !decodeData.success { self.onError("削除に失敗しました。\(decodeData.messages)", completion); return }

            completion(decodeData.success)
        }.resume()
    }

    func likeExpedition(expeditionId: Int, completion: @escaping (LikeResponse?) -> Void) {
        struct Response: Codable {
            var success: Bool
            var messages: [String]
            var data: LikeResponse?
        }

        guard let token = loginToken else { self.onError("ログインしてください。", completion); return }
        let url = getURL("api/expedition/like/\(expeditionId)")

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("\(token)", forHTTPHeaderField: "Authorization")

        URLSession.shared.dataTask(with: request) { data, response, error in
            if error != nil { self.onError(String(describing: error!), completion); return }

            guard let decodeData = try? JSONDecoder().decode(Response.self, from: data!) else { self.onError("\(#function) decode error", completion); return }

            guard decodeData.success else { self.onError(decodeData.messages.joined(separator: "\n"), completion); return }

            completion(decodeData.data)
        }.resume()
    }

    func getExpeditionList(completion: @escaping ([Expedition]?) -> Void) {
        struct Response: Codable {
            var success: Bool
            var messages: [String]
            var data: [Expedition]?
        }

        guard let token = loginToken else { print("token not found"); return }
        let url = getURL("api/expedition/list?page=1")

        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("\(token)", forHTTPHeaderField: "Authorization")

        URLSession.shared.dataTask(with: request) { data, response, error in
            if error != nil { self.onError(String(describing: error!), completion); return }

            guard let decodeData = try? JSONDecoder().decode(Response.self, from: data!) else { self.onError("\(#function) decode error", completion); return }

            if !decodeData.success {
                print(decodeData.messages)
                SnackBarManager.shared.error("取得に失敗しました。")
            }

            completion(decodeData.data)
        }.resume()
    }

    func getExpeditionListByUser(userId: Int, page: Int=1, completion: @escaping ([Expedition]?) -> Void) {
        struct Response: Codable {
            var success: Bool
            var messages: [String]
            var data: [Expedition]?
        }

        guard let token = loginToken else { print("token not found"); return }
        let url = getURL("api/expedition/list/user?userId=\(userId)&page=\(page)")

        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("\(token)", forHTTPHeaderField: "Authorization")

        URLSession.shared.dataTask(with: request) { data, response, error in
            if error != nil { self.onError(String(describing: error!), completion); return }

            guard let decodeData = try? JSONDecoder().decode(Response.self, from: data!) else { self.onError("\(#function) decode error", completion); return }

            if !decodeData.success { self.onError(decodeData.messages.joined(separator: "\n"), completion); return }

            completion(decodeData.data)
        }.resume()
    }

    func getFavoriteExpeditionList(userId: Int, page: Int=1, completion: @escaping ([Expedition]?) -> Void) {
        struct Response: Codable {
            var success: Bool
            var messages: [String]
            var data: [Expedition]?
        }

        guard let token = loginToken else { print("token not found"); return }
        let url = getURL("api/expedition/list/user/likes?userId=\(userId)&page=\(page)")

        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("\(token)", forHTTPHeaderField: "Authorization")

        URLSession.shared.dataTask(with: request) { data, response, error in
            if error != nil { self.onError(String(describing: error!), completion); return }

            guard let decodeData = try? JSONDecoder().decode(Response.self, from: data!) else { self.onError("\(#function) decode error", completion); return }

            if !decodeData.success { self.onError(decodeData.messages.joined(separator: "\n"), completion); return }

            completion(decodeData.data)
        }.resume()
    }

    func getExpeditionDetail(expeditionId: Int, completion: @escaping (ExpeditionDetail?) -> Void) {
        struct Response: Codable {
            var success: Bool
            var messages: [String]
            var data: ExpeditionDetail
        }

        guard let token = loginToken else { print("token not found"); return }
        let url = getURL("api/expedition/\(expeditionId)")

        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("\(token)", forHTTPHeaderField: "Authorization")

        URLSession.shared.dataTask(with: request) { data, response, error in
            if error != nil { self.onError(String(describing: error!), completion); return }

            guard let decodeData = try? JSONDecoder().decode(Response.self, from: data!) else { self.onError("\(#function) decode error", completion); return }

            if !decodeData.success {
                print(decodeData.messages)
                SnackBarManager.shared.error("投稿に失敗しました。")
            }

            completion(decodeData.data)
        }.resume()
    }
}

#Preview {
    @Previewable @State var expedition: Expedition?

    VStack {
        Text(expedition?.title ?? "no title")

        CreatePostView(sports: .constant(Sports.baseball))
    }
    .onAppear {
        APIHelper.shared.getExpeditionList { expeditionData in
            expedition = expeditionData?.first
        }
    }
}
