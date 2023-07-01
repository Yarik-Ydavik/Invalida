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
    
    var body: some Scene {
        WindowGroup {
            LocationView()
                .environmentObject(vm)
        }
    }
}
