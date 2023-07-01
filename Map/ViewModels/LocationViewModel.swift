//
//  LocationViewModel.swift
//  Map
//
//  Created by Yaroslav Zagumennikov on 01.07.2023.
//

import Foundation
import MapKit
import SwiftUI

class LocationViewModel : ObservableObject {
    @Published var locations : [Location]
    
    @Published var mapLocation : Location {
        didSet{
            updateLocation(location: mapLocation)
        }
    }
    @Published var mapRegion = MKCoordinateRegion()
    
    // Показ списка локаций
    @Published var showLocations = false
    
    init(){
        let locations = LocationsDataService.locations
        self.locations = locations
        self.mapLocation = locations.first!
        updateLocation(location: locations.first!)
    
    }
    
    private func updateLocation (location: Location){
        withAnimation(.easeInOut){
            mapRegion = MKCoordinateRegion(
                center: location.coordinates,
                span: MKCoordinateSpan(
                    latitudeDelta: 0.1,
                    longitudeDelta: 0.1
                )
            )
        }
    }
    // Показывать/скрывать список локаций
    func showLocationsList(){
        withAnimation(.easeInOut) {
            showLocations.toggle()
        }
    }
    
    // Переключаться на другую локацию
    func nextLocations (locations : Location){
        withAnimation(.easeInOut) {
            mapLocation = locations
            showLocations = false
        }
    }
}
