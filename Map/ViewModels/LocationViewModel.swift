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
//    let point1 = CLLocationCoordinate2DMake(-73.761105, 41.017791);
//    let point2 = CLLocationCoordinate2DMake(-73.760701, 41.019348);
//    let point3 = CLLocationCoordinate2DMake(-73.757201, 41.019267);
//    let point4 = CLLocationCoordinate2DMake(-73.757482, 41.016375);
//    let point5 = CLLocationCoordinate2DMake(-73.761105, 41.017791);
//    
//    var points: [CLLocationCoordinate2D] = []
//    var geodesic: MKGeodesicPolyline?

    
    
    
    
    
    
    
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
//        points = [point1 , point2, point3, point4, point5]
//        geodesic = MKGeodesicPolyline(coordinates: points , count: 5)

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
