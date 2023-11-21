//
//  CreateEventRequest.swift
//  Map
//
//  Created by Yaroslav Zagumennikov on 19.09.2023.
//

import Foundation

struct locationRequest: Codable {
    let latitude, longitude: Double
}

struct CreateEventRequest: Codable {
    let name, cityName: String
    let location: locationRequest
    let description: String
    let maxCountPlaces: Int
    let date: String
}
