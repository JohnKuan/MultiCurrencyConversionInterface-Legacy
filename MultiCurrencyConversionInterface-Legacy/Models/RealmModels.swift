//
//  RealmModels.swift
//  MultiCurrencyConversionInterface-Legacy
//
//  Created by John Kuan on 29/5/20.
//  Copyright © 2020 JohnKuan. All rights reserved.
//

import Realm
import RealmSwift

// CurrencyRate model
@objcMembers class CurrencyRate: Object, Decodable {
    
    @objc dynamic var base = ""
    @objc dynamic var date: String = ""
    @objc private dynamic var dictionaryData: Data? = nil
    @objc dynamic var rates: [String: Double] {
        get {
            guard let dictionaryData = dictionaryData else {
                return [String: Double]()
            }
            do {
                let dict = try JSONSerialization.jsonObject(with: dictionaryData, options: []) as? [String: Double]
                return dict!
            } catch {
                return [String: Double]()
            }
        }

        set {
            do {
                let data = try JSONSerialization.data(withJSONObject: newValue, options: [])
                dictionaryData = data
            } catch {
                dictionaryData = nil
            }
        }
    }
    
    private enum CodingKeys: String, CodingKey {
        case base
        case date
        case rates
    }
    
    public required convenience init(from decoder: Decoder) throws {
        self.init()
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.base = try container.decode(String.self, forKey: .base)
        self.date = try container.decode(String.self, forKey: .date)
        self.rates = try container.decode([String: Double].self, forKey: .rates)
    }
    
    override static func primaryKey() -> String?
    {
        return "base"
    }
}

// CurrencyRate model
@objcMembers class ExchangeItemHistory: Object, Decodable {
    @objc dynamic var transactionID = UUID().uuidString
    @objc dynamic var date: Date = Date()
    @objc dynamic var transactionAmount: String = ""
    @objc dynamic var transactionRate: String = ""
    
    
    private enum CodingKeys: String, CodingKey {
        case transactionID
        case date
        case transactionAmount
        case transactionRate
    }
    
    public required convenience init(from decoder: Decoder) throws {
        self.init()
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.transactionID = try container.decode(String.self, forKey: .transactionID)
        self.date = try container.decode(Date.self, forKey: .date)
        self.transactionAmount = try container.decode(String.self, forKey: .transactionAmount)
        self.transactionRate = try container.decode(String.self, forKey: .transactionRate)
    }
    
    override static func primaryKey() -> String?
    {
        return "transactionID"
    }
}


class Wallet: Object, Decodable {
    @objc dynamic var walletId: String = ""
    @objc dynamic var updatedDate: Date = Date()
    var currencies: List<Currency> = List<Currency>()

    private enum CodingKeys: String, CodingKey {
        case walletId
        case updatedDate
        case currencies
    }
    
    public required convenience init(from decoder: Decoder) throws {
        self.init()
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.walletId = try container.decode(String.self, forKey: .walletId)
        self.updatedDate = try container.decode(Date.self, forKey: .updatedDate)
        let cur = try container.decodeIfPresent([Currency].self, forKey: .currencies) ?? [Currency()]
        currencies.append(objectsIn: cur)
    }
    
    override static func primaryKey() -> String?
    {
        return "walletId"
    }
}

@objcMembers class Currency: Object, Decodable {
    dynamic var currencyId: String = ""
    dynamic var balance: Double = 0
    
    private enum CodingKeys: String, CodingKey {
        case currencyId
        case balance
    }
    
    override static func primaryKey() -> String? {
        return "currencyId"
    }
    public required convenience init(from decoder: Decoder) throws {
        self.init()
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.currencyId = try container.decode(String.self, forKey: .currencyId)
        self.balance = try container.decode(Double.self, forKey: .balance)
       
    }
}


