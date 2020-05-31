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

class MockExchangeRateAPIService: IExchangeRateAPIService {
    func loadCurrencyRateWithFromAndToSelected(from: String, to: String) -> Observable<Result<CurrencyRateModel, Error>> {
        let urlString = ExchangeRateAPIService.exchangeURL + "?base=" + from + "&symbols=" + to
        return loadCurrencyRates(urlString: urlString)
    }
    
    func loadCurrencyRatesWithBase(base: String) -> Observable<Result<CurrencyRateModel, Error>> {
        let urlString = ExchangeRateAPIService.exchangeURL + "?base=\(base)"
        return loadCurrencyRates(urlString: urlString)
    }
    
    func loadCurrencyRates(urlString: String) -> Observable<Result<CurrencyRateModel, Error>> {
        let test = "{\"rates\":{\"CAD\":1.528,\"HKD\":8.6347,\"ISK\":150.8,\"PHP\":56.231,\"DKK\":7.4542,\"HUF\":348.73,\"CZK\":26.921,\"AUD\":1.6681,\"RON\":4.8493,\"SEK\":10.487,\"IDR\":16269.7,\"INR\":84.1025,\"BRL\":5.9654,\"RUB\":78.4416,\"HRK\":7.587,\"JPY\":119.29,\"THB\":35.424,\"CHF\":1.072,\"SGD\":1.5712,\"PLN\":4.4495,\"BGN\":1.9558,\"TRY\":7.6101,\"CNY\":7.9456,\"NOK\":10.788,\"NZD\":1.7863,\"ZAR\":19.4239,\"USD\":1.1136,\"MXN\":24.57,\"ILS\":3.9065,\"GBP\":0.90088,\"KRW\":1376.21,\"MYR\":4.8414},\"base\":\"EUR\",\"date\":\"2020-05-29\"}"
        let data = Data(test.utf8) 
        let model = try! JSONDecoder().decode(CurrencyRateModel.self, from: data)
        return Observable.just(.success(model))
    }
}
