//
//  CurrencyConvertorHistoryCoordinator.swift
//  MultiCurrencyConversionInterface-Legacy
//
//  Created by John Kuan on 29/5/20.
//  Copyright © 2020 JohnKuan. All rights reserved.
//

import Foundation

import UIKit

protocol CurrencyConvertorHistoryCoordinator: class {}

class CurrencyConvertorHistoryCoordinatorImplementation: Coordinator {
    unowned let navigationController: UINavigationController
    
    init(navigationController: UINavigationController) {
        self.navigationController = navigationController
    }
    
    func start() {
        let ccHViewController = CurrencyConversionHistoryViewController()
        let cchViewModel = CurrencyConversionHistoryViewModel(coordinator: self)
        ccHViewController.viewModel = cchViewModel
        
        navigationController.pushViewController(ccHViewController,
                                                animated: true)
    }
}

extension CurrencyConvertorHistoryCoordinatorImplementation: CurrencyConvertorHistoryCoordinator {}
