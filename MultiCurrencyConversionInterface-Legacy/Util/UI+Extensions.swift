//
//  UI+Extensions.swift
//  MultiCurrencyConversionInterface-Legacy
//
//  Created by John Kuan on 29/5/20.
//  Copyright © 2020 JohnKuan. All rights reserved.
//

import UIKit

extension UIButton {
  func setBackgroundColor(_ color: UIColor, forState controlState: UIControl.State) {
    let colorImage = UIGraphicsImageRenderer(size: CGSize(width: 1, height: 1)).image { _ in
      color.setFill()
      UIBezierPath(rect: CGRect(x: 0, y: 0, width: 1, height: 1)).fill()
    }
    setBackgroundImage(colorImage, for: controlState)
  }
}

protocol ReuseIdentifiable: class {
    static var reuseIdentifier: String { get }
}

extension ReuseIdentifiable {
    static var reuseIdentifier: String { .init(describing: self) }
}

extension UICollectionViewCell: ReuseIdentifiable {}
extension UITableViewCell: ReuseIdentifiable {}

struct Dimensions {
    static let screenWidth: CGFloat
        = UIScreen.main.bounds.width
    static let screenHeight: CGFloat
        = UIScreen.main.bounds.height
    
    static let historyCardSize
        = CGSize(width: Dimensions.screenWidth * 0.9,
                 height: Dimensions.screenWidth * 0.45)
    
    static let padding: CGFloat = 15.0
    static let smallPadding: CGFloat = 8.0
}

struct CurrencyConverter {
    static func getSymbolForCurrencyCode(code: String) -> String? {
        let result = getLocalForCurrencyCode(code: code)
        return result?.currencySymbol
    }
    static func getLocalForCurrencyCode(code: String) -> Locale? {
        return Locale.availableIdentifiers.map { Locale(identifier: $0) }.first { $0.currencyCode == code }
    }
    
    static func convertCurrencyToDouble(local: Locale, input: String) -> Double? {
        let numberFormatter = NumberFormatter()
        numberFormatter.numberStyle = .currency
        numberFormatter.locale = local
        return numberFormatter.number(from: input)?.doubleValue
    }
    
    static func convertDoubleToCurrency(local: Locale, amount: Double) -> String {
        let numberFormatter = NumberFormatter()
        numberFormatter.numberStyle = .currency
        numberFormatter.locale = local
        return numberFormatter.string(from: NSNumber(value: amount)) ?? ""
    }
}
