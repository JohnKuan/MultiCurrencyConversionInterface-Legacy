//
//  MultiCurrencyConversionInterface_LegacyTests.swift
//  MultiCurrencyConversionInterface-LegacyTests
//
//  Created by John Kuan on 28/5/20.
//  Copyright © 2020 JohnKuan. All rights reserved.
//

import XCTest
@testable import MultiCurrencyConversionInterface_Legacy

class MultiCurrencyConversionInterface_LegacyTests: XCTestCase {

    
    
    
    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testExample() throws {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
        let viewModel = TestCurrencyConversionViewModel()
    }

    func testPerformanceExample() throws {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }

}
