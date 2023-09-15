//
//  LocationPreviewView.swift
//  Map
//
//  Created by Yaroslav Zagumennikov on 02.07.2023.
//

import SwiftUI

struct LocationPreviewView: View {
    @EnvironmentObject private var vm : LocationViewModel
    
    let location: Location
    var body: some View {
        HStack (alignment: .bottom){
            VStack(alignment: .leading, spacing: 16){
                imageLocation
                titleLocation
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            
            VStack (spacing: 8){
                learnMoreButton
                nextButton
            }
            
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 10)
                .fill(.ultraThinMaterial)
                .offset(y: 65)
        )
        .cornerRadius(10)
        .padding()
        
    }
}

struct LocationPreviewView_Previews: PreviewProvider {
    static var previews: some View {
        ZStack {
            Color.blue
                .ignoresSafeArea()
            LocationPreviewView(location:LocationsDataService.locations.first!)
                .environmentObject(LocationViewModel())
        }
    }
}

extension LocationPreviewView{
    private var imageLocation : some View{
        ZStack {
            Image(location.imageNames.first!)
                .resizable()
                .scaledToFill()
                .frame(width: 100, height: 100)
            .cornerRadius(10)
        }
        .padding(6)
        .background(Color.white)
        .cornerRadius(10)
    }
    
    private var titleLocation : some View {
        VStack (alignment: .leading){
            Text(location.name)
                .font(.title3)
                .bold()
            Text(location.cityName)
                .font(.subheadline)
        }
    }
    
    private var learnMoreButton : some View{
        Button {
            
        } label: {
            Text ("Узнать больше")
                .font(.headline)
                .frame(width: 125,height: 35)
        }
        .buttonStyle(.borderedProminent)
    }
    
    private var nextButton : some View{
        Button {
            vm.nextButtonClicked(location : location)
        } label: {
            Text ("Далее")
                .font(.headline)
                .frame(width: 125,height: 35)
        }
        .buttonStyle(.bordered)
    }
}
