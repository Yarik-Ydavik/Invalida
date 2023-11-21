//
//  RegisterRequest.swift
//  Map
//
//  Created by Yaroslav Zagumennikov on 19.09.2023.
//

import Foundation

struct RegisterRequestBody: Codable {
    let name: String
    let surname: String
    let patronymic: String
    let email: String
    let role: Int
    let disease: String
    let passwordHash: String
}
