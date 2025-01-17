//
//  LoginAPI.swift
//  VisitorGO
//
//  Created by shusuke imamura on 2025/01/10.
//

import SwiftUI

extension APIHelper {
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
}
