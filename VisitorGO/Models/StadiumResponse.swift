//
//  StadiumResponse.swift
//  VisitorGO
//
//  Created by shusuke imamura on 2025/01/22.
//

import SwiftUI

struct StadiumResponse: Codable {
    var success: Bool
    var message: String
    var data: StadiumResponseBody?
}

struct StadiumResponseBody: Codable, Hashable {
    var id: Int
    var name: String
    var description: String
    var address: String
    var capacity: Int
    var image: String
    var expeditions: [Expedition]?
//    var facilities: [Facility]
}

struct Facility: Codable {
    var ame: String
    var address: String
    var visitCount: String
}

struct StadiumSearchResponse: Codable {
    var success: Bool
    var message: String
    var data: [StadiumResponseBody]?
}
