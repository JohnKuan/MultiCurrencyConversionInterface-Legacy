//
//  CurrencyServiceTest.swift
//  MultiCurrencyConversionInterface-LegacyTests
//
//  Created by John Kuan on 30/5/20.
//  Copyright © 2020 JohnKuan. All rights reserved.
//

import XCTest
import RxSwift
import RxCocoa
import RxTest
@testable import MultiCurrencyConversionInterface_Legacy

class CurrencyServiceTest: XCTestCase {
    
//    var observer: PublishRelay<Result<CurrencyRateModel, Error>>!
    var disposeBag: DisposeBag!
    var scheduler: TestScheduler!
    
    let exchangeRateAPIService: IExchangeRateAPIService = MockExchangeRateAPIService()
    override func setUp() {
        super.setUp()
        self.scheduler = TestScheduler(initialClock: 0)
//        self.observer = PublishRelay<Result<CurrencyRateModel, Error>>()
        self.disposeBag = DisposeBag()

    }
    
    func testRequest() {
        
        let request = scheduler.createObserver(Result<CurrencyRateModel, Error>.self)
        exchangeRateAPIService.loadCurrencyRates(urlString: ExchangeRateAPIService.exchangeURL).bind(to: request).disposed(by: disposeBag)
//        scheduler.start()
          
        XCTAssert(request.events.count > 0, "Expected something")
    }
}
