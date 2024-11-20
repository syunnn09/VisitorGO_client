//
//  MapViewHelper.swift
//  VisitorGO
//
//  Created by shusuke imamura on 2024/11/18.
//

import SwiftUI
import MapKit

class MapViewHelper: NSObject, ObservableObject, MKLocalSearchCompleterDelegate {
    var completer = MKLocalSearchCompleter()
    @Published var location = ""
    @Published var searchQuery = ""
    @Published var completions: [MKLocalSearchCompletion] = []
    @Published var locationDetail = ""
    
    override init() {
        super.init()
        completer.delegate = self
        completer.resultTypes = .pointOfInterest
    }
    
    func onSearchLocation() {
        if searchQuery == location {
            completions = []
            return
        }
        
        searchQuery = location
        
        if searchQuery.isEmpty {
            completions = []
        } else {
            if completer.queryFragment != searchQuery {
                completer.queryFragment = searchQuery
            }
        }
    }
    
    func completerDidUpdateResults(_ completer: MKLocalSearchCompleter) {
        DispatchQueue.main.async {
            if self.searchQuery.isEmpty {
                self.completions = .init()
            } else {
                self.completions = completer.results
            }
        }
    }
    
    func searchLocation(locate: MKLocalSearchCompletion, completion: @escaping @MainActor (MKLocalSearchCompletion, CLLocationCoordinate2D) -> Void) {
        let request = MKLocalSearch.Request()
        request.naturalLanguageQuery = locate.title + "," + locate.subtitle
        
        MKLocalSearch(request: request).start { (response, err) in
            if let error = err {
                print("MKLocalSearch Error: \(error)")
                return
            }
            if let item = response?.mapItems.first {
                DispatchQueue.main.async {
                    completion(locate, item.placemark.coordinate)
                }
            }
        }
    }
}
