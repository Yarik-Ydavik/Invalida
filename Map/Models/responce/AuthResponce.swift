//
//  AuthResponce.swift
//  Map
//
//  Created by Yaroslav Zagumennikov on 19.09.2023.
//

import Foundation

// Ответ от сервера одинаковый при регистрации и авторизации
struct LoginResponse: Codable {
    let accessToken: String
    let refreshToken: String
}
