//
//  LoginViewModel.swift
//  Map
//
//  Created by Yaroslav Zagumennikov on 12.09.2023.
//

import Foundation

class LoginViewModel: ObservableObject {
    var email: String = ""
    var passwordHash: String = ""
    
    var name: String = ""
    var surname: String = ""
    var patronymic: String = ""
    var role: Int = 0
    var disease: String = ""
    
    @Published var isAuthentificated: Bool = false

    
    func login() {
                
        WebService().login(username: email, password: passwordHash) { result in
            switch result {
                case .success(let tokenInfo):
                    UserDefaults.standard.setValue(tokenInfo.accessToken, forKey: "tokenAuth")
                    UserDefaults.standard.setValue(tokenInfo.refreshToken, forKey: "tokenRefresh")

                    
                    print(tokenInfo.accessToken)
                    print(tokenInfo.refreshToken)
                    DispatchQueue.main.async { [weak self] in
                        self?.isAuthentificated = true
                    }
                case .failure(let error):
                    print("Ошибка")
                    print(error)
            }
        }
    }
    
    func registration() {
        WebService().registration(
            name: name,
            surname: surname,
            patronymic: patronymic,
            email: email,
            role: role,
            disease: disease,
            passwordHash: passwordHash) { result in
                switch result {
                    case .success(let tokenInfo):
                        UserDefaults.standard.setValue(tokenInfo.accessToken, forKey: "tokenAuth")
                        UserDefaults.standard.setValue(tokenInfo.refreshToken, forKey: "tokenRefresh")

                        
                        print(tokenInfo.accessToken)
                        print(tokenInfo.refreshToken)
                        DispatchQueue.main.async { [weak self] in
                            self?.isAuthentificated = true
                        }
                    case .failure(let error):
                        print("Ошибка")
                        print(error)
                }
            }
    }
}
