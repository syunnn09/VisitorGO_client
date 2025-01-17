//
//  Locate.swift
//  VisitorGO
//
//  Created by shusuke imamura on 2024/11/18.
//

import MapKit
import SwiftUI
import Foundation

class Locate: Identifiable, Equatable, ObservableObject {
    var id: UUID
    var name: String
    var place: String
    var latitude: CLLocationDegrees
    var longitude: CLLocationDegrees
    
    @Published var alias: String
    @Published var icon: String = "mappin"
    @Published var color: Color = .red
    
    init(name: String, place: String, latitude: CLLocationDegrees, longitude: CLLocationDegrees) {
        self.id = UUID()
        self.name = name
        self.place = place
        self.latitude = latitude
        self.longitude = longitude
        self.alias = name
    }

    var coordinate: CLLocationCoordinate2D {
        CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
    }
}

struct VisitedFacilityRequest: Codable {
    let address: String
    let color: String
    let icon: String
    let latitude: Double
    let longitude: Double
    let name: String

    init(_ locate: Locate) {
        self.address = locate.place
        self.color = "FFAAFF"
        self.icon = locate.icon
        self.latitude = locate.latitude
        self.longitude = locate.longitude
        self.name = locate.alias
    }
}

extension VisitedFacilityRequest {
    static func convert(locates: [Locate]) -> [VisitedFacilityRequest] {
        var facilities: [VisitedFacilityRequest] = []
        for locate in locates {
            facilities.append(VisitedFacilityRequest(locate))
        }
        return facilities
    }
}

extension Locate {
    static func == (lhs: Locate, rhs: Locate) -> Bool {
        return lhs.name == rhs.name && lhs.place == rhs.place
    }
}

extension Locate {
    public static let sample = Locate(name: "東京ドーム", place: "〒112-0004, 東京都文京区, 後楽1丁目3-61", latitude: 35.7055812, longitude: 139.7519134)
}
