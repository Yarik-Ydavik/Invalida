//
//  LoginViewModel.swift
//  Map
//
//  Created by Yaroslav Zagumennikov on 12.09.2023.
//

import Foundation
import CoreData

class UserViewModel: ObservableObject {
    let container: NSPersistentContainer
    @Published var tokensAuthorization: [UserTokens] = []
        
    var email: String = ""
    var passwordHash: String = ""
    
    var name: String = ""
    var surname: String = ""
    var patronymic: String = ""
    var role: Int = 0
    var disease: String = ""
    
    @Published var isAuthentificated: Bool = false

    init() {
        container = NSPersistentContainer(name: "UserTokens")
        container.loadPersistentStores { description, error in
            if let error = error {
                print("Failed load data: \(error)")
            }
        }
        loadTokens()
    }
    
    func login() {
                
        WebService().login(username: email, password: passwordHash) { result in
            switch result {
                case .success(let tokenInfo):
                    let tokens = UserTokens(context: self.container.viewContext)
                    tokens.accessToken = tokenInfo.accessToken
                    tokens.refreshToken = tokenInfo.refreshToken
                    
                    DispatchQueue.main.async { [weak self] in
                        self?.getProfileInfo( user: tokens )
                    }
                case .failure(let error):
                    print("Ошибка")
                    print(error)
            }
        }
    }
    
    func getProfileInfo (user: UserTokens){
        WebService().getProfile(Authorization: user.accessToken!) { result in
            switch result {
            case .success(let success):
                switch success.role {
                    case "Child": user.role = 0
                    case "Parent": user.role = 1
                    case "Volunteer" : user.role = 2
                    case "CommercialOrganization": user.role = 3
                default:
                    print("Нет такого типа")
                }
                DispatchQueue.main.async { [weak self] in
                    self?.saveData()
                    self?.isAuthentificated = true
                }
            case .failure(let failure):
                print("Ошибка")
                print(failure)
            }
        }
    }
    
    // Сохранение токенов в базе данных системы
    func saveData() {
        do {
            try container.viewContext.save()
            loadTokens()
        } catch let error {
            print("Error save data: \(error)")
        }
    }
    // Загрузка токенов из базе данных системы
    func loadTokens(){
        let request = NSFetchRequest<UserTokens>(entityName: "UserTokens")
        do {
           tokensAuthorization = try container.viewContext.fetch(request)
        } catch let error {
            print("Error fetch tokens: \(error)")
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
                        let tokens = UserTokens(context: self.container.viewContext)
                        tokens.accessToken = tokenInfo.accessToken
                        tokens.refreshToken = tokenInfo.refreshToken
                        tokens.role = Int32(self.role)
                    
                        DispatchQueue.main.async { [weak self] in
                            self?.saveData()
                            self?.isAuthentificated = true
                        }
                    case .failure(let error):
                        print("Ошибка")
                        print(error)
                }
            }
    }
    
    
    func delitUser () {
        let fetchRequest: NSFetchRequest<NSFetchRequestResult> = NSFetchRequest(entityName: "UserTokens")
        let deleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)

        do {
            try self.container.viewContext.execute(deleteRequest)
            try self.container.viewContext.save()
            loadTokens() // обновляем список токенов после удаления
            isAuthentificated = false // сбрасываем флаг аутентификации

        } catch let error as NSError {
            print("Error: \(error.localizedDescription)")
        }

        saveData()
    }
    
}
