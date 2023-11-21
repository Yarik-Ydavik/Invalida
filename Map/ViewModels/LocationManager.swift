//
//  LocationManager.swift
//  Map
//
//  Created by Yaroslav Zagumennikov on 18.09.2023.
//

import Foundation
import SwiftUI
import CoreLocation
import MapKit
import Combine

class LocationManager: NSObject, ObservableObject, MKMapViewDelegate, CLLocationManagerDelegate {
    @Published var mapView: MKMapView = .init()
    @Published var manager: CLLocationManager = .init()
    
    // Данные со страницы создания событий
    //--------------------------------------------------------------------///////////////////////////////////////////////////////////////
    @Published var nameEvent: String = ""
    @Published var descriptionEvent: String = ""
    @Published var searchText: String = ""
    
    @Published var latitude: Double = 0
    @Published var longtitude: Double = 0
    
    @Published var images:[UIImage?] = []
    @Published var imagesName:[String] = []
    
    @Published var eventImages: [String : UIImage] = [:]
    @Published var downloadImage: Bool = false
    
    @Published var maxCountPlaces: Int = 0
    @Published var selectedDate: Date = Date()

    //--------------------------------------------------------------------///////////////////////////////////////////////////////////////
    //--------------------------------------------------------------------///////////////////////////////////////////////////////////////
    var cancellable: AnyCancellable?
    @Published var fetchedPlaces: [CLPlacemark]?
    
    @Published var userLocation: CLLocation?
    
    @Published var pickedLocation: CLLocation?
    @Published var pickedPlaceMark: CLPlacemark?
    
    @Published var eventAddress: [String : CLPlacemark] = [:]
    
    @Published var userCity: String = ""

    //-------------------------------------------------------------
    //перенос с locationViewModel
    @Published var locations : [CreateEventResponse] = []
    @Published var mapLocation : CreateEventResponse =
    CreateEventResponse(
        id: "",
        name: "",
        cityName: "",
        location: locationRequest(latitude: 0, longitude: 0),
        description: "",
        date: "",
        maxCountPlaces: 0,
        currentCountPlaces: 0,
        images: [""]
    ) {
        didSet{
            updateLocation(location: mapLocation)
        }
    }
    @Published var mapRegion = MKCoordinateRegion()
    
    // Показ списка локаций
    @Published var showLocations = false
    
    @Published var planet: Bool = false

    private func updateLocation (location: CreateEventResponse){
        mapRegion = MKCoordinateRegion(
            center: CLLocationCoordinate2D(latitude: Double(location.location.latitude), longitude: Double(location.location.longitude)),
            span: MKCoordinateSpan(
                latitudeDelta: 0.1,
                longitudeDelta: 0.1
            )
        )
    }
    
    // Показывать/скрывать список локаций
    func showLocationsList(){
        withAnimation(.easeInOut) {
            showLocations.toggle()
        }
    }
    
    // Загрузка изображения мероприятия
    func loadImage(from urlString: String, eventId: String, completion: @escaping (UIImage?) -> Void) {

        let components = urlString.components(separatedBy: "events/")
        if let lastComponent = components.last {
            guard let url = URL(string: "http://localhost:9090/api/upload/events/\(lastComponent)") else { return }

            URLSession.shared.dataTask(with: url) { data, response, error in
                guard let data = data, error == nil else {
                    print("Error loading image: \(error?.localizedDescription ?? "Unknown error")")
                    return
                }

                DispatchQueue.main.async {
                    let image = UIImage(data: data)
                    self.eventImages[eventId] = image
                    completion(image)
                }
            }.resume()
        }
    }
    
    // Переключаться на другую локацию
    func nextLocations (location : CreateEventResponse){
        withAnimation(.easeInOut) {
            mapLocation = location
            showLocations = false
        }
    }
    
