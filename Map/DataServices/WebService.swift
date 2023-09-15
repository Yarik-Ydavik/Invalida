//
//  WebService.swift
//  Map
//
//  Created by Yaroslav Zagumennikov on 11.09.2023.
//

import Foundation

enum AuthenticationError: Error{
    case invalidCredentials
    case custom(errorMessage: String)
}

struct LoginRequestBody: Codable {
    let email: String
    let passwordHash: String
}

// Ответ от сервера одинаковый при регистрации и авторизации
struct LoginResponse: Codable {
    let accessToken: String
    let refreshToken: String
}

struct RegisterRequestBody: Codable {
    let name: String
    let surname: String
    let patronymic: String
    let email: String
    let role: Int
    let disease: String
    let passwordHash: String
}

class WebService {
    func login (username: String, password: String, completion: @escaping (Result<LoginResponse, AuthenticationError>) -> Void) {
        
        guard let url = URL(string: "http://localhost:9090/api/signin") else {
            completion(.failure(.custom(errorMessage: "URL не корректно")))
            return
        }
        
        let body = LoginRequestBody(email: username, passwordHash: password)
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = try? JSONEncoder().encode(body)
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            guard let data = data, error == nil else {
                completion(.failure(.custom(errorMessage: "No data")))
                return
            }
            
            guard let loginResponse = try? JSONDecoder().decode(LoginResponse.self, from: data) else {
                completion(.failure(.invalidCredentials))
                return
            }
            
//            guard let token = loginResponse.accessToken else {
//                completion(.failure(.invalidCredentials))
//                return
//            }
            
            completion(.success(loginResponse))
            
        }.resume()
    }
    
    func registration (
        name: String,
        surname: String,
        patronymic: String,
        email: String,
        role: Int,
        disease: String,
        passwordHash: String,
        completion: @escaping (Result<LoginResponse, AuthenticationError>) -> Void) {
        
        guard let url = URL(string: "http://localhost:9090/api/signup") else {
            completion(.failure(.custom(errorMessage: "URL не корректно")))
            return
        }
        
        let body = RegisterRequestBody(
            name: name,
            surname: surname,
            patronymic: patronymic,
            email: email,
            role: role,
            disease: disease,
            passwordHash: passwordHash
        )
            
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = try? JSONEncoder().encode(body)
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            guard let data = data, error == nil else {
                completion(.failure(.custom(errorMessage: "No data")))
                return
            }
            
            guard let loginResponse = try? JSONDecoder().decode(LoginResponse.self, from: data) else {
                completion(.failure(.invalidCredentials))
                return
            }
            
//            guard let token = loginResponse.accessToken else {
//                completion(.failure(.invalidCredentials))
//                return
//            }
            
            completion(.success(loginResponse))
            
        }.resume()
    }
}
