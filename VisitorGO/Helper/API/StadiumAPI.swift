//
//  StadiumAPI.swift
//  VisitorGO
//
//  Created by shusuke imamura on 2025/01/22.
//

import SwiftUI

extension APIHelper {
    func getStadium(stadiumId: Int, completion: @escaping (StadiumResponseBody?) -> Void) {
        typealias Response = StadiumResponse

        guard let token = loginToken else { print("token not found"); return }

        let url = getURL("api/stadium/\(stadiumId)")
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("\(token)", forHTTPHeaderField: "Authorization")

        URLSession.shared.dataTask(with: request) { data, response, error in
            if error != nil { self.onError(String(describing: error!), completion); return }

            guard let decodeData = try? JSONDecoder().decode(Response.self, from: data!) else { print("\(#function) decode error"); return }

            guard decodeData.success else { self.onError("\(#function) error", completion); return }

            completion(decodeData.data)
        }.resume()
    }

    func searchStadium(keyword: String, completion: @escaping ([StadiumResponseBody]?) -> Void) {
        typealias Response = StadiumSearchResponse

        let url = getURL("api/admin/stadium/stadiums?keyword=\(keyword)")
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")

        URLSession.shared.dataTask(with: request) { data, response, error in
            if error != nil { self.onError(String(describing: error!), completion); return }

            guard let decodeData = try? JSONDecoder().decode(Response.self, from: data!) else { self.onError("\(#function) decode error", completion); return }

            guard decodeData.success else { self.onError("\(#function) error", completion); return }

            completion(decodeData.data)
        }.resume()
    }
}
