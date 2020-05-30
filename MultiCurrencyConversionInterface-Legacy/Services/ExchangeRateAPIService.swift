//
//  ExchangeRateAPIService.swift
//  MultiCurrencyConversionInterface-Legacy
//
//  Created by John Kuan on 28/5/20.
//  Copyright © 2020 JohnKuan. All rights reserved.
//

import RxSwift

protocol IExchangeRateAPIService {
    func loadCurrencyRateWithFromAndToSelected(from: String, to: String) -> Observable<Result<CurrencyRateModel, Error>>
    func loadCurrencyRatesWithBase(base: String) -> Observable<Result<CurrencyRateModel, Error>>
    func loadCurrencyRates(urlString: String) -> Observable<Result<CurrencyRateModel, Error>>
}

class ExchangeRateAPIService: IExchangeRateAPIService {
    static let exchangeURL: String = "https://api.exchangeratesapi.io/latest"
    private let networkClient = NetworkClient(baseUrlString: ExchangeRateAPIService.exchangeURL)
    
    func loadCurrencyRateWithFromAndToSelected(from: String, to: String) -> Observable<Result<CurrencyRateModel, Error>> {
        let urlString = ExchangeRateAPIService.exchangeURL + "?base=" + from + "&symbols=" + to
        return loadCurrencyRates(urlString: urlString)
    }
    
    func loadCurrencyRatesWithBase(base: String) -> Observable<Result<CurrencyRateModel, Error>> {
        let urlString = ExchangeRateAPIService.exchangeURL + "?base=\(base)"
        return loadCurrencyRates(urlString: urlString)
    }
    
    func loadCurrencyRates(urlString: String) -> Observable<Result<CurrencyRateModel, Error>> {
        return self.networkClient.get(CurrencyRateModel.self, urlString, printURL: true)
    }
}
