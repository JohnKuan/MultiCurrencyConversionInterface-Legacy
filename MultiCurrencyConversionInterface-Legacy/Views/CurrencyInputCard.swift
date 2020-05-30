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
    
    lazy var textFieldToolBar: UIToolbar = {
        let toolbar = UIToolbar(frame: CGRect(origin: .zero, size: .init(width: self.frame.width, height: 30)))
        let flexSpace = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        let doneButton = UIBarButtonItem(title: "Done", style: .done, target: self, action: #selector(doneButtonAction))
        toolbar.setItems([flexSpace, doneButton], animated: false)
        toolbar.sizeToFit()
        return toolbar
    }()
    
    lazy var textField: UITextField = {
        let textField = UITextField()
        textField.keyboardType = .decimalPad
        textField.placeholder = "e.g. 1000"
        textField.inputAccessoryView = textFieldToolBar
        textField.translatesAutoresizingMaskIntoConstraints = false
        return textField
    }()
    
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
        bindTextField()
    }
    
    private func bindDropdowns() {
       viewModel.availableExchangeRates
           .observeOn(MainScheduler.instance)
           .bind(onNext: { (newOptions) in
                self.setOptions(options: newOptions)
           })
           .disposed(by: disposeBag)
   }
    
    private func bindTextField() {
        
        //bind events when textfield is computed against
        
        

        
        // bind events when textfield is typed
//        let statement = textField.rx.controlEvent([.allEditingEvents])
//            .withLatestFrom(textField.rx.text)
//            .map({ (text) -> Double in
//                guard let t = text, let de = Double(t) else {
//                    return 0
//                }
//                print(de)
//                return de
//            })
//        switch self.currencyInputCardType {
//            case .From:
////               statement.bind(to: viewModel.didEnterFromAmount).disposed(by: disposeBag)
//            viewModel.didEnterFromAmount.map { (newVal) -> String in
//                return String(format: "%.2f", newVal)
//                }.bind(to: textField.rx.text).disposed(by: disposeBag)
//            default:
////                statement.bind(to: viewModel.didEnterToAmount).disposed(by: disposeBag)
//            viewModel.didEnterToAmount.map { (newVal) -> String in
//                return String(format: "%.2f", newVal)
//                }.bind(to: textField.rx.text).disposed(by: disposeBag)
//        }
        
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
        addSubview(textField)
        
        NSLayoutConstraint.activate([
            titleLabel.leftAnchor.constraint(equalTo: leftAnchor),
            titleLabel.topAnchor
                .constraint(equalTo: topAnchor),
//            titleLabel.rightAnchor
//                .constraint(equalTo: self.view.rightAnchor),
//            titleLabel.heightAnchor
//                .constraint(equalToConstant: Dimensions.screenHeight * 0.3)
        ])
        
        NSLayoutConstraint.activate([
            dropDownButton.leftAnchor.constraint(equalTo: leftAnchor),
            dropDownButton.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 5.0),
            dropDownButton.widthAnchor.constraint(equalToConstant: 100.0),
//            dropDownButton.heightAnchor.constraint(equalToConstant: 40.0),
            dropDownButton.bottomAnchor.constraint(greaterThanOrEqualTo: bottomAnchor)
        ])
        
        
        NSLayoutConstraint.activate([
            textField.leftAnchor.constraint(equalTo: dropDownButton.rightAnchor, constant: Dimensions.padding),
            textField.topAnchor.constraint(equalTo: dropDownButton.topAnchor),
            textField.bottomAnchor.constraint(equalTo: dropDownButton.bottomAnchor),
            textField.rightAnchor.constraint(equalTo: rightAnchor, constant: -Dimensions.padding),
        ])
    }
}


