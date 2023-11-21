//
//  RowLocationsView.swift
//  Map
//
//  Created by Yaroslav Zagumennikov on 01.07.2023.
//

import SwiftUI

struct RowLocationsView: View {
    @EnvironmentObject private var vm : LocationManager

    var body: some View {
        List{
            ForEach(vm.locations) { location in
                Button {
                    vm.nextLocations(location: location)
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
            .environmentObject(LocationManager())
    }
}

extension RowLocationsView {
    private func RowLocation (location : CreateEventResponse) -> some View {
        return HStack{
            if let Imagr = vm.eventImages[location.id] {
                Image(uiImage: Imagr)
                    .resizable()
                    .scaledToFill()
                    .frame(width: 45, height: 45)
                    .cornerRadius(10)
            } else {
                Image("image")
                    .resizable()
                    .scaledToFill()
                    .frame(width: 45, height: 45)
                    .cornerRadius(10)
            }
            VStack (alignment: .leading) {
                Text(location.name)
                    .font(.headline)
                Text(vm.eventAddress[location.id]?.name ??  location.cityName)
                    .lineLimit(1)
                    .font(.subheadline)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
    }
}


