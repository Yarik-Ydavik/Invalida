//
//  ProfileView.swift
//  Map
//
//  Created by Yaroslav Zagumennikov on 23.09.2023.
//

import SwiftUI

struct ProfileView: View {
    @EnvironmentObject var vmLogi : UserViewModel
    
    var body: some View {
        VStack {
            Button("Выйти из аккаунта") {
                vmLogi.delitUser()
            }
        }
        
    }
}

#Preview {
    ProfileView()
}
