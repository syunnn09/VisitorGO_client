//
//  RegistUserAPI.swift
//  VisitorGO
//
//  Created by shusuke imamura on 2025/01/10.
//

import SwiftUI

extension APIHelper {
    func regist(username: String, password: String, name: String, bio: String, completion: @escaping (Bool) -> Void) {
        struct Request: Codable {
            var name: String
            var token: String
            var password: String
            var description: String
            var profileImage: String?
            var username: String
            var fileId: String?
        }
        struct Response: Codable {
            var message: String
            var success: Bool
        }
        
        guard let token = verifyToken else { print("verify token error"); return }
        
        let requestData = Request(name: name, token: token, password: password, description: bio, profileImage: "http://172.20.10.8:58285/icon", username: username)
        
        let url = getURL("api/auth/register")
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        
        request.httpBody = try? JSONEncoder().encode(requestData)
        URLSession.shared.dataTask(with: request) { data, response, error in
            if error != nil { self.onError(String(describing: error), completion); return }
            
            guard let decodeData = try? JSONDecoder().decode(Response.self, from: data!) else { self.onError("\(#function) decode error", completion); return }
            completion(decodeData.success)
        }.resume()
    }
}
