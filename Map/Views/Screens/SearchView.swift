//
//  MapScreenView.swift
//  Map
//
//  Created by Yaroslav Zagumennikov on 16.09.2023.
//

import SwiftUI
import CoreLocation
import MapKit
import AVKit

struct SearchView: View {
    @EnvironmentObject var locationManager: LocationManager 
    
    @State var navigationTag: String?
    @State var showList = false
    
    @State private var showSheet = false
    @StateObject var mediaItems = PickedMediaItems()
    
    // Выбор даты мероприятия
    @Environment(\.dismiss) var dismiss
    var body: some View {
        VStack {
            HStack(spacing: 15) {
                Button {
                    dismiss()
                } label: {
                    Image(systemName: "chevron.left")
                        .font(.title3)
                        .foregroundStyle(Color.primary)
                }
                Text("Добавить мероприятие")
                    .font(.title3)
                    .fontWeight(.semibold)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.leading)
            
            
            ScrollView  {
                TextFieldEvent(
                    icon: "",
                    hint: "Название мероприятия",
                    binding: $locationManager.nameEvent,
                    bindingButton: $showList
                )
                
                HStack(spacing: 10, content: {
                    TextField("Описание мероприятия", text: $locationManager.descriptionEvent, axis: .vertical)
                        .lineLimit(4...10)
                        .frame(maxHeight: .infinity)
                        .layoutPriority(1)

                })
                .padding(.vertical, 12)
                .padding(.horizontal)
                .background{
                    RoundedRectangle(cornerRadius: 10, style: .continuous)
                        .strokeBorder(.gray)
                }
                .padding(.vertical, 5)
                DateFieldEvent(binding: $locationManager.selectedDate )
                
                HStack(spacing: 10, content: {
                    TextField("Количество доступных мест", text: Binding<String>(
                        get: { locationManager.maxCountPlaces.description },
                        set: { locationManager.maxCountPlaces = Int($0) ?? 0 }
                    ))
                    .frame(width: 30, alignment: Alignment.center)

                })
                .padding(.vertical, 12)
                .padding(.horizontal)
                .background{
                    RoundedRectangle(cornerRadius: 10, style: .continuous)
                        .strokeBorder(.gray)
                }
                .padding(.top, 5)
                .frame(width: UIScreen.main.bounds.size.width - 30, alignment: .leading)
                Text("Количество доступных мест")
                    .frame(width: UIScreen.main.bounds.size.width - 30 , alignment: Alignment.leading)
                    .foregroundStyle(Color.gray)
                    .font(.caption)
                
                TextFieldEvent(
                    icon: "magnifyingglass",
                    hint: "Найти локацию",
                    binding: $locationManager.searchText,
                    bindingButton: $showList
                )
                
                if showList == true, let places = locationManager.fetchedPlaces, !places.isEmpty {
                    ScrollView {
                        ForEach (places, id: \.self) { place in
                            Button(action: {
                                if let coordinate = place.location?.coordinate{
                                    locationManager.pickedLocation = .init(latitude: coordinate.latitude, longitude: coordinate.longitude)
                                    locationManager.mapView.region = .init(center: coordinate, latitudinalMeters: 1000, longitudinalMeters: 1000)
                                    locationManager.addDraggablePin(coordinate: coordinate)
                                    locationManager.updatePlacemark(location: .init(latitude: coordinate.latitude, longitude: coordinate.longitude))
                                }
                                navigationTag = "MAPVIEW"
                            }, label: {
                                HStack(spacing: 15, content: {
                                    Image(systemName: "mappin.circle.fill")
                                        .font(.title2)
                                        .foregroundStyle(.gray)
                                    
                                    VStack(alignment: .leading, spacing: 6, content: {
                                        Text(place.name ?? "")
                                            .font(.title3.bold())
                                            .foregroundStyle(Color.primary )
                                        
                                        Text(place.locality ?? "")
                                            .font(.caption)
                                            .foregroundStyle(.gray)
                                    })
                                })
                            })
                            .frame(width: UIScreen.main.bounds.size.width - 40, alignment: .leading)
                        }
                    }
                    .frame(maxHeight: 100)

                }else {
                    Button(action: {
                        if let coordinate = locationManager.userLocation?.coordinate{
                            locationManager.mapView.region = .init(center: coordinate, latitudinalMeters: 1000, longitudinalMeters: 1000)
                            locationManager.addDraggablePin(coordinate: coordinate)
                            locationManager.updatePlacemark(location: .init(latitude: coordinate.latitude, longitude: coordinate.longitude))
                            navigationTag = "MAPVIEW"
                        }
                    }, label: {
                        Label(
                            title: { Text("Использовать текущее местоположение").font(.callout) },
                            icon: { Image(systemName: "location.north.circle.fill") }
                        )
                        .foregroundStyle(.green)
                    })
                    .frame(maxWidth: .infinity, alignment: .leading)
                }

                HStack {
                    Button(action: {
                        mediaItems.deleteAll()
                    }, label: {
                        Image(systemName: "trash")
                            .foregroundColor(.red)
                    })
                    Spacer()
                    Text("Фото")
                    Spacer()
                    Button(action: {
                        showSheet = true
                    }, label: {
                        Image(systemName: "plus")
                    })
                }
                .padding(.vertical, 10)
                .padding(.horizontal)
                .background{
                    RoundedRectangle(cornerRadius: 10, style: .continuous)
                        .strokeBorder(Color.clear)
                }
                .padding(.vertical, 5)
                ScrollView {
                    ForEach(mediaItems.items, id: \.id) { item in
                        
                        ZStack(alignment: .topLeading) {
                            if item.mediaType == .photo {
                                Image(uiImage: item.photo ?? UIImage())
                                    .resizable()
                                    .aspectRatio(contentMode: .fit)
                            } else if item.mediaType == .video {
                                if let url = item.url {
                                    VideoPlayer(player: AVPlayer(url: url))
                                        .frame(minHeight: 200)
                                } else { EmptyView() }
                            } else {
                                if let livePhoto = item.livePhoto {
                                    LivePhotoView(livePhoto: livePhoto)
                                        .frame(minHeight: 200)
                                } else { EmptyView() }
                            }
                                                
                            Image(systemName: getMediaImageName(using: item))
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(width: 24, height: 24)
                                .padding(4)
                                .background(Color.black.opacity(0.5))
                                .foregroundColor(.white)
                        }
                    }
                    .sheet(isPresented: $showSheet, content: {
                        PhotoPicker(mediaItems: mediaItems) { didSelectItem in
                            // Handle didSelectItems value here...
                            showSheet = false
                        }.ignoresSafeArea(.all)
                    })
                }
            }
            .padding()
            .frame(maxHeight: UIScreen.main.bounds.size.height, alignment: .top)
            .background{
                NavigationLink(tag: "MAPVIEW", selection: $navigationTag) {
                    MapViewSelection(showLocations: $showList)
                        .environmentObject(locationManager)
                        .toolbar(.hidden)
                } label: {}
                    .labelsHidden()
            }
            
        }
        Button(action: {
            if !mediaItems.items.isEmpty {
                for item in mediaItems.items {
                    locationManager.images.append(item.photo)
                    locationManager.imagesName.append(item.id)
                }
            }
            locationManager.addEventCity()
            dismiss()
        }, label: {
            Text("Добавить мероприятие")
                .tint(.white)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 12)
                .padding(.horizontal)
                .background{
                    RoundedRectangle(cornerRadius: 10, style: .continuous)
                        .fill(Color.blue)
                        .strokeBorder(.gray)
                        
                }
                .padding(.vertical, 5)
        })
        .padding(.horizontal)
    }
    fileprivate func getMediaImageName(using item: PhotoPickerModel) -> String {
        switch item.mediaType {
            case .photo: return "photo"
            case .video: return "video"
            case .livePhoto: return "livephoto"
        }
    }
}

