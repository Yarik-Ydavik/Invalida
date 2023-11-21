//
//  AuthView.swift
//  Map
//
//  Created by Yaroslav Zagumennikov on 12.09.2023.
//

import SwiftUI

struct AuthView: View {
    @EnvironmentObject private var loginVM : UserViewModel
    
    var body: some View {
        NavigationStack {
            ZStack{
                Color(UIColor.secondarySystemBackground)
                    .ignoresSafeArea()
                Form {
                    HStack{
                        Spacer()
                        Text("Авторизация")
                        Spacer()
                        Image(systemName: loginVM.isAuthentificated ? "lock.open" : "lock.fill")
                    }
                    TextField("Почта", text: $loginVM.email)
                    SecureField("Пароль", text: $loginVM.passwordHash)
                    HStack (alignment: .center){
                        Spacer()
                        Button("Войти") {
                            loginVM.login()
                        }
                        .navigationDestination(isPresented: $loginVM.isAuthentificated) {
                            EventView()
                        }
                        .tint(.black)
                        
                        Spacer()
                        
                    }
                    NavigationLink("Нет аккаунта?") {
                        RegisterView()
                    }
                }
                .frame(height: 280)
                .scrollDisabled(true)
            }
        }
        
    }
}

#Preview {
    AuthView()
        .environmentObject(UserViewModel())
}
