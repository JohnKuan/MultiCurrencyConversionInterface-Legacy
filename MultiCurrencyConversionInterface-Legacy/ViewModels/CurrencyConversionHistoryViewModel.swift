//
//  CurrencyConversionHistoryViewModel.swift
//  MultiCurrencyConversionInterface-Legacy
//
//  Created by John Kuan on 29/5/20.
//  Copyright © 2020 JohnKuan. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa
import RxRealm
import RealmSwift

protocol ICurrencyConversionHistoryViewModel {
    var viewDidLoad: PublishRelay<Void> { get }
    
    // Output
    var isLoadingFirstPage: BehaviorRelay<Bool> { get }
    var historyItems: PublishRelay<[ExchangeItemHistory]> { get }
    
}

class CurrencyConversionHistoryViewModel:  ICurrencyConversionHistoryViewModel  {
    
    let viewDidLoad: PublishRelay<Void> = PublishRelay<Void>()
    
    // Output
    var isLoadingFirstPage: BehaviorRelay<Bool> = BehaviorRelay<Bool>(value: false)
    var historyItems: PublishRelay<[ExchangeItemHistory]> = PublishRelay<[ExchangeItemHistory]>()
    
    
    private let coordinator: CurrencyConvertorHistoryCoordinator
    
    private let disposeBag = DisposeBag()
    
    init(coordinator: CurrencyConvertorHistoryCoordinator) {
        self.coordinator = coordinator
        bindOnViewDidLoad()
    }
    
    private func bindOnViewDidLoad() {
        viewDidLoad
            .do(onNext: { [unowned self] _ in
                // fetch from data store
                let realm = try! Realm()
                let laps = realm.objects(ExchangeItemHistory.self)
                Observable.collection(from: laps)
                    .map({ (history) -> [ExchangeItemHistory] in
                        return history.toArray().reversed()
                    })
                    .bind(to: self.historyItems)
                    .disposed(by: self.disposeBag)
            })
            .subscribe()
            .disposed(by: disposeBag)
    }
}
