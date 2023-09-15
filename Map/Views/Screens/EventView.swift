//
//  EventView.swift
//  Map
//
//  Created by Yaroslav Zagumennikov on 10.09.2023.
//

import SwiftUI

struct EventView: View {
    @EnvironmentObject private var vm : LocationViewModel
    @State private var selection: String = "home"
    @State private var planet: Bool = true

    
    var body: some View {
        
        TabView (selection: $selection) {
            NavigationStack {
                VStack{
                    if planet {
                        RowLocationsView()
                            .navigationTitle("Список мероприятий")
                    } else {
                        LocationView(planet: $planet)
                            .navigationTitle("")
                    }
                }
                .overlay(alignment: .topTrailing) {
                    Button {
                        planet.toggle()
                    } label: {
                        Image(systemName: planet ? "globe.americas" : "globe.americas.fill")
                            .padding()
                            .font(.title2)
                            .bold()
                            .foregroundColor(.primary)
                            .background(.thickMaterial)
                            .cornerRadius(15)
                            .padding()
                    }
                }
            }.tabItem {
                Image( systemName: "house")
                Text ("Главная")
            }
            
            Color.white
                .ignoresSafeArea(edges: .top)
                .tabItem {
                    Image( systemName: "person")
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
        .environmentObject(LocationViewModel())
}
