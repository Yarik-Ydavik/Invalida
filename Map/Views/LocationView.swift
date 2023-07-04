//
//  LocationView.swift
//  Map
//
//  Created by Yaroslav Zagumennikov on 01.07.2023.
//

import SwiftUI
import MapKit

struct LocationView: View {
    @EnvironmentObject private var vm : LocationViewModel
    var body: some View {
        ZStack{
    
            Map(
                coordinateRegion: $vm.mapRegion,
                annotationItems: vm.locations,
                annotationContent: { Location in
                    MapAnnotation(coordinate: Location.coordinates) {
                        MarkerView()
                            .scaleEffect(Location.id == vm.mapLocation.id ? 1.5 : 1.0)
                    }
                }
            )
                .edgesIgnoringSafeArea(.all)
            
            VStack(spacing: 0) {
                header
                    .padding()
                Spacer()
                
                ZStack {
                    LocationPreviewView(location: vm.mapLocation)
                        .shadow(color: Color.black.opacity(0.3), radius: 20)
                }
            }
        }
    }
}

struct LocationView_Previews: PreviewProvider {
    static var previews: some View {
        LocationView()
            .environmentObject(LocationViewModel())
    }
}

extension LocationView {
    
    private var header : some View{
        VStack {
            
            Button {
                vm.showLocationsList()
            } label: {
                Text(vm.mapLocation.name + ", " + vm.mapLocation.cityName)
                    .font(.title2)
                    .bold()
                    .foregroundColor(.primary)
                    .frame(height: 55)
                    .frame(maxWidth: .infinity)
                    .animation(.none, value: vm.mapLocation)
                    .overlay(alignment: .leading) {
                        Image(systemName: "arrow.down")
                            .font(.headline)
                            .foregroundColor(.primary)
                            .bold()
                            .rotationEffect(Angle(degrees: vm.showLocations ? 180 : 0))
                            .padding()
                    }
            }
            if vm.showLocations{
                RowLocationsView()
            }
        }
        .background(.thickMaterial)
        .cornerRadius(15)
        .shadow(color: Color.black.opacity(0.3), radius: 15, x: 0, y: 15)
        
    }
    
}
