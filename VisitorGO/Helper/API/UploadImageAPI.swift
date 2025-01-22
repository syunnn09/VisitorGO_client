//
//  UploadImageAPI.swift
//  VisitorGO
//
//  Created by shusuke imamura on 2025/01/10.
//

import SwiftUI

extension APIHelper {
    func uploadImage(_ images: [UIImage], folder: String = "folder", completion: @escaping @MainActor (Bool, [String]?) -> Void) {
        struct Body: Codable {
            let imageUrls: [String]
        }
        struct Response: Codable {
            let message: String
            let success: Bool
            let data: Body?
        }

        let boundary = UUID().uuidString

        let url = getURL("api/upload/images?folder=\(folder)")
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")

        var body = Data()

        for image in images {
            guard let imageData = image.jpegData(compressionQuality: 0.6) else { print("image error"); return }
            body.append("--\(boundary)\r\n".data(using: .utf8)!)
            body.append("Content-Disposition: form-data; name=\"images\"; filename=\"\(UUID.prefix(10)).jpg\"\r\n".data(using: .utf8)!)
            body.append("Content-Type: image/jpeg\r\n\r\n".data(using: .utf8)!)
            body.append(imageData)
            body.append("\r\n".data(using: .utf8)!)
        }
        body.append("--\(boundary)--\r\n".data(using: .utf8)!)
        request.httpBody = body

        URLSession.shared.dataTask(with: request) { data, response, error in
            if error != nil {
                print("request error")
                print(error!)
                return
            }
            guard let decodeData = try? JSONDecoder().decode(Response.self, from: data!) else { print("\(#function) decode error"); return }
            Task {
                await completion(decodeData.success, decodeData.data?.imageUrls)
            }
        }.resume()
    }
}
