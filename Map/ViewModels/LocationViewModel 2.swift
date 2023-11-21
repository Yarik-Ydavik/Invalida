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
   
    @Published var planet: Bool = false
    
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
    func nextButtonClicked(location : Location) {
        print (location)
        // Получить текущий индекс выбранной локации
        if let currentIndex = locations.firstIndex(where: { $0.id == location.id }){
            mapLocation = locations[(currentIndex + 1)==locations.count ? 0 : currentIndex + 1]
            print(currentIndex)
        }
        
        // Вызвать функцию updateLocation с новым значением
        updateLocation(location: mapLocation)
    }

}
