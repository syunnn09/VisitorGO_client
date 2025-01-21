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
            var message: String
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

            guard let decodeData = try? JSONDecoder().decode(Response.self, from: data!) else { print("\(#function) decode error"); return }

            if !decodeData.success {
                print(decodeData.message)
                SnackBarManager.shared.error("投稿に失敗しました。")
            }

            completion(decodeData.success)
        }.resume()
    }

    func getExpeditionList(completion: @escaping ([Expedition]?) -> Void) {
        struct Response: Codable {
            var success: Bool
            var message: String
            var data: [Expedition]
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
                print(decodeData.message)
                SnackBarManager.shared.error("取得に失敗しました。")
            }

            completion(decodeData.data)
        }.resume()
    }

    func getExpeditionDetail(expeditionId: Int, completion: @escaping (ExpeditionDetail?) -> Void) {
        struct Response: Codable {
            var success: Bool
            var message: String
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
                print(decodeData.message)
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