extension SearchView {
    private func TextFieldEvent (
        icon: String,
        hint: String,
        binding: Binding<String>,
        bindingButton: Binding<Bool>
    ) -> some View {
        HStack(spacing: 10, content: {
            Image(systemName: "\(icon)")
                .foregroundStyle(.gray)
            
            TextField("\(hint)", text: binding)
                .onTapGesture {
                    bindingButton.wrappedValue = hint == "Найти локацию" ? true : false
                }
        })
        .padding(.vertical, 12)
        .padding(.horizontal)
        .background{
            RoundedRectangle(cornerRadius: 10, style: .continuous)
                .strokeBorder(.gray)
        }
        .padding(.vertical, 5)
    }
    
}

extension SearchView {
    private func DateFieldEvent (
        binding: Binding<Date>
    ) -> some View {
        DatePicker(selection: binding, in: Date()...) {
            Text("Дата начала события")
                .font(.headline)
        }
    }
}
#Preview {
    SearchView()
        .environmentObject(LocationManager())
}

struct MapViewSelection: View {
    @EnvironmentObject var locationManager: LocationManager
    @Environment(\.dismiss) var dismiss
    
    @Binding var showLocations: Bool
    var body: some View {
        ZStack {
            MapViewHelper()
                .environmentObject(locationManager)
                .ignoresSafeArea()
            
            Button (action: {
                dismiss()
            }, label: {
                Image (systemName: "chevron.left")
                    .font(.title2.bold())
                    .foregroundStyle(Color.primary)
            })
            .padding()
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
            
            if let place = locationManager.pickedPlaceMark {
                VStack (spacing: 15, content: {
                    Text("Подтвердите локацию")
                        .font(.title2.bold())
                    
                    HStack(spacing: 15, content: {
                        Image(systemName: "mappin.circle.fill")
                            .font(.title2)
                            .foregroundStyle(.gray)
                        
                        VStack(alignment: .leading, spacing: 6, content: {
                            Text(place.name ?? "")
                                .font(.title3.bold())
                            
                            Text(place.locality ?? "")
                                .font(.caption)
                                .foregroundStyle(.gray)
                        })
                    })
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.vertical, 10)
                    
                    Button(action: {
                        locationManager.searchText = place.name ?? ""
                        showLocations = false
                        
                        // здесь отправка локации
                        locationManager.latitude = (place.location?.coordinate.latitude)!
                        locationManager.longtitude = (place.location?.coordinate.longitude)!
                        dismiss()
                        
                        
                    }, label: {
                        Text("Подтвердить локацию")
                            .fontWeight(.semibold)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 12)
                            .background{
                                RoundedRectangle (cornerRadius: 10, style: .continuous)
                                    .fill(Color.green)
                            }
                            .overlay(alignment: .trailing) {
                                Image(systemName: "arrow.right")
                                    .font(.title3.bold())
                                    .padding(.trailing)
                            }
                            .foregroundStyle(Color.white)
                    })
                })
                .padding()
                .background{
                    RoundedRectangle(cornerRadius: 10, style: .continuous)
                        .fill(.white)
                        .ignoresSafeArea()
                }
                .frame(maxHeight: .infinity, alignment: .bottom)
            }
        }
        .onDisappear(perform: {
            locationManager.pickedLocation = nil
            locationManager.pickedPlaceMark = nil
            
            locationManager.mapView.removeAnnotations(locationManager.mapView.annotations)
        })
    }
    
}

struct MapViewHelper: UIViewRepresentable{
    @EnvironmentObject var locationManager: LocationManager
    
    func makeUIView(context: Context) -> MKMapView {
        return locationManager.mapView
    }
    
    func updateUIView(_ uiView: MKMapView, context: Context) {}
}


