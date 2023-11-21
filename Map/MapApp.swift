//
//  MapApp.swift
//  Map
//
//  Created by Yaroslav Zagumennikov on 30.06.2023.
//

import SwiftUI

@main
struct MapApp: App {
    
    @StateObject private var vmLogi = UserViewModel()
    
    var body: some Scene {
        WindowGroup {
            if vmLogi.tokensAuthorization.first?.accessToken != nil {
                if vmLogi.tokensAuthorization.first?.role == 3 {
                    EventOrganizView()
                        .environmentObject(vmLogi)
                }else {
                    EventView()
                        .environmentObject(vmLogi)
                }
            } else {
                AuthView()
                    .environmentObject(vmLogi)
            }

            
        }
    }

}
