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
    func nextLocations (location : Location){
        withAnimation(.easeInOut) {
            mapLocation = location
            showLocations = false
        }
    }
    
    // Нажатие на кнопку далее у превью локации
    func nextButtonClicked() {
        guard let currentIndex = locations.firstIndex(where: {$0 == mapLocation}) else { return }
        
        let nextIndex = currentIndex + 1
        guard locations.indices.contains(nextIndex) else {
            guard let nextLocation = locations.first else { return }
            nextLocations(location : nextLocation)
            return
        }
        let nextLocation = locations[nextIndex]
        nextLocations(location: nextLocation)
    }
}
