//
//  ViewController.swift
//  TakeAwayNow
//
//  Created by Reshma Unnikrishnan on 10.01.20.
//  Copyright © 2020 ruvlmoon. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

class RestaurantsViewController: UIViewController, UITableViewDelegate {

  @IBOutlet weak var tableView: UITableView!
  @IBOutlet weak var sortBarButton: UIBarButtonItem!
  @IBOutlet weak var searchBar: UISearchBar!
  
  private var sortingRelay = PublishRelay<SortType>()
  private var searchRelay = PublishRelay<String>()
  private var favoriteRelay = PublishRelay<Bool>()
  
  // MARK: - Properties
  private let disposeBag = DisposeBag()
  private let indicatorView = UIActivityIndicatorView(style: .large)
  private let dataSource = BehaviorRelay(value: [RestaurantViewModel]())
  
  var viewModel: RestaurantsViewModelType = RestaurantsViewModel()
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    setProperties()
    bindViewModel()
    bindView()
    updateSortLabel(title: .bestMatch)
  }
  
  private func bindViewModel() {
    dataSource
      .bind(to: tableView.rx.items(cellIdentifier: "restaurantcell", cellType: RestaurantCell.self)) {  [weak self] (row, restaurantViewModel, cell) in
        guard let self = self else { return }
        cell.updateWithRestaurant(restaurantViewModel: restaurantViewModel)
        cell.favoriteRelay = self.favoriteRelay
      }
      .disposed(by: disposeBag)
    
    let viewDidAppear = rx.sentMessage(#selector(RestaurantsViewController.viewDidAppear(_:))).take(1).mapToVoid().asDriverComplete()
  
    let input = RestaurantsViewModel.Input(
                  viewAppearTrigger: viewDidAppear,
                  sortTrigger: sortingRelay.asDriverComplete(),
                  favoriteTrigger: favoriteRelay.asDriverComplete(),
                  searchTextTrigger: searchRelay.asDriverComplete()
                )
    let output = viewModel.transform(input: input)
    
    // for Warning: UITableView was told to layout its visible cells
    //              and other contents without being in the view hierarchy
    // https://github.com/ReactiveX/RxSwift/pull/2076
    
    output.restaurantsViewModel
      .do(onNext: { [weak self] (restaurants) in
        // just to make sure the value loaded before drive
        self?.tableView.separatorStyle = .singleLine
        return
      })
      .drive(dataSource)
      .disposed(by: disposeBag)
  }
  
  private func bindView() {
    searchBar.rx
      .text
      .orEmpty
      .subscribe(onNext: { (text) in
        self.searchRelay.accept(text)
      })
      .disposed(by: self.disposeBag)
    
    self.sortBarButton.rx.tap
      .subscribe { [weak self] _ in
      guard let self = self else { return }

      guard let sortVC = self.storyboard?.instantiateViewController(identifier: "SortOptionsViewController") as? SortOptionsViewController else {
        fatalError("SortOptionsViewController not found!!")
      }
      
      sortVC.viewModel.task.subscribe(onNext: { [weak self] task in
        self?.sortingRelay.accept(task.sortType)
        self?.updateSortLabel(title: task.sortType)
        
        sortVC.dismiss(animated: true, completion: nil)
        self?.tableView.scrollToRow(at: IndexPath(row: 0, section: 0), at: .top, animated: true)
      }).disposed(by: self.disposeBag)
        
      self.present(sortVC, animated: true, completion: nil)
    }.disposed(by: disposeBag)
  }
  
  private func setProperties() {
    tableView.rx.setDelegate(self).disposed(by: disposeBag)
    tableView.backgroundColor = .clear
    tableView.rowHeight = 325 // UITableView.automaticDimension
    tableView.estimatedRowHeight = 325
  }
  
  private func updateSortLabel(title: SortType) {
    switch title {
    case .averageProductPrice:
      self.sortBarButton.title = "Average Product Price"
    case .bestMatch:
      self.sortBarButton.title = "Best Match"
    case .deliveryCosts:
      self.sortBarButton.title = "Delivery Costs"
    case .distance:
      self.sortBarButton.title = "Distance"
    case .minCost:
      self.sortBarButton.title = "Minimum Cost"
    case .newest:
      self.sortBarButton.title = "Newest"
    case .popularity:
      self.sortBarButton.title = "Popularity"
    case .ratingAverage:
      self.sortBarButton.title = "Rating Average"
    }
  }
}

class RestaurantCell: UITableViewCell {
  private(set) var disposeBag = DisposeBag()
  
  var restaurantViewModel: RestaurantViewModel?
  var favoriteRelay = PublishRelay<Bool>()
  var storedItems: [String] = []
  @IBOutlet weak var name: UILabel!
  @IBOutlet weak var status: UILabel!
  @IBOutlet weak var popularity: UILabel!
  @IBOutlet weak var bestMatch: UILabel!
  @IBOutlet weak var newest: UILabel!
  @IBOutlet weak var averageRating: UILabel!
  @IBOutlet weak var distance: UILabel!
  @IBOutlet weak var averageProductPrice: UILabel!
  @IBOutlet weak var deliveryCosts: UILabel!
  @IBOutlet weak var minimumCosts: UILabel!
  @IBOutlet weak var favoriteButton: UIButton!
  
  override func prepareForReuse() {
    disposeBag = DisposeBag()
  }
  
  func updateWithRestaurant(restaurantViewModel: RestaurantViewModel) {
    self.restaurantViewModel = restaurantViewModel
    
    let restaurant = restaurantViewModel.item
    
    name.text = restaurant.name
    status.text = restaurant.status
    popularity.text = String(format: "%.2f", restaurant.popularity)
    bestMatch.text = String(format: "%.2f", restaurant.bestMatch)
    newest.text = String(format: "%.2f", restaurant.newest)
    averageRating.text = String(format: "%.2f", restaurant.ratingAverage)
    distance.text = String(restaurant.distance)
    averageProductPrice.text = String(restaurant.averageProductPrice)
    deliveryCosts.text = String(restaurant.deliveryCosts)
    minimumCosts.text = String(restaurant.minCost)
    
    self.setFavorite(restaurantViewModel.isFavorite())
    
    bindObservers()
  }
  
  func bindObservers() {
    favoriteButton.rx.tap.asDriver()
      .map({ [weak self] (_) -> Bool in
        self?.restaurantViewModel?.toggleFavorite()
        return self?.restaurantViewModel?.isFavorite() ?? false
      })
      .drive(onNext: { [weak self] isFavorite in
        self?.setFavorite(isFavorite)
        self?.favoriteRelay.accept(isFavorite)
      })
      .disposed(by: disposeBag)
  }
  
  private func setFavorite(_ isFavorite: Bool) {
    DispatchQueue.main.async { [weak self] in
      if (isFavorite) {
        self?.favoriteButton.imageView?.image = #imageLiteral(resourceName: "active")
      } else {
        self?.favoriteButton.imageView?.image = #imageLiteral(resourceName: "inactive")
      }
    }
  }
}
