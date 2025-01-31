//
//  StadiumResponse.swift
//  VisitorGO
//
//  Created by shusuke imamura on 2025/01/22.
//

import SwiftUI

struct StadiumResponse: Codable {
    var success: Bool
    var messages: [String]
    var data: StadiumResponseBody?
}

struct StadiumResponseBody: Codable, Hashable {
    var id: Int
    var name: String
    var description: String
    var address: String
    var capacity: Int
    var image: String
    var attribution: String?
    var expeditions: [Expedition]?
    var facilities: [Facility]?
}

struct Facility: Codable, Hashable {
    var name: String
    var address: String
    var visitCount: Int
}

struct StadiumSearchResponse: Codable {
    var success: Bool
    var messages: [String]
    var data: [StadiumResponseBody]?
}
