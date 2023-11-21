//
//  LoginRequest.swift
//  Map
//
//  Created by Yaroslav Zagumennikov on 19.09.2023.
//

import Foundation

struct LoginRequestBody: Codable {
    let email: String
    let passwordHash: String
}
