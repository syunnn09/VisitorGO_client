//
//  AuthAPI.swift
//  VisitorGO
//
//  Created by shusuke imamura on 2025/01/21.
//

import Foundation

extension APIHelper {
    func sendMail(mail: String, completion: @escaping (Bool) -> Void, tokenType: String="register") {
        struct Response: Codable {
            var message: String
            var success: Bool
        }
        
        let url = getURL("api/auth/emailVerification?email=\(mail)&tokenType=\(tokenType)")
        var request = URLRequest(url: url)
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            if error != nil { print("error: \(String(describing: error))"); return }
            guard let data else { return }
            guard let decodeData = try? JSONDecoder().decode(Response.self, from: data) else { self.onError("\(#function) decode error", completion); return }
            completion(decodeData.success)
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
