//
//  UserData.swift
//  VisitorGO
//
//  Created by shusuke imamura on 2024/12/17.
//

import Foundation

struct Profile: Codable {
    var id: Int
    var email: String
    var name: String
    var description: String
    var profileImage: String
    var fileId: String
    var username: String
}
