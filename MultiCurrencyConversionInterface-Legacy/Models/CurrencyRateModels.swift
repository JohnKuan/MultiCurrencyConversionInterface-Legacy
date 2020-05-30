//
//  CurrencyRateModels.swift
//  MultiCurrencyConversionInterface-Legacy
//
//  Created by John Kuan on 28/5/20.
//  Copyright © 2020 JohnKuan. All rights reserved.
//

import Foundation

struct CurrencyRateModel : Codable {
    let base: String
    let date: String
    let rates: Dictionary<String, Double>
}



