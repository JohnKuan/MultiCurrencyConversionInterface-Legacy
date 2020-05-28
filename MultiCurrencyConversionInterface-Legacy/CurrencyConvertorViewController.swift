//
//  CurrencyConvertorViewController.swift
//  MultiCurrencyConversionInterface-Legacy
//
//  Created by John Kuan on 28/5/20.
//  Copyright © 2020 JohnKuan. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import RxBiBinding
import DropDown

class CurrencyConvertorViewController: UIViewController {

    // MARK: - Properties
    private let disposeBag = DisposeBag()
    var viewModel: CurrencyConversionViewModel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        setupUI()
        bindRatesLabel()
        
        viewModel.viewDidLoad.accept(())
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setupNavigationBar()
        setupNavigationItem()
    }
    
    lazy var fromCardComponent: CurrencyInputCard = {
        let view = CurrencyInputCard(type: .From, viewModel: viewModel)
        (view.textField.rx.text <-> viewModel.didEnterFromAmount).disposed(by: disposeBag)
        view.bindAll()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    lazy var toCardComponent: CurrencyInputCard = {
        let view = CurrencyInputCard(type: .To, viewModel: viewModel)
        (view.textField.rx.text <-> viewModel.didEnterToAmount).disposed(by: disposeBag)
        view.bindAll()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    lazy var ratesCalculatedLabel: UILabel = {
        let label = UILabel()
        label.textColor = .gray
        label.text = "Here"
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    

}

extension CurrencyConvertorViewController {
    
//    func bindDropdowns() {
//        viewModel.availableExchangeRates
//            .observeOn(MainScheduler.instance)
//            .bind(onNext: { (newOptions) in
//                self.fromCardComponent.setOptions(options: newOptions)
//                self.toCardComponent.setOptions(options: newOptions)
//            })
//            .disposed(by: disposeBag)
//
//    }
    
    private func bindRatesLabel() {
        viewModel.rateExchangeLabel
            .observeOn(MainScheduler.instance)
            .map({ (res) -> String in
                return "Rates: \(res)"
            })
            .bind(to: ratesCalculatedLabel.rx.text)
            .disposed(by: disposeBag)
    }
    
}


// MARK: - UI Setup
extension CurrencyConvertorViewController {
    private func setupUI() {
        if #available(iOS 13.0, *) {
            self.overrideUserInterfaceStyle = .light
        }
        self.view.backgroundColor = .white
        
        self.view.addSubview(fromCardComponent)
        self.view.addSubview(toCardComponent)
        self.view.addSubview(ratesCalculatedLabel)
    
        
        NSLayoutConstraint.activate([
            fromCardComponent.leftAnchor
                .constraint(equalTo: self.view.leftAnchor, constant: 15.0),
            fromCardComponent.topAnchor
                .constraint(equalTo: self.view.safeAreaLayoutGuide.topAnchor),
            fromCardComponent.rightAnchor
                .constraint(equalTo: self.view.rightAnchor, constant: -15.0),
            fromCardComponent.heightAnchor
                .constraint(equalToConstant: 60)
        ])
        
        NSLayoutConstraint.activate([
            toCardComponent.leftAnchor
                .constraint(equalTo: self.view.leftAnchor, constant: 15.0),
            toCardComponent.topAnchor
                .constraint(equalTo: self.fromCardComponent.bottomAnchor, constant: 20.0),
            toCardComponent.rightAnchor
                .constraint(equalTo: self.view.rightAnchor, constant: -15.0),
            toCardComponent.heightAnchor
                .constraint(equalToConstant: 60)
        ])
        
        NSLayoutConstraint.activate([
            ratesCalculatedLabel.leftAnchor
                .constraint(equalTo: self.view.leftAnchor, constant: 15.0),
            ratesCalculatedLabel.topAnchor
                .constraint(equalTo: self.toCardComponent.bottomAnchor, constant: 20.0),
            ratesCalculatedLabel.rightAnchor
                .constraint(equalTo: self.view.rightAnchor, constant: -15.0),
        ])
        
    }
    
    private func setupNavigationBar() {
           self.navigationController?.navigationBar.barTintColor = .white
           self.navigationController?.navigationBar.isTranslucent = false
       }
       
       private func setupNavigationItem() {
           self.navigationItem.title = "Currency Conversion"
       }
    
}
