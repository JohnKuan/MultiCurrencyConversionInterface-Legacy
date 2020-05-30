//
//  CurrencyConversionHistoryViewController.swift
//  MultiCurrencyConversionInterface-Legacy
//
//  Created by John Kuan on 29/5/20.
//  Copyright © 2020 JohnKuan. All rights reserved.
//

import UIKit
import RxSwift

class CurrencyConversionHistoryViewController: UIViewController {
    
    
    // MARK: - Properties
    private let disposeBag = DisposeBag()
    var viewModel: ICurrencyConversionHistoryViewModel!
    var bottomConstraint: NSLayoutConstraint?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        setupUI()
        bindCollectionView()
        bindLoadingState()
        bindBottomActivityIndicator()
        
        viewModel.viewDidLoad.accept(())
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setupNavigationBar()
        setupNavigationItem()
    }
    
    lazy var historyCollectionView: UICollectionView = {
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: collectionViewLayout())
        collectionView.backgroundColor = .white
        
        collectionView.register(CurrencyHistoryItemCard.self, forCellWithReuseIdentifier: CurrencyHistoryItemCard.reuseIdentifier)
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        return collectionView
    }()
    
    lazy var bottomActivityIndicator: UIActivityIndicatorView = {
        let indicator = UIActivityIndicatorView(style: .large)
        indicator.hidesWhenStopped = true
        indicator.translatesAutoresizingMaskIntoConstraints = false
        return indicator
    }()
    
    
}

// MARK: - Binding
extension CurrencyConversionHistoryViewController {
    private func bindCollectionView() {
        /// Bind unsplash photos to the collection view items
        viewModel.historyItems
            .bind(to: historyCollectionView.rx.items(
                cellIdentifier: CurrencyHistoryItemCard.reuseIdentifier,
                cellType: CurrencyHistoryItemCard.self)) { row, historyItem, cell in
                    cell.transactionIDLabel.text = "TRX-\(historyItem.transactionID)"
                    let dateFormmater = DateFormatter()
                    dateFormmater.dateFormat = "MMM dd yyyy ᛫ HH:mm"
                    cell.dateLabel.text = dateFormmater.string(from: historyItem.date)
                    cell.transactionAmountLabel.text = historyItem.transactionAmount
                    cell.transactionRateAmountLabel.text = historyItem.transactionRate
        }
            .disposed(by: disposeBag)
    }
    
    private func bindLoadingState() {
        viewModel.isLoadingFirstPage
            .observeOn(MainScheduler.instance)
            .map({ (isLoading) in
                return isLoading ? "Fetching..." : "View History"
            })
            .bind(to: navigationItem.rx.title)
            .disposed(by: disposeBag)
    }
    
    private func bindBottomActivityIndicator() {
//        viewModel.isLoadingAdditionalPhotos
//            .observeOn(MainScheduler.instance)
//            .do(onNext: { [weak self] isLoading in
//                self?.updateConstraintForMode(loadingMorePhotos: isLoading)
//            })
//            .bind(to: bottomActivityIndicator.rx.isAnimating)
//            .disposed(by: disposeBag)
    }
}

// MARK: - UI Setup
extension CurrencyConversionHistoryViewController {
    private func setupUI() {
        if #available(iOS 13.0, *) {
            self.overrideUserInterfaceStyle = .light
        }
        self.view.backgroundColor = .white
        self.view.addSubview(historyCollectionView)
        self.view.addSubview(bottomActivityIndicator)
        
        bottomConstraint = historyCollectionView.bottomAnchor
            .constraint(equalTo: self.view.safeAreaLayoutGuide.bottomAnchor)
        
        NSLayoutConstraint.activate([
            historyCollectionView.leftAnchor
                .constraint(equalTo: self.view.leftAnchor),
            historyCollectionView.topAnchor
                .constraint(equalTo: self.view.safeAreaLayoutGuide.topAnchor),
            historyCollectionView.rightAnchor
                .constraint(equalTo: self.view.rightAnchor),
            bottomConstraint!
        ])
        
        NSLayoutConstraint.activate([
            bottomActivityIndicator.centerXAnchor
                .constraint(equalTo: self.view.centerXAnchor),
            bottomActivityIndicator.bottomAnchor
                .constraint(equalTo: self.view.safeAreaLayoutGuide.bottomAnchor),
            bottomActivityIndicator.widthAnchor
                .constraint(equalToConstant: 44),
            bottomActivityIndicator.heightAnchor
                .constraint(equalToConstant: 44)
        ])
    }
    
    private func setupNavigationBar() {
           self.navigationController?.navigationBar.barTintColor = .white
           self.navigationController?.navigationBar.isTranslucent = false
       }
       
   private func setupNavigationItem() {
       self.navigationItem.title = "View History"
   }
    
    private func collectionViewLayout() -> UICollectionViewLayout {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        layout.itemSize = Dimensions.historyCardSize
        let inset: CGFloat = Dimensions.padding
        layout.sectionInset = .init(top: inset,
                                    left: inset,
                                    bottom: inset,
                                    right: inset)
      return layout
    }
    
}
