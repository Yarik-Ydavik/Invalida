//
//  ProfileRespose.swift
//  Map
//
//  Created by Yaroslav Zagumennikov on 25.09.2023.
//

import Foundation

struct ProfileRespose: Codable {
    let name: String
    let surname: String
    let patronymic: String
    let email: String
    let role: String
    let urlIcon: String
}
