//
//  AlertModel.swift
//  Giphy
//
//  Created by Арсений Убский on 16.01.2023.
//

import Foundation

struct AlertModel {
    let title: String
    let message: String
    let buttonText: String
    let completion: ()-> Void
}
