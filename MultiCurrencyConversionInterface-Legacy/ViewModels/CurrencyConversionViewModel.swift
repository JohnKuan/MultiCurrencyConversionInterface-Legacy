//
//  CurrencyConversionViewModel.swift
//  MultiCurrencyConversionInterface-Legacy
//
//  Created by John Kuan on 28/5/20.
//  Copyright © 2020 JohnKuan. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa
import RxBiBinding
import RealmSwift

protocol ICurrencyConversionViewModel: class {
    var viewDidLoad: PublishRelay<Void> { get }
    var didSelectFromCurrency: BehaviorRelay<String> { get }
    var didEnterFromAmount: BehaviorRelay<String?> { get }
    var didSelectToCurrency: BehaviorRelay<String> { get }
    var didEnterToAmount: BehaviorRelay<String?> { get }
    var didSelectConvertButton: PublishRelay<Void> { get }
    var enableConvertButton: PublishRelay<Bool> { get }
    var didSelectHistoryButton: PublishRelay<Void> { get }
    
    // Output
    var isLoadingFirstPage: BehaviorRelay<Bool> { get }
    var currencyRateModel: BehaviorRelay<CurrencyRateModel?>{ get }
    var availableExchangeRates: BehaviorRelay<[DropdownOption]> { get }
    var rateExchange: PublishRelay<Double> { get }
    var rateExchangeLabel: BehaviorRelay<String> { get }
    
    var fromWalletBalance: PublishRelay<Double> { get }
    var fromWalletBalanceLabel: PublishRelay<String> { get }
    var fromWalletBalanceNotExceed: PublishRelay<Bool> { get }
    
    var toWalletBalance: PublishRelay<Double> { get }
    var toWalletBalanceLabel: PublishRelay<String> { get }
    var toWalletBalanceNotExceed: PublishRelay<Bool> { get }
    
}

protocol ITestableCurrencyConversionViewModel {
    
}

class TestCurrencyConversionViewModel: ITestableCurrencyConversionViewModel {
    
}


class CurrencyConversionViewModel : ICurrencyConversionViewModel, ITestableCurrencyConversionViewModel  {
    let repo = Repository()
    
    var wallet: Dictionary<String, Double> =
        [
            "AUD": 150.20,
            "SGD": 15000.50,
            "JPY": 12990.30
        ]
//    let walletBalance: Double = 15000.05
//    let baseCurrency = "SGD"
    
    var changingFrom: Bool = false
    var changingTo: Bool = false
    
    private var convertString: String = ""
    private var convertable: Bool = false
    
    // MARK: - Private Properties
    private let exchangeRateAPIService: IExchangeRateAPIService
    private let coordinator: CurrencyConvertorMainCoordinator
    private let disposeBag = DisposeBag()
    
    
    let viewDidLoad: PublishRelay<Void> = PublishRelay<Void>()
    
    let didSelectFromCurrency: BehaviorRelay<String> = BehaviorRelay<String>(value: "")
    
    var didEnterFromAmount: BehaviorRelay<String?> = BehaviorRelay<String?>(value: nil)
    
    var didSelectToCurrency: BehaviorRelay<String> = BehaviorRelay<String>(value: "")
    
    var didEnterToAmount: BehaviorRelay<String?> = BehaviorRelay<String?>(value: nil)
    let didSelectConvertButton: PublishRelay<Void> = PublishRelay<Void>()
    let enableConvertButton: PublishRelay<Bool> = PublishRelay<Bool>()
    let didSelectHistoryButton: PublishRelay<Void> = PublishRelay<Void>()
    
    
    // output
    let isLoadingFirstPage: BehaviorRelay<Bool> = BehaviorRelay<Bool>(value: false)
    
    let currencyRateModel: BehaviorRelay<CurrencyRateModel?> =  BehaviorRelay<CurrencyRateModel?>(value: nil)
    
    let availableExchangeRates: BehaviorRelay<[DropdownOption]> =  BehaviorRelay<[DropdownOption]>(value: [])
    
