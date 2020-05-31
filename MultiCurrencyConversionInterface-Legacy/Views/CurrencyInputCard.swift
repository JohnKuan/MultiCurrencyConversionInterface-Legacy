//
//  CurrencyInputCard.swift
//  MultiCurrencyConversionInterface-Legacy
//
//  Created by John Kuan on 28/5/20.
//  Copyright © 2020 JohnKuan. All rights reserved.
//

import UIKit
import DropDown
import RxSwift
import RxBiBinding

enum CurrencyInputCardType {
    case From
    case To
}

class CurrencyInputCard: UIView {
    // MARK: - Properties
    let disposeBag = DisposeBag()
    private(set) var viewModel: CurrencyConversionViewModel!
    
    private var currencyInputCardType: CurrencyInputCardType = .To
    
    private var showOptions: Bool = false
    
    private var options: [DropdownOption] = []
    
    lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.text = "Currency"
        label.adjustsFontSizeToFitWidth = true
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    lazy var dropDownButton: UIButton = {
        let button = UIButton()
        button.setTitle("Cur", for: .normal)
        button.setTitleColor(UIColor.gray, for: .normal)
        button.addTarget(self, action: #selector(toggleOptions), for: .touchUpInside)
        button.layer.borderWidth = 0.5
        button.layer.borderColor = UIColor.darkGray.cgColor
        button.layer.cornerRadius = 1
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
  
    lazy var dropDownView: DropDown = {
        let dropDown = DropDown()
        dropDown.anchorView = dropDownButton
        // Top of drop down will be below the anchorView
        dropDown.bottomOffset = CGPoint(x: 0, y:(dropDown.anchorView?.plainView.bounds.height)!)
        dropDown.dataSource = []
        dropDown.translatesAutoresizingMaskIntoConstraints = false
        dropDown.selectionAction = { [unowned self] (index: Int, item: String) in
            print("Selected item: \(item) at index: \(index)")
            self.dropDownButton.setTitle(item, for: .normal)
            switch (self.currencyInputCardType) {
            case .From:
                self.viewModel.didSelectFromCurrency.accept(item)
            case .To:
                self.viewModel.didSelectToCurrency.accept(item)
            }
        }
        return dropDown
    }()
    
    lazy var walletBalanceLabel: UILabel = {
        let label = UILabel()
        label.textColor = .gray
        label.text = "Balance: "
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    lazy var textFieldToolBar: UIToolbar = {
        let toolbar = UIToolbar(frame: CGRect(origin: .zero, size: .init(width: self.frame.width, height: 30)))
        let flexSpace = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        let doneButton = UIBarButtonItem(title: "Done", style: .done, target: self, action: #selector(doneButtonAction))
        toolbar.setItems([flexSpace, doneButton], animated: false)
        toolbar.sizeToFit()
        return toolbar
    }()
    
    lazy var currencyTextField: CurrencyTextField = {
        let textField = CurrencyTextField()
        textField.inputAccessoryView = textFieldToolBar
        textField.translatesAutoresizingMaskIntoConstraints = false
        return textField
    }()
//
//    lazy var textField: UITextField = {
//        let textField = UITextField()
//        textField.keyboardType = .decimalPad
//        textField.placeholder = "e.g. 1000"
//        textField.inputAccessoryView = textFieldToolBar
//        textField.translatesAutoresizingMaskIntoConstraints = false
//        return textField
//    }()
    
    public init(type: CurrencyInputCardType, viewModel: CurrencyConversionViewModel) {
        super.init(frame: .zero)
        self.viewModel = viewModel
        self.currencyInputCardType = type
        setupUI()
    }

    private override init(frame: CGRect) {
        super.init(frame: frame)
        
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    @objc func toggleOptions() {
        if (showOptions) {
            dropDownView.hide()
        } else {
            dropDownView.show()
        }
        showOptions = !showOptions
    }
    
    @objc func doneButtonAction() {
        endEditing(true)
    }
    
    func setOptions(options: [DropdownOption]) {
        self.options = options
        dropDownView.dataSource = self.options.map({ (option) -> String in
            return option.key
        })
        dropDownView.selectRow(0)
    }
}

extension CurrencyInputCard {
    
    func bindAll() {
        bindDropdowns()
        bindWalletBalanceLabel()

    }
    
    private func bindDropdowns() {
        /// bind when available exchange rates are provided by source
       viewModel.availableExchangeRates
            .asDriver()
            .drive(onNext: { (newOptions) in
                self.setOptions(options: newOptions)
           })
           .disposed(by: disposeBag)
        
        /// set base on selected
        switch currencyInputCardType {
        case .From:
            viewModel.didSelectFromCurrency.asDriver()
                .do(onNext: { [unowned self] (val) in
                    self.currencyTextField.changeCurrentLocal(code: val)
                })
                .drive(dropDownButton.rx.title(for: .normal)).disposed(by: disposeBag)
        default:
            viewModel.didSelectToCurrency.asDriver()
                .do(onNext: { [unowned self] (val) in
                    self.currencyTextField.changeCurrentLocal(code: val)
                })
                .drive(dropDownButton.rx.title(for: .normal)).disposed(by: disposeBag)
        }
   }
    
    private func bindWalletBalanceLabel() {
        switch currencyInputCardType {
        case .From:
            viewModel.fromWalletBalanceLabel
                .asDriver(onErrorJustReturn: "")
                .drive(walletBalanceLabel.rx.text)
                .disposed(by: disposeBag)
            
            viewModel.fromWalletBalanceNotExceed.asDriver(onErrorJustReturn: false)
                .drive(onNext: { [unowned self] (isNotExceeded) in
                    self.walletBalanceLabel.textColor = isNotExceeded ? UIColor.gray : UIColor.red
                }).disposed(by: disposeBag)
        default:
            viewModel.toWalletBalanceLabel
                .asDriver(onErrorJustReturn: "")
                .drive(walletBalanceLabel.rx.text)
                .disposed(by: disposeBag)
        }
    }
}

extension CurrencyInputCard {
    private func setupUI() {
        if #available(iOS 13.0, *) {
            self.overrideUserInterfaceStyle = .light
        }
        self.backgroundColor = .white
        
        switch currencyInputCardType {
        case .From:
            titleLabel.text = "From"
        default:
            titleLabel.text = "To"
        }
        
        addSubview(dropDownButton)
        addSubview(dropDownView)
        addSubview(titleLabel)
        addSubview(currencyTextField)
        addSubview(walletBalanceLabel)
        
        NSLayoutConstraint.activate([
            titleLabel.leftAnchor.constraint(equalTo: leftAnchor),
            titleLabel.topAnchor
                .constraint(equalTo: topAnchor),
        ])
        
        NSLayoutConstraint.activate([
            dropDownButton.leftAnchor.constraint(equalTo: leftAnchor),
            dropDownButton.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 5.0),
            dropDownButton.widthAnchor.constraint(equalToConstant: 100.0),
        ])
        
        
        NSLayoutConstraint.activate([
            currencyTextField.leftAnchor.constraint(equalTo: dropDownButton.rightAnchor, constant: Dimensions.padding),
            currencyTextField.topAnchor.constraint(equalTo: dropDownButton.topAnchor),
            currencyTextField.bottomAnchor.constraint(equalTo: dropDownButton.bottomAnchor),
            currencyTextField.rightAnchor.constraint(equalTo: rightAnchor, constant: -Dimensions.padding),
        ])
        
        NSLayoutConstraint.activate([
            walletBalanceLabel.leftAnchor
                .constraint(equalTo: leftAnchor),
            walletBalanceLabel.topAnchor
                .constraint(equalTo: dropDownButton.bottomAnchor, constant: 5.0),
            walletBalanceLabel.rightAnchor
                .constraint(equalTo: rightAnchor, constant: -Dimensions.padding),
            walletBalanceLabel.bottomAnchor.constraint(greaterThanOrEqualTo: bottomAnchor)
        ])
    }
}