    // Нажатие на кнопку далее у превью локации
    func nextButtonClicked(location : CreateEventResponse) {
        // Получить текущий индекс выбранной локации
        guard let currentIndex = locations.firstIndex(where: { $0.id == location.id }) else{
            print("Невозможно найти текущий индекс локации")
            return
        }
        let nextIndex = currentIndex + 1
        
        guard locations.indices.contains(nextIndex) else {
            guard let firstLocation = locations.first else { return }
            nextLocations(location: firstLocation)
            return
        }
        let nextLocation = locations[nextIndex]
        nextLocations(location: nextLocation)
    }
    //-------------------------------------------------------------

    override init () {
        super.init()

        
        manager.delegate = self
        mapView.delegate = self
        
        manager.requestWhenInUseAuthorization()
        cancellable = $searchText
            .debounce(for: .seconds(0.5) , scheduler: DispatchQueue.main)
            .removeDuplicates()
            .sink(receiveValue: { [weak self] value in
                if value != "" {
                    self?.fetchPlaces(value: value)
                }else {
                    self?.fetchedPlaces = nil
                }
            })
    }
    
    func fetchPlaces(value: String) {
        Task{
            do {
                let request = MKLocalSearch.Request()
                request.naturalLanguageQuery = value.lowercased()
                
                let response = try await MKLocalSearch(request: request).start()
                
                await MainActor.run {
                    self.fetchedPlaces = response.mapItems.compactMap({ item -> CLPlacemark? in
                        return item.placemark
                    })
                }
            }catch {
                
            }
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let currentLocation = locations.last else { return }
        self.userLocation = currentLocation
        
        CLGeocoder().reverseGeocodeLocation(userLocation ?? CLLocation(latitude: 0, longitude: 0)) { placemarks, error in
            if let error = error {
                print("Reverse geocoding failed: \(error.localizedDescription)")
                return
            }
            
            guard let placemark = placemarks?.first else { return }
            let locality = placemark.locality?.localizedLowercase ?? ""
            let englishCity = self.convertToEnglish(locality)
            self.userCity = englishCity
            
            self.showCityLocations()
        }
    }
    
    func convertToEnglish(_ string: String) -> String {
        let locale = Locale(identifier: "en_US")
        guard let englishString = string.applyingTransform(.toLatin, reverse: false)?.applyingTransform(.stripDiacritics, reverse: false) else {
            return string
        }
        return englishString.capitalized(with: locale)
    }

    
    func showCityLocations () {
        WebService().getEventsCity(userCity: userCity, accessToken: UserViewModel().tokensAuthorization.first!.accessToken!) { [weak self] result in
            switch result{
                case .success(let eventsInfo):
                    DispatchQueue.main.async {
                        self?.locations = eventsInfo
                        if eventsInfo.isEmpty { print("Не было получено никаких мероприятий от сервера по этому гооду") }
                        else {
                            self?.mapLocation = eventsInfo.first ??
                                CreateEventResponse(
                                    id: "",
                                    name: "",
                                    cityName: "",
                                    location: locationRequest(
                                        latitude: LocationsDataService.locations.first!.coordinates.latitude,
                                        longitude: LocationsDataService.locations.first!.coordinates.longitude
                                    ),
                                    description: "",
                                    date: "",
                                    maxCountPlaces: 0,
                                    currentCountPlaces: 0,
                                    images: [""]
                                )
                            self?.updateLocation(location: eventsInfo.first ??
                                 CreateEventResponse(
                                     id: "",
                                     name: "",
                                     cityName: "",
                                     location: locationRequest(
                                         latitude: LocationsDataService.locations.first!.coordinates.latitude,
                                         longitude: LocationsDataService.locations.first!.coordinates.longitude
                                     ),
                                     description: "",
                                     date: "",
                                     maxCountPlaces: 0,
                                     currentCountPlaces: 0,
                                     images: [""]
                                 )
                            )
                        }
                        
                    }
                    
                case .failure(let error):
                    print("Ошибка c получением событий по городу")
                    print(error)
                    print(error.localizedDescription)
            }
        }
    }
    
    func addPhoto(eventId: String, userToken: String){
        
        WebService().addImagesToEvent(
            Authorization: userToken,
            eventId: eventId,
            fileNames: imagesName,
            images: images) { result in
                switch result{
                    case .success(let photosInfo):
                        for photo in photosInfo {
                            print(photo)
                        }
                    case .failure(let error):
                        print("Ошибка c добавлением картинок к событию по городу")
                        print(error)
                        print(error.localizedDescription)
                }
            }
    }
    
    // Запись на событие
    func recordOnEvent (
        eventId: String
    ) {
        WebService().recordingEvent(Authorization: UserViewModel().tokensAuthorization.first!.accessToken!, eventId: eventId ) { result in
            switch result {
            case .success(let success):
                print(success)
                if let index = self.locations.firstIndex(where: { $0.id == eventId }) {
                    self.locations[index].currentCountPlaces += 1
                }
            case .failure(let failure):
                print(failure)
            }
        }
    }
    
    func addEventCity(){
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd.MM.yyyy" // формат даты
        let dateString = dateFormatter.string(from: selectedDate) // преобразование в строку
        
        WebService().createEvent(
                accessToken: UserViewModel().tokensAuthorization.first!.accessToken!,
                name: nameEvent,
                cityName: userCity,
                location: locationRequest(latitude: latitude, longitude: longtitude),
                description: descriptionEvent,
                maxCountPlaces: maxCountPlaces,
                date: dateString
        ) { [weak self] result in
            switch result{
                case .success(let eventInfo):
                    if self?.images.count != 0 {
                        self?.addPhoto(eventId: eventInfo.id, userToken: UserViewModel().tokensAuthorization.first!.accessToken!)
                        DispatchQueue.main.async {
                            // Опубликование значения из главного потока
                            self?.locations.append(eventInfo)
                        }
                    }else {
                        // Выполнение длительной операции в фоновом потоке
                        DispatchQueue.main.async {
                            // Опубликование значения из главного потока
                            self?.locations.append(eventInfo)
                        }

                    }
                    
                case .failure(let error):
                    print("Ошибка c созданием события по городу")
                    print(error)
                    print(error.localizedDescription)
            }
        }
            
    }
    
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        switch manager.authorizationStatus{
        case .notDetermined: manager.requestWhenInUseAuthorization()
        case .denied: handleLocationError()
        case .authorizedAlways: manager.requestLocation()
        case .authorizedWhenInUse: manager.requestLocation()
        @unknown default:
            ()
        }
    }
    
