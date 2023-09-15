//
//  MarkerView.swift
//  Map
//
//  Created by Yaroslav Zagumennikov on 04.07.2023.
//

import SwiftUI

struct MarkerView: View {
    var body: some View {
        VStack (spacing: 0){
            Image(systemName: "map.circle")
                .resizable()
                .scaledToFit()
                .frame(width: 30, height: 30)
                .foregroundColor(.accentColor)
                .background(.white)
                .clipShape(/*@START_MENU_TOKEN@*/Circle()/*@END_MENU_TOKEN@*/)
            
            Image(systemName: "arrowtriangle.down.fill")
                .resizable()
                .scaledToFit()
                .frame( height: 10)
                .foregroundColor(.accentColor)
                .offset(y: -3)
        }
        .padding(.bottom, 30)
    }
}

#Preview {
    MarkerView()
}
