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

protocol ICurrencyConversionViewModel: class {
    var viewDidLoad: PublishRelay<Void> { get }
    var didSelectFromCurrency: PublishRelay<String> { get }
    var didEnterFromAmount: PublishRelay<Double> { get }
    var didSelectToCurrency: PublishRelay<String> { get }
    var didEnterToAmount: PublishRelay<Double> { get }
    
    // Output
    var isLoadingFirstPage: BehaviorRelay<Bool> { get }
    var currencyRateModel: BehaviorRelay<CurrencyRateModel?>{ get }
    var availableExchangeRates: BehaviorRelay<[DropdownOption]> { get }
    
}


class CurrencyConversionViewModel : ICurrencyConversionViewModel  {
    
    let baseCurrency = "SGD"
    
    // MARK: - Private Properties
    private let exchangeRateAPIService: IExchangeRateAPIService
    private let coordinator: CurrencyConvertorMainCoordinator
    private let disposeBag = DisposeBag()
    
    
    let viewDidLoad: PublishRelay<Void> = PublishRelay<Void>()
    
    let didSelectFromCurrency: PublishRelay<String> = PublishRelay<String>()
    
    var didEnterFromAmount: PublishRelay<Double> = PublishRelay<Double>()
    
    var didSelectToCurrency: PublishRelay<String> = PublishRelay<String>()
    
    var didEnterToAmount: PublishRelay<Double> = PublishRelay<Double>()
    
    let isLoadingFirstPage: BehaviorRelay<Bool> = BehaviorRelay<Bool>(value: false)
    
    let currencyRateModel: BehaviorRelay<CurrencyRateModel?> =  BehaviorRelay<CurrencyRateModel?>(value: nil)
    
    let availableExchangeRates: BehaviorRelay<[DropdownOption]> =  BehaviorRelay<[DropdownOption]>(value: [])
    
    let rateExchange: PublishRelay<Double> = PublishRelay<Double>()
    let rateExchangeLabel: PublishRelay<String> = PublishRelay<String>()
    
    
    init(exchangeRateAPIService: IExchangeRateAPIService, coordinator: CurrencyConvertorMainCoordinator) {
        self.exchangeRateAPIService = exchangeRateAPIService
        self.coordinator = coordinator
        bindOnViewDidLoad()
        bindOnDidSelectDropdownItem()
        didSelectFromCurrency.accept(baseCurrency)
    }
    
    private func getCurrencyRate() {
        self.exchangeRateAPIService
        .loadCurrencyRatesWithBase(base: self.baseCurrency)
        .map { (res) -> CurrencyRateModel in
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
            let string = selectedFrom + "1.00" + " to " + selectedTo + String(format: "%.2f", rateExchange)
            observer.onNext(string)
            return Disposables.create {}
        }
        .bind(to: rateExchangeLabel)
        .disposed(by: disposeBag)
    }
}

extension CurrencyConversionViewModel {
    
    // MARK: - Bindings
    private func bindOnViewDidLoad() {
        viewDidLoad
            .observeOn(MainScheduler.instance)
            .do(onNext: { [unowned self] _ in
                self.getCurrencyRate()
            })
            .subscribe()
            .disposed(by: disposeBag)
    }
    private func bindOnDidSelectDropdownItem() {
        Observable.combineLatest(didSelectFromCurrency, didSelectToCurrency)
            .subscribe(onNext: { [unowned self] (fromValue, toValue) in
                self.requestExchangeRate(from: fromValue, to: toValue)
            })
            .disposed(by: disposeBag)
        Observable.combineLatest(didSelectFromCurrency, didSelectToCurrency, rateExchange)
            .subscribe(onNext: { [unowned self] (selectedFrom, selectedTo, rate) in
                self.calculateRateExchangeLabel(selectedFrom: selectedFrom, selectedTo: selectedTo, rateExchange: rate)
            }).disposed(by: disposeBag)
        
    }
}

struct DropdownOption: Hashable {
    public static func == (lhs: DropdownOption, rhs: DropdownOption) -> Bool {
        return lhs.key == rhs.key
    }

    var key: String
    var val: String
}
