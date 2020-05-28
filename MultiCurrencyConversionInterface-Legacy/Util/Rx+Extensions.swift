//
//  Rx+Extensions.swift
//  MultiCurrencyConversionInterface-Legacy
//
//  Created by John Kuan on 28/5/20.
//  Copyright © 2020 JohnKuan. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa

extension ObservableType {
    func currentAndPrevious() -> Observable<(current: Element, previous: Element)> {
        return self.multicast({ () -> PublishSubject<Element> in PublishSubject<Element>() }) { (values: Observable<Element>) -> Observable<(current: Element, previous: Element)> in
            let pastValues = Observable.merge(values.take(1), values)
            
            return Observable.combineLatest(values.asObservable(), pastValues) { (current, previous) in
                return (current: current, previous: previous)
            }
        }
    }
}
