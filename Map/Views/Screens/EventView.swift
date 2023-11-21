//
//  EventView.swift
//  Map
//
//  Created by Yaroslav Zagumennikov on 10.09.2023.
//

import SwiftUI
import MapKit
import CoreLocation

struct EventView: View {
    @StateObject var locManager: LocationManager = .init()
    
    @State private var selection: String? = "home"
    
    @EnvironmentObject var vmLogi: UserViewModel
    var body: some View {
        
        TabView (selection: $selection) {
            NavigationStack {
                VStack{
                    if !locManager.locations.isEmpty{
                        if !locManager.planet {
                            ListHomeView()
                                .environmentObject(locManager)
                                .navigationTitle("Список мероприятий")
                        } else {
                            LocationView()
                                .environmentObject(locManager)
                        }
                    } else {
                        ListHomeView()
                            .environmentObject(locManager)
                            .navigationTitle("Список мероприятий")
                    }
                    
                }
                .overlay(alignment: .topTrailing) {
                    Image(systemName: locManager.planet ? "globe.americas.fill" : "globe.americas" )
                        .padding()
                        .font(.title3)
                        .bold()
                        .foregroundColor(.primary)
                        .background(.thickMaterial)
                        .cornerRadius(15)
                        .padding()
                        .onTapGesture {
                            withAnimation {
                                if !locManager.locations.isEmpty {
                                    locManager.planet.toggle()

                                }
                            }
                        }
                        .shadow(color: locManager.planet ? Color.black.opacity(0.3) : Color.clear, radius: 15, x: 10, y: 15)
                }
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
        .onAppear(){
             UITabBar.appearance().backgroundColor = .white
        }
        
    }
}
#Preview {
    EventView()
        .environmentObject(LocationManager())
}
