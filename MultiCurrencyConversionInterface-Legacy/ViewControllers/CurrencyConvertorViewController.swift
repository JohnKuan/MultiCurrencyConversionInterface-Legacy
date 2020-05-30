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
        bindWalletBalanceLabel()
        bindButtons()
        
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
        label.text = ""
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    lazy var fromWalletBalanceLabel: UILabel = {
        let label = UILabel()
        label.textColor = .gray
        label.text = "Balance: "
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    lazy var toWalletBalanceLabel: UILabel = {
        let label = UILabel()
        label.textColor = .gray
        label.text = "Balance: "
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    lazy var convertButton: UIButton = {
        let button = UIButton(type: .roundedRect)
        button.setTitle("Convert", for: .normal)
        button.setTitle("Converting..", for: .highlighted)
        button.setTitle("Converting..", for: .selected)
        button.setBackgroundColor(UIColor.lightGray.withAlphaComponent(0.5), forState: .disabled)
        button.setBackgroundColor(.lightGray, forState: .highlighted)
        button.setTitleColor(.black, for: .normal)
        button.setTitleColor(.darkGray, for: .disabled)
        button.layer.borderWidth = 0.5
        button.layer.borderColor = UIColor.gray.cgColor
        button.layer.cornerRadius = Dimensions.smallPadding
        button.layer.masksToBounds = true
        button.isEnabled = false // first disable
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    lazy var historyButton: UIButton = {
        let button = UIButton(type: .roundedRect)
        button.setTitle("View History", for: .normal)
        button.setTitleColor(.black, for: .normal)
        button.setTitleColor(.lightGray, for: [.highlighted, .selected, .disabled])
        button.layer.borderWidth = 0.5
        button.layer.borderColor = UIColor.gray.cgColor
        button.layer.cornerRadius = Dimensions.smallPadding
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
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
    
    private func bindButtons() {
        
        // convert button
        convertButton.rx.tap.bind(to: viewModel.didSelectConvertButton).disposed(by: disposeBag)
        viewModel.enableConvertButton.observeOn(MainScheduler.instance).bind(to: convertButton.rx.isEnabled).disposed(by: disposeBag)
        
        
        historyButton.rx.tap.bind(to: viewModel.didSelectHistoryButton).disposed(by: disposeBag)
    }
    
    private func bindWalletBalanceLabel() {
        viewModel.fromWalletBalanceLabel
            .observeOn(MainScheduler.instance)
            .bind (to: fromWalletBalanceLabel.rx.text)
        .disposed(by: disposeBag)
        
        viewModel.fromWalletBalanceNotExceed.observeOn(MainScheduler.instance)
            .subscribe(onNext: { [unowned self] (available) in
                self.fromWalletBalanceLabel.textColor = available ? UIColor.gray : UIColor.red
            }).disposed(by: disposeBag)
        
        viewModel.toWalletBalanceLabel
            .observeOn(MainScheduler.instance)
            .bind (to: toWalletBalanceLabel.rx.text)
        .disposed(by: disposeBag)
        
//        viewModel.toWalletBalanceNotExceed.observeOn(MainScheduler.instance)
//            .subscribe(onNext: { [unowned self] (available) in
//                self.toWalletBalanceLabel.textColor = available ? UIColor.gray : UIColor.red
//            }).disposed(by: disposeBag)
        
    }
    
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
        self.view.addSubview(fromWalletBalanceLabel)
        self.view.addSubview(toWalletBalanceLabel)
        self.view.addSubview(convertButton)
        self.view.addSubview(historyButton)
        view.addGestureRecognizer(UITapGestureRecognizer(target: self.view, action: #selector(UIView.endEditing)))
    
        
        NSLayoutConstraint.activate([
            fromCardComponent.leftAnchor
                .constraint(equalTo: self.view.leftAnchor, constant: Dimensions.padding),
            fromCardComponent.topAnchor
                .constraint(equalTo: self.view.safeAreaLayoutGuide.topAnchor, constant: 50),
            fromCardComponent.rightAnchor
                .constraint(equalTo: self.view.rightAnchor, constant: -Dimensions.padding),
            fromCardComponent.heightAnchor
                .constraint(equalToConstant: 60)
        ])
        
        NSLayoutConstraint.activate([
            toCardComponent.leftAnchor
                .constraint(equalTo: self.view.leftAnchor, constant: Dimensions.padding),
            toCardComponent.topAnchor
                .constraint(equalTo: self.ratesCalculatedLabel.bottomAnchor, constant: 25.0),
            toCardComponent.rightAnchor
                .constraint(equalTo: self.view.rightAnchor, constant: -Dimensions.padding),
            toCardComponent.heightAnchor
                .constraint(equalToConstant: 60)
        ])
        
        NSLayoutConstraint.activate([
            ratesCalculatedLabel.leftAnchor
                .constraint(equalTo: self.view.leftAnchor, constant: Dimensions.padding),
            ratesCalculatedLabel.topAnchor
                .constraint(equalTo: self.fromWalletBalanceLabel.bottomAnchor, constant: 25.0),
            ratesCalculatedLabel.rightAnchor
                .constraint(equalTo: self.view.rightAnchor, constant: -Dimensions.padding),
        ])
        
        NSLayoutConstraint.activate([
            fromWalletBalanceLabel.leftAnchor
                .constraint(equalTo: self.view.leftAnchor, constant: Dimensions.padding),
            fromWalletBalanceLabel.topAnchor
                .constraint(equalTo: self.fromCardComponent.bottomAnchor, constant: 5.0),
            fromWalletBalanceLabel.rightAnchor
                .constraint(equalTo: self.view.rightAnchor, constant: -Dimensions.padding),
        ])
        
        NSLayoutConstraint.activate([
            toWalletBalanceLabel.leftAnchor
                .constraint(equalTo: self.view.leftAnchor, constant: Dimensions.padding),
            toWalletBalanceLabel.topAnchor
                .constraint(equalTo: self.toCardComponent.bottomAnchor, constant: 5.0),
            toWalletBalanceLabel.rightAnchor
                .constraint(equalTo: self.view.rightAnchor, constant: -Dimensions.padding),
        ])
        
        NSLayoutConstraint.activate([
            convertButton.leftAnchor
                .constraint(equalTo: self.view.leftAnchor, constant: Dimensions.padding),
            convertButton.rightAnchor
                .constraint(equalTo: self.view.rightAnchor, constant: -Dimensions.padding),
            convertButton.heightAnchor.constraint(equalToConstant: 45.0)
        ])
        
        NSLayoutConstraint.activate([
            historyButton.leftAnchor
                .constraint(equalTo: self.view.leftAnchor, constant: Dimensions.padding),
            historyButton.topAnchor
                .constraint(equalTo: self.convertButton.bottomAnchor, constant: 20.0),
            historyButton.rightAnchor
                .constraint(equalTo: self.view.rightAnchor, constant: -Dimensions.padding),
            historyButton.bottomAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.bottomAnchor),
            historyButton.heightAnchor.constraint(equalToConstant: 45.0)
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
