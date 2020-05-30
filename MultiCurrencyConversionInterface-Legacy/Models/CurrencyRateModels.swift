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
    
    private enum CodingKeys: String, CodingKey {
        case base
        case date
        case rates
    }
    init(from decoder: Decoder) throws {
        
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.base = try container.decode(String.self, forKey: .base)
        self.date = try container.decode(String.self, forKey: .date)
        self.rates = try container.decode(Dictionary<String, Double>.self, forKey: .rates)
    }
}



