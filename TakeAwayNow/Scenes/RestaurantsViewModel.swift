//
//  RestaurantsViewModel.swift
//  TakeAwayNow
//
//  Created by Reshma Unnikrishnan on 10.01.20.
//  Copyright © 2020 ruvlmoon. All rights reserved.
//

import RxSwift
import RxCocoa

protocol RestaurantsViewModelInput {
  var viewAppearTrigger: Driver<Void> { get }
  var sortTrigger: Driver<SortType> { get }
  var favoriteTrigger: Driver<Bool> { get }
  var searchTextTrigger: Driver<String> { get }
}

protocol RestaurantsViewModelOutput {
  var restaurantsViewModel: Driver<[RestaurantViewModel]> { get }
}

protocol RestaurantsViewModelType {
  var networkAPI: RestaurantAccessAPI { get set }
  var input: RestaurantsViewModelInput { get set }
  var output: RestaurantsViewModelOutput { get set }
  
  func transform(input: RestaurantsViewModelInput) -> RestaurantsViewModelOutput
}

final class RestaurantsViewModel: RestaurantsViewModelType {
  var sortableRestaurantsViewModel: SortableRestaurantsViewModel
  var restaurantsRelay = PublishRelay<[RestaurantViewModel]>()
  
  struct Input: RestaurantsViewModelInput {
    var viewAppearTrigger: Driver<Void>
    var sortTrigger: Driver<SortType>
    var favoriteTrigger: Driver<Bool>
    var searchTextTrigger: Driver<String>
  }
  
  struct Output: RestaurantsViewModelOutput {
    var restaurantsViewModel: Driver<[RestaurantViewModel]>
  }
  
  private var disposeBag = DisposeBag()
  
  var networkAPI: RestaurantAccessAPI
  var input: RestaurantsViewModelInput
  var output: RestaurantsViewModelOutput
  
  init(networkAPI: RestaurantAccessAPI = LocalFileAPI()) {
    self.networkAPI = networkAPI
    self.input = Input(viewAppearTrigger: Driver.of(), sortTrigger: Driver.of(), favoriteTrigger: Driver.of(), searchTextTrigger: Driver.of())
    self.output = Output(restaurantsViewModel:  Driver.of([]))
    self.sortableRestaurantsViewModel = SortableRestaurantsViewModel()
  }
  
  func transform(input: RestaurantsViewModelInput) -> RestaurantsViewModelOutput {
    self.input = input
    
    input.searchTextTrigger
      .drive(onNext: { [weak self] (searchText) in
        guard let self = self else { return }
        let filteredItems = self.sortableRestaurantsViewModel.items.filter { $0.item.name.hasPrefix(searchText)}
        self.restaurantsRelay.accept(filteredItems)
      }).disposed(by: disposeBag)
    
    input.favoriteTrigger
      .drive(onNext: { [weak self] title in
        self?.sortableRestaurantsViewModel.sortNow()
        self?.restaurantsRelay.accept(self?.sortableRestaurantsViewModel.items ?? [])
      }).disposed(by: disposeBag)
    
    input.sortTrigger
      .drive(onNext: { [weak self] title in
        self?.sortableRestaurantsViewModel.sortAndStoreBy(title: title)
        self?.restaurantsRelay.accept(self?.sortableRestaurantsViewModel.items ?? [])
      }).disposed(by: disposeBag)
    
    input.viewAppearTrigger
      .drive(onNext: { [weak self] in
        guard let self = self else { return }
        
        self.networkAPI
          .fetchRestaurants(data: RequestData(path: TakeAwayNowAPIEndPoint.showRestaurants.path))
          .subscribe(onNext: { [weak self] restaurants in
            guard let restaurants = restaurants else { return }
            
            self?.sortableRestaurantsViewModel.clear()
            
            for restaurant in restaurants {
              let viewModelItem = RestaurantViewModelItem(model: restaurant)
              let viewModel = RestaurantViewModel(item: viewModelItem)
              self?.sortableRestaurantsViewModel.append(restaurantViewModel: viewModel)
            }
            
            self?.sortableRestaurantsViewModel.sortNow()
            
            self?.restaurantsRelay.accept(self?.sortableRestaurantsViewModel.items ?? [])
          })
          .disposed(by: self.disposeBag)
        
      })
      .disposed(by: disposeBag)
    
    self.output = Output(restaurantsViewModel: restaurantsRelay.asDriver(onErrorJustReturn: []))
    
    return self.output
  }
}