    let rateExchange: PublishRelay<Double> = PublishRelay<Double>()
    let rateExchangeLabel: BehaviorRelay<String> = BehaviorRelay<String>(value: "")
    let fromWalletBalance: PublishRelay<Double> = PublishRelay<Double>()
    let fromWalletBalanceLabel: PublishRelay<String> = PublishRelay<String>()
    let fromWalletBalanceNotExceed: PublishRelay<Bool> = PublishRelay<Bool>()
    
    let toWalletBalance: PublishRelay<Double> = PublishRelay<Double>()
    let toWalletBalanceLabel: PublishRelay<String> = PublishRelay<String>()
    let toWalletBalanceNotExceed: PublishRelay<Bool> = PublishRelay<Bool>()
    
    let amountToBeConvertedString: BehaviorRelay<String> = BehaviorRelay<String>(value: "")
    
    
    init(exchangeRateAPIService: IExchangeRateAPIService, coordinator: CurrencyConvertorMainCoordinator) {
        self.exchangeRateAPIService = exchangeRateAPIService
        self.coordinator = coordinator
        bindOnViewDidLoad()
        bindOnDidSelectDropdownItem()
        bindOnTextFieldDidChange()
        bindButtons()
        bindCalculateConversion()
    }
    
    private func getCurrencyRate() {
        self.exchangeRateAPIService
        .loadCurrencyRatesWithBase(base: "")
        .map { [unowned self] (res) -> CurrencyRateModel in
            do {
                let m = try res.get()
                self.convertRatesFromDictToDropDownOptions(rates: m.rates)
                return m
            }
            }.bind(to: currencyRateModel)
        .disposed(by: disposeBag)
    }
    
    private func requestExchangeRate(from: String, to: String) {
        self.exchangeRateAPIService
            .loadCurrencyRateWithFromAndToSelected(from: from, to: to)
            .map { (res) -> Double in
                do {
                    let r = try res.get()
                    guard let rateEx = r.rates[to] else { return 0 }
                    return rateEx
                }
            }.bind(to: rateExchange)
            .disposed(by: disposeBag)
    }
    
    private func convertRatesFromDictToDropDownOptions(rates: Dictionary<String, Double>) {
        let sortedRates = rates.map { (key: String, value: Double) -> DropdownOption in
            return DropdownOption(key: key, val: key)
        }.sorted { (a, b) -> Bool in
            a.key<b.key
        }
        availableExchangeRates.accept(sortedRates)
    }
    
    private func calculateRateExchangeLabel(selectedFrom: String, selectedTo: String, rateExchange: Double) {
        Observable.create { observer in
            let string = selectedFrom + "1" + " = " + selectedTo + String(format: "%.4f", rateExchange)
            observer.onNext(string)
            return Disposables.create {}
        }
        .bind(to: rateExchangeLabel)
        .disposed(by: disposeBag)
    }
    
    private func isCurrentWalletBalanceAvailable(currency: String, deducting: Double) -> Bool {
        guard let currentBalance = wallet[currency] else {
            return false
        }
        return currentBalance - deducting >= 0
    }
    
    private func currentValueInWalletFor(currency: String) -> Double {
        guard let val = wallet[currency] else { return 0 }
        return val
    }
}

extension CurrencyConversionViewModel {
    
