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

public class BehaviorDriver<Element>: NSObject {
    
    var behavior: BehaviorRelay<Element>!
    var driver: Driver<Element> {
        
        return behavior.asDriver()
    }

    public init(value: Element) {
       behavior =  BehaviorRelay<Element>(value: value)
    }
    
    public func value()->Element {
        return behavior.value
    }
    
    public func accept(_ event: Element) {
        behavior.accept(event)
    }
    
    public func drive(onNext: ((Element) -> Void)? = nil, onCompleted: (() -> Void)? = nil, onDisposed: (() -> Void)? = nil) -> Disposable {
        
        return driver.drive(onNext: onNext, onCompleted: onCompleted, onDisposed: onDisposed)
    }
    
    public func drive<Observer>(_ observer: Observer) -> Disposable where Observer : ObserverType, Element == Observer.Element {
        return driver.drive(observer)
    }
}
