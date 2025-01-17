//
//  SendMailAPI.swift
//  VisitorGO
//
//  Created by shusuke imamura on 2025/01/10.
//

import SwiftUI

extension APIHelper {
    func sendMail(mail: String, completion: @escaping (Bool) -> Void) {
        struct Response: Codable {
            var message: String
            var success: Bool
        }
        
        let url = getURL("api/auth/emailVerification?email=\(mail)&tokenType=register")
        var request = URLRequest(url: url)
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            if error != nil { print("error: \(String(describing: error))"); return }
            guard let data else { return }
            guard let decodeData = try? JSONDecoder().decode(Response.self, from: data) else { self.onError("\(#function) decode error", completion); return }
            print(decodeData.success)
            completion(decodeData.success)
        }.resume()
    }
}
