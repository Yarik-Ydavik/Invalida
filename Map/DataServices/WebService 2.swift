//
//  WebService.swift
//  Map
//
//  Created by Yaroslav Zagumennikov on 11.09.2023.
//

import Foundation
import UIKit

enum AuthenticationError: Error{
    case invalidCredentials
    case custom(errorMessage: String)
}

enum EventError: Error{
    case invalidCredentials
    case custom(errorMessage: String)
}

class WebService {
    func login (
        username: String,
        password: String,
        completion: @escaping (Result<LoginResponse, AuthenticationError>) -> Void
    ) {
        
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
            
            
            completion(.success(loginResponse))
            
        }.resume()
    }
    
    func getProfile(
        Authorization: String,
        completion: @escaping (Result<ProfileRespose, AuthenticationError>) -> Void
    ) {
        guard let url = URL(string: "http://localhost:9090/api/profile") else {
            completion(.failure(.custom(errorMessage: "URL не корректно")))
            return
        }
        
        var request = URLRequest(url: url)
        request.addValue(Authorization, forHTTPHeaderField: "Authorization")
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            guard let data = data, error == nil else {
                completion(.failure(.custom(errorMessage: "Нет данных")))
                return
            }
            
            guard let profileInfo = try? JSONDecoder().decode(ProfileRespose.self, from: data) else {
                completion(.failure(.invalidCredentials))
                return
            }
            
            completion(.success(profileInfo))
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
            
            
            completion(.success(loginResponse))
            
        }.resume()
    }
    
    // Создание события
    func createEvent (
        accessToken: String,
        name: String,
        cityName: String,
        location: locationRequest,
        description: String,
        maxCountPlaces: Int,
        date: String,
        completion: @escaping (Result<CreateEventResponse, EventError>) -> Void
    ) {
        guard let url = URL(string: "http://localhost:9090/api/event") else {
            completion(.failure(.custom(errorMessage: "URL не корректно")))
            return
        }
        
        let body = CreateEventRequest(
            name: name,
            cityName: cityName,
            location: location,
            description: description,
            maxCountPlaces: maxCountPlaces,
            date: date
        )
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue(accessToken, forHTTPHeaderField: "Authorization")
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = try? JSONEncoder().encode(body)
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            guard let data = data, error == nil else {
                completion(.failure(.custom(errorMessage: "No data")))
                return
            }
            
            guard let createEventResponse = try? JSONDecoder().decode(CreateEventResponse.self, from: data) else {
                completion(.failure(.invalidCredentials))
                return
            }
            
            completion(.success(createEventResponse))
            
        }.resume()
    }
    
    // Добавление картинок к событию
    func addImagesToEvent(
        Authorization: String,
        eventId: String,
        fileNames: [String],
        images: [UIImage?],
        completion: @escaping (Result<AddPhotoResponse, EventError>) -> Void
    ) {
        let url = URL(string: "http://localhost:9090/api/upload/events/\(eventId)")!
         
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue(Authorization, forHTTPHeaderField: "Authorization")
         
        let boundary = UUID().uuidString
        request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
         
        let images = images
         
        let body = NSMutableData()
         
        for image in images {
            let imageData = image!.jpegData(compressionQuality: 1)!
            body.append("--\(boundary)\r\n".data(using: .utf8)!)
            body.append("Content-Disposition: form-data; name=\"formFiles\"; filename=\"image.jpg\"\r\n".data(using: .utf8)!)
            body.append("Content-Type: image/jpeg\r\n\r\n".data(using: .utf8)!)
            body.append(imageData)
            body.append("\r\n".data(using: .utf8)!)
        }
         
        body.append("--\(boundary)--\r\n".data(using: .utf8)!)
         
        request.httpBody = body as Data
         
        URLSession.shared.dataTask(with: request) { data, response, error in
            guard let data = data, error == nil else {
                completion(.failure(.custom(errorMessage: "No data")))
                return
            }
            
            guard let getPhotosResponse = try? JSONDecoder().decode(AddPhotoResponse.self, from: data) else {
                completion(.failure(.invalidCredentials))
                return
            }
            
            completion(.success(getPhotosResponse))
            
        }.resume()
    }
    
    
    // Получение событий по городу
    func getEventsCity(
        userCity: String,
        accessToken: String,
        completion: @escaping (Result<[CreateEventResponse], EventError>) -> Void
    ) {
        guard let url = URL(string: "http://localhost:9090/api/events/\(userCity)") else {
            completion(.failure(.custom(errorMessage: "URL не корректно")))
            return
        }
        
        var request = URLRequest(url: url)
        request.addValue(accessToken, forHTTPHeaderField: "Authorization")
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            guard let data = data, error == nil else {
                completion(.failure(.custom(errorMessage: "No data")))
                return
            }
            
            guard let getEventsResponse = try? JSONDecoder().decode([CreateEventResponse].self, from: data) else {
                completion(.failure(.invalidCredentials))
                return
            }
            
            completion(.success(getEventsResponse))
            
        }.resume()
    }
    
    // ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
    // ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
    // ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

    // Запись на событие
    func recordingEvent (
        Authorization: String,
        eventId: String,
        completion: @escaping (Result<String, EventError>) -> Void
    ) {
        guard let url = URL(string: "http://localhost:9090/api/recordingEvent/\(eventId)") else {
            completion(.failure(.custom(errorMessage: "URL не корректно")))
            return
        }
        
        print(url)
        print(Authorization)
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue(Authorization, forHTTPHeaderField: "Authorization")
        request.addValue(eventId, forHTTPHeaderField: "eventId")
        
        URLSession.shared.dataTask(with: request) { data, response, error  in
            guard let data = data, error == nil else {
                completion(.failure(.custom(errorMessage: "No data")))
                return
            }
            
            guard let recodEventResponse = String(data: data , encoding: .utf8) else {
                completion(.failure(.custom(errorMessage: "Непредвиденная ошибка при записи на мероприятие")))
                return
            }
            completion(.success(recodEventResponse))
        }.resume()
    }
    
    
}
