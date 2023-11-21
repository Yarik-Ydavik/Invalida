//
//  RegisterView.swift
//  Map
//
//  Created by Yaroslav Zagumennikov on 15.09.2023.
//

import SwiftUI

struct RegisterView: View {
    @Environment(\.presentationMode) var presentationMode
    @EnvironmentObject private var loginVM : UserViewModel
    
    @State var rol: String = "Роль"
    
    var body: some View {
        ZStack{
            Color(UIColor.secondarySystemBackground)
                .ignoresSafeArea()
            Form {
                HStack{
                    Spacer()
                    Text("Регистрация")
                    Spacer()
                    Image(systemName: loginVM.isAuthentificated ? "lock.open" : "lock.fill")
                }
                TextField("Имя", text: $loginVM.name)
                TextField("Фамилия", text: $loginVM.surname)
                TextField("Отчество", text: $loginVM.patronymic)

                Menu {
                    Button("Родитель") {
                        rol = "Родитель"
                        loginVM.role = 0
                    }
                    Button("Ребёнок") {
                        rol = "Ребёнок"
                        loginVM.role = 1
                    }
                    Button("Волонтёр") {
                        rol = "Волонтёр"
                        loginVM.role = 2
                    }
                    Button("Организация") {
                        rol = "Организация"
                        loginVM.role = 3
                    }
                } label: {
                    Text(rol)
                        .tint(.black)
                        .frame(width: UIScreen.main.bounds.width/2, alignment: .leading)
                        
                }

                TextField("Почта", text: $loginVM.email)
                SecureField("Пароль", text: $loginVM.passwordHash)
                HStack (alignment: .center){
                    Spacer()
                    Button("Войти") {
                        loginVM.registration()
                    }
                    .navigationDestination(isPresented: $loginVM.isAuthentificated) {
                        EventView()
                    }
                    .tint(.black)
                    
                    Spacer()
                    
                }

            }
            .frame(height: 400)
            .scrollDisabled(true)
        }
        .navigationBarBackButtonHidden(true)
        .navigationBarItems(leading:
            Button(action:{self.presentationMode.wrappedValue.dismiss()}) {
                HStack {
                    Image(systemName: "arrow.left") // set image here
                    .aspectRatio(contentMode: .fit)
                    Text("Авторизация")
                }
            }
        )
    }
}

#Preview {
    RegisterView()
        .environmentObject(UserViewModel())

}
