//
//  EventOrganizView.swift
//  Map
//
//  Created by Yaroslav Zagumennikov on 23.09.2023.
//

import SwiftUI

struct EventOrganizView: View {
    @StateObject var locManager: LocationManager = .init()
    @EnvironmentObject var vmLogi: UserViewModel
    
    @State private var selection: String? = "home"
    var body: some View {
        TabView (selection: $selection) {
            NavigationStack {
                ListHomeView()
                    .environmentObject(locManager)
                    .navigationTitle("Список мероприятий")
                    .toolbar(content: {
                        ToolbarItem(placement: .topBarTrailing) {
                            NavigationLink(
                                destination:
                                    SearchView()
                                        .environmentObject(locManager)
                                        .navigationBarBackButtonHidden(),
                                label: {
                                    Image(systemName: "plus")
                                }).tint(.black)
                        }
                    })
            }.tabItem {
                Image( systemName: "house")
                Text ("Главная")
            }

            ProfileView()
                .environmentObject(vmLogi)
            .tabItem {
                Image (systemName: "person.crop.square")
                Text ("Профиль")
            }
        }
    }
}

#Preview {
    EventOrganizView()
}