    // MARK: - Bindings
    private func bindOnViewDidLoad() {
        viewDidLoad
            .observeOn(MainScheduler.instance)
            .do(onNext: { [unowned self] _ in
                self.getCurrencyRate()
                self.retrieveWallet()
            })
            .subscribe()
            .disposed(by: disposeBag)
    }
    private func bindOnDidSelectDropdownItem() {
        
        didSelectFromCurrency.filter({!$0.isEmpty}).observeOn(MainScheduler.instance)
            .map { (fromCur) -> String in
                return "Balance: \(fromCur) " + String(format: "%.2f", self.currentValueInWalletFor(currency: fromCur))
            }.bind(to: fromWalletBalanceLabel).disposed(by: disposeBag)
        
        didSelectToCurrency.filter({!$0.isEmpty}).observeOn(MainScheduler.instance)
        .map { (toCur) -> String in
            return "Balance: \(toCur) " + String(format: "%.2f", self.currentValueInWalletFor(currency: toCur))
        }.bind(to: toWalletBalanceLabel).disposed(by: disposeBag)
        
        
        Observable.combineLatest(didSelectFromCurrency.filter({!$0.isEmpty}), didSelectToCurrency.filter({!$0.isEmpty}))
            .debounce(.microseconds(50), scheduler: MainScheduler.instance)
            .subscribe(onNext: { [unowned self] (fromValue, toValue) in
                self.requestExchangeRate(from: fromValue, to: toValue)
            })
            .disposed(by: disposeBag)
        
        Observable.combineLatest(didSelectFromCurrency, didSelectToCurrency, rateExchange)
            .subscribe(onNext: { [unowned self] (selectedFrom, selectedTo, rate) in
                self.calculateRateExchangeLabel(selectedFrom: selectedFrom, selectedTo: selectedTo, rateExchange: rate)
            }).disposed(by: disposeBag)
    }
    
    typealias ItemType<T> = (current: T, previous: T)
    private func bindOnTextFieldDidChange() {
        Observable.combineLatest(
            didEnterFromAmount.debounce(.microseconds(0), scheduler: MainScheduler.instance).map({ $0 ?? ""}).currentAndPrevious(),
            didEnterToAmount.debounce(.microseconds(0), scheduler: MainScheduler.instance).map({ $0 ?? ""}).currentAndPrevious(),
            rateExchange.currentAndPrevious())
            .filter({ (first: ItemType, second: ItemType, rateEx: ItemType) -> Bool in
                let d1 = Double(first.current) ?? 0
                let d2 = Double(second.current) ?? 0
                return  !d2.isEqual(to:d1 * rateEx.current) && !d1.isEqual(to: d2 / rateEx.current)
            })
            .observeOn(MainScheduler.instance)
            .subscribe(onNext: { [unowned self] (first: ItemType, second: ItemType, rateEx: ItemType) in
                if first.current != first.previous && second.current == second.previous {
                    // first was changed
                    if !self.changingFrom {
                        do {
                            guard let d = Double(first.current) else { return }
                            self.changingTo = true
                            self.didEnterToAmount.accept(String(format: "%.2f", d * rateEx.current))
                        }
                    } else {
                        self.changingFrom = false
                    }
                    
                } else if (second.current != second.previous && first.current == first.previous) {
                    // second was changed
                    if !self.changingTo {
                        do {
                            guard let d = Double(second.current) else { return }
                            self.changingFrom = true
                            self.didEnterFromAmount.accept(String(format: "%.2f", d / rateEx.current))
                        }
                    } else {
                           self.changingTo = false
                    }
                    
                } else if rateEx.current != rateEx.previous {
                    do {
                        guard let d1 = Double(first.current) else { return }
                        self.didEnterToAmount.accept(String(format: "%.2f", d1 * rateEx.current))
                    }
                }
            })
        .disposed(by: disposeBag)
        

        Observable.combineLatest(didSelectFromCurrency, didEnterFromAmount, currencyRateModel)
            .debounce(.microseconds(0), scheduler: MainScheduler.instance)
            .subscribe(onNext: { [unowned self] (cur, strOpt, allRatesModel) in
                guard let string = strOpt, let dou = Double(string) else {
                    return
                }
                let isAvailable = self.isCurrentWalletBalanceAvailable(currency: cur, deducting: dou)
                self.fromWalletBalanceNotExceed.accept(isAvailable)
                self.enableConvertButton.accept(isAvailable)
            }).disposed(by: disposeBag)
    }
    
