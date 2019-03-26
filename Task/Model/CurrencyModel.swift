//
//  CurrencyModel.swift
//  Task
//
//  Created by Hemaraju MacMini on 25/03/19.
//  Copyright © 2019 incipio. All rights reserved.
//

import Foundation
struct CurrencyModel: Codable {
    let base: String?
    let rates: [String: Double]
    let date: String?
}

