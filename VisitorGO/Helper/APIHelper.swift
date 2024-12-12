//
//  APIHelper.swift
//  VisitorGO
//
//  Created by shusuke imamura on 2024/12/12.
//

import SwiftUI

var token: String = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJleHAiOjE3MzQ1Nzc0MDcsImp0aSI6ImQwMjRkYjg5LTMzYWItNDM0OS05NzMzLWYwMTc2OGI2NWEyMyIsInVzZXJJZCI6M30.b25tLtL9mJWSIunXXhXlTiKCb2Ggas3xSPPI-_mJVKU"

class APIHelper {
    static let shared = APIHelper()

    func login(email: String, password: String) {
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

        let url = URL(string: "https://go-app-bm43.onrender.com/api/auth/login")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")

        request.httpBody = try? JSONEncoder().encode(requestData)
        URLSession.shared.dataTask(with: request) { data, response, error in
            if error != nil {
                print("Error")
                return
            }
            guard let decodeData = try? JSONDecoder().decode(Response.self, from: data!) else { print("decode error"); return }
            guard let response = response as? HTTPURLResponse else { print("Response Error"); return }
            print(response.statusCode)
            print(decodeData.message)
        }.resume()
    }

    func getProtectedHelloWorld() {
        struct Response: Decodable {
            var success: Bool?
            var message: String
        }

        let url = URL(string: "https://go-app-bm43.onrender.com/api/sample/protectedHelloWorld")!
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        request.setValue("\(token)", forHTTPHeaderField: "Authorization")
        URLSession.shared.dataTask(with: request) { data, response, error in
            if error != nil {
                print("sample@gmail.com")
                return
            }

            guard let response = response as? HTTPURLResponse else { print("Response Error"); return }
            print(response.statusCode)
            guard let decodeData = try? JSONDecoder().decode(Response.self, from: data!) else { print("decode error"); return }
            print(decodeData.message)
        }.resume()
    }

    func regist(email: String, password: String, name: String, bio: String) {
        struct Request: Codable {
            var name: String
            var email: String
            var password: String
            var description: String
            var profileImage: String?
        }
        struct Response: Codable {
            var message: String
            var success: Bool
        }

        let requestData = Request(name: name, email: email, password: password, description: bio, profileImage: "http://172.20.10.8:58285/icon")

        let url = URL(string: "https://go-app-bm43.onrender.com/api/auth/register")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")

        request.httpBody = try? JSONEncoder().encode(requestData)
        URLSession.shared.dataTask(with: request) { data, response, error in
            if error != nil {
                print("Error")
                return
            }

            let decodeData = try? JSONDecoder().decode(Response.self, from: data!)
            guard let response = response as? HTTPURLResponse else { print("Response Error"); return }
            print(response.statusCode)
            print(decodeData!.success)
            print(decodeData!.message)
        }.resume()
    }
}
