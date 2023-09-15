//
//  MapApp.swift
//  Map
//
//  Created by Yaroslav Zagumennikov on 30.06.2023.
//

import SwiftUI

@main
struct MapApp: App {
    
    @StateObject private var vm = LocationViewModel()
    @StateObject private var vmLogi = LoginViewModel()
    
    @AppStorage("tokenAuth") var token: String?
        
    var body: some Scene {
        WindowGroup {
            if token != nil {
                EventView()
                    .environmentObject(vm)
            } else {
                AuthView()
                    .environmentObject(vmLogi)
            }
        }
    }

}
