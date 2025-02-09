//
//  TeamAPI.swift
//  VisitorGO
//
//  Created by shusuke imamura on 2025/01/21.
//

import Foundation

extension APIHelper {
    /// TODO fix
    func getMyTeam(completion: @escaping (Bool) -> Void) {
        struct Response: Codable {
            var success: Bool
            var messages: [String]
        }

        let endpoint = loginToken != nil ? "me" : "public"
        let url = getURL("api/team/\(endpoint)")

        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        if let token = loginToken {
            request.setValue("\(token)", forHTTPHeaderField: "Authorization")
        }

        URLSession.shared.dataTask(with: request) { data, response, error in
            if error != nil { self.onError(String(describing: error!), completion); return }

            guard let decodeData = try? JSONDecoder().decode(Response.self, from: data!) else { self.onError("\(#function) decode error", completion); return }

            if !decodeData.success {
                print(decodeData.messages)
                SnackBarManager.shared.error("投稿に失敗しました。")
            }

            completion(decodeData.success)
        }.resume()
    }

    func getTeamList(sportsId: Int, completion: @escaping ([TeamResponse]?) -> Void) {
        struct Response: Codable {
            var success: Bool
            var messages: [String]
            var data: [TeamResponse]?
        }

        guard let token = self.loginToken else { self.onError("invalid token", completion); return }
        let url = getURL("api/team/\(sportsId)")

        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("\(token)", forHTTPHeaderField: "Authorization")

        URLSession.shared.dataTask(with: request) { data, response, error in
            if error != nil { self.onError(String(describing: error!), completion); return }
            
            guard let decodeData = try? JSONDecoder().decode(Response.self, from: data!) else { self.onError("\(#function) decode error", completion); return }
            
            if !decodeData.success {
                self.onError("\(#function) \(decodeData.messages.joined(separator: ", "))", completion);
                return
            }
            
            completion(decodeData.data)
        }.resume()
    }
}
