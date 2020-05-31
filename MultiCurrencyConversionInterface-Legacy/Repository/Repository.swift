//
//  Repository.swift
//  MultiCurrencyConversionInterface-Legacy
//
//  Created by John Kuan on 29/5/20.
//  Copyright © 2020 JohnKuan. All rights reserved.
//

import Foundation
import RealmSwift
import CoreData

import RxSwift
import RxRealm

class Repository {
    let backgroundQueue = DispatchQueue(label: "com.app.queue",
    qos: .background,
    target: nil)
    
    
    func updateWalletBalance(wallet: Dictionary<String, Double>) {
        let walletObject = Wallet()
        walletObject.walletId = "1"
        let curArray = wallet.map({ (k,v) -> Currency in
            let currency = Currency()
            currency.currencyId = k
            currency.balance = v
            return currency
        })
        walletObject.currencies.append(objectsIn: curArray)
        walletObject.updatedDate = Date()
        let realm = try! Realm()
        try! realm.write{
            realm.add(walletObject, update: .all)
        }
    }
    
    
//    func retrieveCurrentWalletBalance() -> Dictionary<String, Double> {
//        Observable.l
//        Observable.from(object: Wallet.self)
//        DispatchQueue.main.async {
//            //1
//            guard let appDelegate =
//              UIApplication.shared.delegate as? AppDelegate else {
//                return
//            }
//
//            let managedContext =
//              appDelegate.persistentContainer.viewContext
//
//            //2
//            let fetchRequest =
//              NSFetchRequest<NSManagedObject>(entityName: "ExchangeRate")
//
//            //3
//            do {
//              let people = try managedContext.fetch(fetchRequest)
//                print(people)
//            } catch let error as NSError {
//              print("Could not fetch. \(error), \(error.userInfo)")
//            }
//        }
//    }
    
  
    func saveCurrency(currencyRateModel: CurrencyRateModel) {
//        DispatchQueue.main.async {
//            guard let appDelegate =
//              UIApplication.shared.delegate as? AppDelegate else {
//              return
//            }
//
//            // 1
//            let managedContext =
//              appDelegate.persistentContainer.viewContext
//
//            // 2
//            let entity =
//              NSEntityDescription.entity(forEntityName: "ExchangeRate",
//                                         in: managedContext)!
//
//            let er = NSManagedObject(entity: entity,
//                                         insertInto: managedContext)
//
//            // 3
//            er.setValue(currencyRateModel.base, forKeyPath: "base")
//            er.setValue(currencyRateModel.date, forKeyPath: "date")
//            er.setValue(currencyRateModel.rates, forKeyPath: "rates")
//
//            // 4
//            do {
//              try managedContext.save()
//            } catch let error as NSError {
//              print("Could not save. \(error), \(error.userInfo)")
//            }
//        }
    
        let storable = CurrencyRate()
        storable.base = currencyRateModel.base
        storable.date = currencyRateModel.date
        storable.rates = currencyRateModel.rates
        
        backgroundQueue.async {
            let realm = try! Realm()
            try! realm.write{
                realm.add(storable, update: .modified)
            }
        }
    }
    
    func readCurrency() {
//        DispatchQueue.global(qos: .background).async {
//            let ob = self.realm.objects(CurrencyRate.self)
//            print(ob.first?.rates)
//        }
        
//        backgroundQueue.async {
            let realm = try! Realm()
            let currentRate = try! realm.objects(CurrencyRate.self).last
            print(currentRate?.rates)
//            Observable.from(object: currentRate)
//        }
        
        
//        DispatchQueue.main.async {
//            //1
//            guard let appDelegate =
//              UIApplication.shared.delegate as? AppDelegate else {
//                return
//            }
//
//            let managedContext =
//              appDelegate.persistentContainer.viewContext
//
//            //2
//            let fetchRequest =
//              NSFetchRequest<NSManagedObject>(entityName: "ExchangeRate")
//
//            //3
//            do {
//              let people = try managedContext.fetch(fetchRequest)
//                print(people)
//            } catch let error as NSError {
//              print("Could not fetch. \(error), \(error.userInfo)")
//            }
//        }
    }
    
    func createExchangeRecord(exchangeItem: ExchangeItemHistory) {
        backgroundQueue.async {
            let realm = try! Realm()
            try! realm.write{
                realm.add(exchangeItem, update: .modified)
            }
        }
    }
        
    func retrieveWallet() -> Dictionary<String, Double> {
        let realm = try! Realm()
        guard let retrievedWallet = realm.object(ofType: Wallet.self, forPrimaryKey: "1") else {
            return [:]
        }
        return retrievedWallet.currencies.reduce([String:Double]()) { (dict, currency) -> [String:Double] in
            var dict = dict
            dict[currency.currencyId] = currency.balance
            return dict
        }
    }
    
    
   
}