    private func bindButtons() {
        didSelectConvertButton.observeOn(MainScheduler.instance)
            .withLatestFrom(amountToBeConvertedString)
//            .do(onNext: { [unowned self] v in
//                print("Convert \(v)")
//            })
            .subscribe(onNext: { [unowned self] (v) in
                self.coordinator.showAlert(convertString: v) {
                    print("store \(v)")
                    self.deductAmount()
                    self.createExchangeRecord()
                }
            })
            .disposed(by: disposeBag)
        
        didSelectHistoryButton.observeOn(MainScheduler.instance)
            .subscribe(onNext: { (_) in
                self.coordinator.pushToHistory()
            }).disposed(by: disposeBag)
    }
    
    private func bindCalculateConversion() {
        Observable.combineLatest(didSelectFromCurrency, didEnterFromAmount, didSelectToCurrency, didEnterToAmount)
            .observeOn(MainScheduler.instance)
            .map({ (fromCur, fromAmountString, toCur, toAmountString) -> String in
                guard let fromAmt = fromAmountString, let toAmt = toAmountString else {
                    return ""
                }
                let conversionString = fromCur + fromAmt + " to " + toCur + toAmt
                return conversionString
            })
            .bind(to: amountToBeConvertedString)
            .disposed(by: self.disposeBag)
    }
    
    private func createExchangeRecord() {
        let disposable = Observable.combineLatest(amountToBeConvertedString, rateExchangeLabel)
        .subscribe(onNext: { (transactionAmount, rateEx) in
            let conversionItem = ExchangeItemHistory()
            conversionItem.transactionID = UUID().uuidString
            conversionItem.date = Date()
            conversionItem.transactionAmount = transactionAmount
            conversionItem.transactionRate = rateEx
            Repository().backgroundQueue.async {
                let realm = try! Realm()
                try! realm.write{
                    realm.add(conversionItem, update: .modified)
                }
            }
            
        })
        disposable.dispose()
    }
    
    private func retrieveWallet() {
//        Repository().backgroundQueue.async {
                let realm = try! Realm()
                guard let retrievedWallet = realm.object(ofType: Wallet.self, forPrimaryKey: "1") else {
                    return
                }
                self.wallet = retrievedWallet.currencies.reduce([String:Double]()) { (dict, currency) -> [String:Double] in
                    var dict = dict
                    dict[currency.currencyId] = currency.balance
                    return dict
                }
            print(self.wallet)
//        }
        
    }
    
    private func deductAmount() {
       let disposable = Observable.combineLatest(didSelectFromCurrency, didEnterFromAmount, didSelectToCurrency, didEnterToAmount)
            .subscribe(onNext: { [unowned self] (fromCur, fromAmountString, toCur, toAmountString) in
                guard let fromValue = self.wallet[fromCur], let deductingAmount = Double(fromAmountString ?? "0"), let addingAmount = Double(toAmountString ?? "0") else { return }
                self.wallet[fromCur] = fromValue - deductingAmount
                self.wallet[toCur] = (self.wallet[toCur] ?? 0) + addingAmount
                // save into repo
                
                self.repo.updateWalletBalance(wallet: self.wallet)
                
                self.didEnterFromAmount.accept("")
                self.didEnterToAmount.accept("")
                self.fromWalletBalanceLabel.accept("Balance: \(fromCur) " + String(format: "%.2f", self.currentValueInWalletFor(currency: fromCur)))
                self.toWalletBalanceLabel.accept("Balance: \(toCur) " + String(format: "%.2f", self.currentValueInWalletFor(currency: toCur)))
                self.enableConvertButton.accept(false)
                print(self.wallet)
                self.coordinator.pushToHistory()
            })
        disposable.dispose()
    }
    
    func loadOnlyOnFirstAttempt() {
        self.repo.updateWalletBalance(wallet: self.wallet)
    }
}

enum ConvertableError : Error {
    case NegativeValue
    case Fail
}

struct DropdownOption: Hashable {
    public static func == (lhs: DropdownOption, rhs: DropdownOption) -> Bool {
        return lhs.key == rhs.key
    }

    var key: String
    var val: String
}
