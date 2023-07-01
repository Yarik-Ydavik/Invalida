//
//  Location.swift
//  Map
//
//  Created by Yaroslav Zagumennikov on 01.07.2023.
//

import Foundation
import MapKit

struct Location: Identifiable, Equatable {
      
    let id : String
    let name : String
    let cityName : String
    let coordinates : CLLocationCoordinate2D
    let description : String
    let imageNames : [String]
    let link : String
    
    init(id: String = UUID().uuidString, name: String, cityName: String, coordinates: CLLocationCoordinate2D, description: String, imageNames: [String], link: String) {
        self.id = id
        self.name = name
        self.cityName = cityName
        self.coordinates = coordinates
        self.description = description
        self.imageNames = imageNames
        self.link = link
    }
    
    static func == (lhs: Location, rhs: Location) -> Bool {
        lhs.id == lhs.id
    }
    
}
