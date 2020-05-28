//
//  CurrencyConvertorMainCoordinator.swift
//  MultiCurrencyConversionInterface-Legacy
//
//  Created by John Kuan on 28/5/20.
//  Copyright © 2020 JohnKuan. All rights reserved.
//

import UIKit

protocol CurrencyConvertorMainCoordinator: class {
    func pushToHistory()
}

class CurrencyConvertorMainCoordinatorImplementation : Coordinator {
    
    unowned let navigationController: UINavigationController
    
    init(navigationController: UINavigationController) {
        self.navigationController = navigationController
    }
    
    func start() {
        let currencyConvertorViewController = CurrencyConvertorViewController()
        let ccVM = CurrencyConversionViewModel(exchangeRateAPIService: ExchangeRateAPIService(), coordinator: self)
        currencyConvertorViewController.viewModel = ccVM
        navigationController
            .pushViewController(currencyConvertorViewController, animated: true)
    }
}

extension CurrencyConvertorMainCoordinatorImplementation: CurrencyConvertorMainCoordinator {
    
    func pushToHistory() {
        
        
//        coordinate(to: photoDetailCoordinator)
    }
}
