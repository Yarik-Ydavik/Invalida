//
//  RowLocationsView.swift
//  Map
//
//  Created by Yaroslav Zagumennikov on 01.07.2023.
//

import SwiftUI

struct RowLocationsView: View {
    @EnvironmentObject private var vm : LocationViewModel
    
    var body: some View {
        List{
            ForEach(vm.locations) { location in
                Button {
                    vm.nextLocations(locations: location)
                } label: {
                    RowLocation(location: location)
                }
                .padding(.vertical, 4)
                .listRowBackground(Color.clear)
                
            }
        }.listStyle(.plain)
    }
}

struct RowLocationsView_Previews: PreviewProvider {
    static var previews: some View {
        RowLocationsView()
            .environmentObject(LocationViewModel())
    }
}

extension RowLocationsView {
    private func RowLocation (location : Location) -> some View {
        HStack{
            if let image = location.imageNames.first{
                Image(image)
                    .resizable()
                    .scaledToFill()
                    .frame(width: 45, height: 45)
                    .cornerRadius(10)
                VStack (alignment: .leading) {
                    Text(location.name)
                        .font(.headline)
                    Text(location.cityName)
                        .font(.subheadline)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
            }
        }
    }
}
