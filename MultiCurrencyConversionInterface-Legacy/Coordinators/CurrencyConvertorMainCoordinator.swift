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
    func pushToConvert()
    func showAlert(convertString: String, completion: @escaping () -> ())
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
//        let currencyConvertorViewController = CurrencyConvertorViewController()
//        let ccVM = CurrencyConversionViewModel(exchangeRateAPIService: ExchangeRateAPIService(), coordinator: self)
//        currencyConvertorViewController.viewModel = ccVM
//        navigationController
//            .pushViewController(currencyConvertorViewController, animated: true)
//        
////        coordinate(to: photoDetailCoordinator)
//        
        let historyPageCoordinator = CurrencyConvertorHistoryCoordinatorImplementation(
            navigationController: navigationController)
        coordinate(to: historyPageCoordinator)
        
    }
    
    func pushToConvert() {
        self.pushToHistory()
    }
    
    func showAlert(convertString: String, completion: @escaping () -> ()) {
        let alert = UIAlertController(title: "Confirm", message: "Are you sure you want to convert \(convertString)? ", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "No", style: .default, handler: { _ in
            //Cancel Action
        }))
        alert.addAction(UIAlertAction(title: "Yes",
                                      style: .default,
                                      handler: {(_: UIAlertAction!) in
                                        //Sign out action
                                        print("Yes")
                                        completion()
        }))
        self.navigationController.present(alert, animated: true, completion: nil)
    }
}