    func handleLocationError() {
         
    }
    
    func addDraggablePin(coordinate: CLLocationCoordinate2D){
        let annotation = MKPointAnnotation()
        annotation.coordinate = coordinate
        annotation.title = "Мероприятие"
        
        mapView.addAnnotation(annotation)
    }
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        let marker = MKMarkerAnnotationView(annotation: annotation, reuseIdentifier: "DELIVERYPIN")
        marker.isDraggable = true
        marker.canShowCallout = false
        
        return marker
    }
    
    func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView, didChange newState: MKAnnotationView.DragState, fromOldState oldState: MKAnnotationView.DragState) {
        guard let newLocation = view.annotation?.coordinate else {return}
        self.pickedLocation = .init(latitude: newLocation.latitude, longitude: newLocation.longitude)
        updatePlacemark(location: .init(latitude: newLocation.latitude, longitude: newLocation.longitude))
    }
    
    func updatePlacemark(location: CLLocation) {
        Task {
            do {
                guard let place = try await reverseLocationCoordinates(location: location) else {return}
                await MainActor.run {
                    self.pickedPlaceMark = place
                }
            } catch {
                
            }
        }
    }
    
    func searchAddres (location: CreateEventResponse){
        Task {
            do {
                guard let place = try await reverseLocationCoordinates(location: CLLocation(latitude: location.location.latitude, longitude: location.location.longitude)) else {return}
                await MainActor.run {
                    self.eventAddress[location.id] = place
                }
            } catch {
                
            }
        }
    }
    
    func reverseLocationCoordinates (location: CLLocation) async throws -> CLPlacemark? {
        let place = try await CLGeocoder().reverseGeocodeLocation(location).first
        return place
    }
}
extension Date {
    func toUTC() -> Date {
        let timeZoneOffset = TimeInterval(TimeZone.current.secondsFromGMT())
        return self.addingTimeInterval(timeZoneOffset)
    }
}
