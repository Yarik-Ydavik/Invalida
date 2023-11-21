//
//  UserRecordView.swift
//  Map
//
//  Created by Yaroslav Zagumennikov on 25.09.2023.
//

import SwiftUI

struct UserRecordView: View {
    @EnvironmentObject private var vm : LocationManager
    
    @Environment(\.dismiss) var dismiss
    var location : CreateEventResponse
    var body: some View {
        
        ZStack {
            VStack (alignment: .center) {
                Button("Записаться на мероприятие") {
                    vm.recordOnEvent(eventId: location.id)
                    dismiss()
                }
            }
        }
    }
}

#Preview {

    UserRecordView( location: CreateEventResponse(
        id: "",
        name: "",
        cityName: "",
        location: locationRequest(latitude: 0, longitude: 0),
        description: "",
        date: "",
        maxCountPlaces: 0,
        currentCountPlaces: 0,
        images: [""]
    ) )
        
}
