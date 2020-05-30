//
//  CurrencyHistoryItemCard.swift
//  MultiCurrencyConversionInterface-Legacy
//
//  Created by John Kuan on 29/5/20.
//  Copyright © 2020 JohnKuan. All rights reserved.
//

import Foundation

import UIKit

class CurrencyHistoryItemCard: UICollectionViewCell {
    
    // MARK: - Initialization
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Properties
    lazy var transactionIDLabel: UILabel = {
        let label = UILabel()
        label.text = "TRX00001"
        label.font = UIFont.systemFont(ofSize: UIFont.smallSystemFontSize, weight: .semibold)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    lazy var dateLabel: UILabel = {
        let label = UILabel()
        label.text = "Mar 16 2020 . 15:10"
        label.font = UIFont.systemFont(ofSize: UIFont.smallSystemFontSize, weight: .semibold)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    lazy var transactionAmountLabel: UILabel = {
        let label = UILabel()
        label.text = "$100 -> 90USD"
        label.font = UIFont.systemFont(ofSize: 16.0)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    lazy var transactionRateAmountLabel: UILabel = {
        let label = UILabel()
        label.text = "$1 = USD0.90"
        label.font = UIFont.italicSystemFont(ofSize: 14.0)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
}

// MARK: - UI Setup
extension CurrencyHistoryItemCard {
    private func setupUI() {
        self.contentView.addSubview(transactionIDLabel)
        self.contentView.addSubview(dateLabel)
        self.contentView.addSubview(transactionAmountLabel)
        self.contentView.addSubview(transactionRateAmountLabel)
        
        self.layer.borderColor = UIColor.black.cgColor
        self.layer.cornerRadius = 20.0
        self.layer.masksToBounds = true
        backgroundColor = UIColor.lightGray.withAlphaComponent(0.5)
        
        NSLayoutConstraint.activate([
            transactionIDLabel.rightAnchor.constraint(equalTo: contentView.rightAnchor, constant: -Dimensions.padding),
            transactionIDLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -Dimensions.padding),
        ])
        
        NSLayoutConstraint.activate([
            dateLabel.rightAnchor.constraint(equalTo: contentView.rightAnchor, constant: -Dimensions.padding),
            dateLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: Dimensions.padding),
        ])
        
        NSLayoutConstraint.activate([
            
            transactionAmountLabel.leftAnchor.constraint(equalTo: contentView.leftAnchor, constant: Dimensions.padding),
//            transactionAmountLabel.topAnchor.constraint(equalTo: transactionIDLabel.bottomAnchor, constant: 8.0),
            transactionAmountLabel.centerYAnchor.constraint(equalTo: contentView.centerYAnchor)
        ])
        
        NSLayoutConstraint.activate([
            transactionRateAmountLabel.leftAnchor.constraint(equalTo: contentView.leftAnchor, constant: Dimensions.padding),
            transactionRateAmountLabel.topAnchor.constraint(equalTo: transactionAmountLabel.bottomAnchor, constant: Dimensions.smallPadding),
//            transactionRateAmountLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -10.0)
        ])
    }
}
