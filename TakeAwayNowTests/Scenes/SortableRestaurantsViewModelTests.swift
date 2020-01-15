//
//  SortableRestaurantsViewModelTests.swift
//  TakeAwayNowTests
//
//  Created by Reshma Unnikrishnan on 15.01.20.
//  Copyright © 2020 ruvlmoon. All rights reserved.
//

import XCTest

@testable import TakeAwayNow

class Mock2UserDefaults: UserDefaults {
  override func set(_ value: Any?, forKey defaultName: String) {}
}

class SortableRestaurantsViewModelTests: XCTestCase {
  var subject: SortableRestaurantsViewModel!
  
  override func setUp() {
    subject = SortableRestaurantsViewModel()
  }
  
  override func tearDown() {
    subject = nil
  }

  func testSortNowFavVsNonFavOrder() {
    let favItem = RestaurantViewModel(item: RestaurantViewModelItem(model: Restaurant(name: "testOne", status: "open", sortingValues: Restaurant.SortingValues(bestMatch: 0.1, newest: 0.2, ratingAverage: 0.3, distance: 1, popularity: 2, averageProductPrice: 3, deliveryCosts: 4, minCost: 5))), cacheStore: StorageAPI(defaults: Mock2UserDefaults()))
    favItem.toggleFavorite()

    let nonFavItem = RestaurantViewModel(item: RestaurantViewModelItem(model: Restaurant(name: "testTwo", status: "open", sortingValues: Restaurant.SortingValues(bestMatch: 0.1, newest: 0.2, ratingAverage: 0.3, distance: 1, popularity: 2, averageProductPrice: 3, deliveryCosts: 4, minCost: 5))), cacheStore: StorageAPI(defaults: Mock2UserDefaults()))
    
    subject.items = [nonFavItem, favItem]
    subject.sortNow()
    
    XCTAssertEqual(subject.items, [favItem, nonFavItem])
  }
  
  func testSortNowFavEqualFavButDiffStatusOrder() {
    let openItem = RestaurantViewModel(item: RestaurantViewModelItem(model: Restaurant(name: "testOne", status: "open", sortingValues: Restaurant.SortingValues(bestMatch: 0.1, newest: 0.2, ratingAverage: 0.3, distance: 1, popularity: 2, averageProductPrice: 3, deliveryCosts: 4, minCost: 5))))
    
    let closedItem = RestaurantViewModel(item: RestaurantViewModelItem(model: Restaurant(name: "testTwo", status: "closed", sortingValues: Restaurant.SortingValues(bestMatch: 0.1, newest: 0.2, ratingAverage: 0.3, distance: 1, popularity: 2, averageProductPrice: 3, deliveryCosts: 4, minCost: 5))))
    
    let orderAheadItem = RestaurantViewModel(item: RestaurantViewModelItem(model: Restaurant(name: "testTwo", status: "order ahead", sortingValues: Restaurant.SortingValues(bestMatch: 0.1, newest: 0.2, ratingAverage: 0.3, distance: 1, popularity: 2, averageProductPrice: 3, deliveryCosts: 4, minCost: 5))))
    
    subject.items = [orderAheadItem, closedItem, openItem]
    subject.sortNow()
    
    XCTAssertEqual(subject.items, [openItem, orderAheadItem, closedItem])
  }
  
  func testSortNowSameFavAndStatusForDefaultOrder() {
    let bestMatchOne = RestaurantViewModel(item: RestaurantViewModelItem(model: Restaurant(name: "testOne", status: "open", sortingValues: Restaurant.SortingValues(bestMatch: 1.1, newest: 0.2, ratingAverage: 0.3, distance: 1, popularity: 2, averageProductPrice: 3, deliveryCosts: 4, minCost: 5))))
    
    let bestMatchTwo = RestaurantViewModel(item: RestaurantViewModelItem(model: Restaurant(name: "testTwo", status: "open", sortingValues: Restaurant.SortingValues(bestMatch: 2.3, newest: 0.2, ratingAverage: 0.3, distance: 1, popularity: 2, averageProductPrice: 3, deliveryCosts: 4, minCost: 5))))
    
    let bestMatchThree = RestaurantViewModel(item: RestaurantViewModelItem(model: Restaurant(name: "testThree", status: "open", sortingValues: Restaurant.SortingValues(bestMatch: 3.5, newest: 0.2, ratingAverage: 0.3, distance: 1, popularity: 2, averageProductPrice: 3, deliveryCosts: 4, minCost: 5))))
    
    subject.items = [bestMatchTwo, bestMatchOne, bestMatchThree]
    subject.sortNow()
    
    XCTAssertEqual(subject.items, [bestMatchThree, bestMatchTwo, bestMatchOne])
  }
  
  func testSortAndStoreBySameFavAndStatusForProductPriceOrder() {
    let productPriceOne = RestaurantViewModel(item: RestaurantViewModelItem(model: Restaurant(name: "testOne", status: "open", sortingValues: Restaurant.SortingValues(bestMatch: 1.1, newest: 0.2, ratingAverage: 0.3, distance: 1, popularity: 2, averageProductPrice: 3, deliveryCosts: 4, minCost: 5))))
    
    let productPriceTwo = RestaurantViewModel(item: RestaurantViewModelItem(model: Restaurant(name: "testTwo", status: "open", sortingValues: Restaurant.SortingValues(bestMatch: 2.3, newest: 0.2, ratingAverage: 0.3, distance: 1, popularity: 2, averageProductPrice: 4, deliveryCosts: 4, minCost: 5))))
    
    let productPriceThree = RestaurantViewModel(item: RestaurantViewModelItem(model: Restaurant(name: "testThree", status: "open", sortingValues: Restaurant.SortingValues(bestMatch: 3.5, newest: 0.2, ratingAverage: 0.3, distance: 1, popularity: 2, averageProductPrice: 5, deliveryCosts: 4, minCost: 5))))
    
    subject.items = [productPriceTwo, productPriceOne, productPriceThree]
    subject.sortAndStoreBy(title: .averageProductPrice)
    
    XCTAssertEqual(subject.items, [productPriceOne, productPriceTwo, productPriceThree])
  }
  
  func testSortAndStoreBySameFavAndStatusForDeliveryCost() {
    let deliveryCostOne = RestaurantViewModel(item: RestaurantViewModelItem(model: Restaurant(name: "testOne", status: "open", sortingValues: Restaurant.SortingValues(bestMatch: 1.1, newest: 0.2, ratingAverage: 0.3, distance: 1, popularity: 2, averageProductPrice: 3, deliveryCosts: 2, minCost: 5))))
    
    let deliveryCostTwo = RestaurantViewModel(item: RestaurantViewModelItem(model: Restaurant(name: "testTwo", status: "open", sortingValues: Restaurant.SortingValues(bestMatch: 2.3, newest: 0.2, ratingAverage: 0.3, distance: 1, popularity: 2, averageProductPrice: 4, deliveryCosts: 3, minCost: 5))))
    
    let deliveryCostThree = RestaurantViewModel(item: RestaurantViewModelItem(model: Restaurant(name: "testThree", status: "open", sortingValues: Restaurant.SortingValues(bestMatch: 3.5, newest: 0.2, ratingAverage: 0.3, distance: 1, popularity: 2, averageProductPrice: 5, deliveryCosts: 4, minCost: 5))))
    
    subject.items = [deliveryCostTwo, deliveryCostOne, deliveryCostThree]
    subject.sortAndStoreBy(title: .deliveryCosts)
    
    XCTAssertEqual(subject.items, [deliveryCostOne, deliveryCostTwo, deliveryCostThree])
  }
  
  func testSortAndStoreBySameFavAndStatusForDistance() {
    let distanceOne = RestaurantViewModel(item: RestaurantViewModelItem(model: Restaurant(name: "testOne", status: "open", sortingValues: Restaurant.SortingValues(bestMatch: 1.1, newest: 0.2, ratingAverage: 0.3, distance: 1, popularity: 2, averageProductPrice: 3, deliveryCosts: 2, minCost: 5))))
    
    let distanceTwo = RestaurantViewModel(item: RestaurantViewModelItem(model: Restaurant(name: "testTwo", status: "open", sortingValues: Restaurant.SortingValues(bestMatch: 2.3, newest: 0.2, ratingAverage: 0.3, distance: 3, popularity: 2, averageProductPrice: 4, deliveryCosts: 3, minCost: 5))))
    
    let distanceThree = RestaurantViewModel(item: RestaurantViewModelItem(model: Restaurant(name: "testThree", status: "open", sortingValues: Restaurant.SortingValues(bestMatch: 3.5, newest: 0.2, ratingAverage: 0.3, distance: 4, popularity: 2, averageProductPrice: 5, deliveryCosts: 4, minCost: 5))))
    
    subject.items = [distanceTwo, distanceOne, distanceThree]
    subject.sortAndStoreBy(title: .distance)
    
    XCTAssertEqual(subject.items, [distanceOne, distanceTwo, distanceThree])
  }
  
  func testSortAndStoreBySameFavAndStatusForMinCost() {
    let minCostOne = RestaurantViewModel(item: RestaurantViewModelItem(model: Restaurant(name: "testOne", status: "open", sortingValues: Restaurant.SortingValues(bestMatch: 1.1, newest: 0.2, ratingAverage: 0.3, distance: 1, popularity: 2, averageProductPrice: 3, deliveryCosts: 2, minCost: 2))))
    
    let minCostTwo = RestaurantViewModel(item: RestaurantViewModelItem(model: Restaurant(name: "testTwo", status: "open", sortingValues: Restaurant.SortingValues(bestMatch: 2.3, newest: 0.2, ratingAverage: 0.3, distance: 3, popularity: 2, averageProductPrice: 4, deliveryCosts: 3, minCost: 3))))
    
    let minCostThree = RestaurantViewModel(item: RestaurantViewModelItem(model: Restaurant(name: "testThree", status: "open", sortingValues: Restaurant.SortingValues(bestMatch: 3.5, newest: 0.2, ratingAverage: 0.3, distance: 4, popularity: 2, averageProductPrice: 5, deliveryCosts: 4, minCost: 5))))
    
    subject.items = [minCostTwo, minCostOne, minCostThree]
    subject.sortAndStoreBy(title: .minCost)
    
    XCTAssertEqual(subject.items, [minCostOne, minCostTwo, minCostThree])
  }
  
  func testSortAndStoreBySameFavAndStatusForNewest() {
    let newestOne = RestaurantViewModel(item: RestaurantViewModelItem(model: Restaurant(name: "testOne", status: "open", sortingValues: Restaurant.SortingValues(bestMatch: 1.1, newest: 1.2, ratingAverage: 0.3, distance: 1, popularity: 2, averageProductPrice: 3, deliveryCosts: 2, minCost: 2))))
    
    let newestTwo = RestaurantViewModel(item: RestaurantViewModelItem(model: Restaurant(name: "testTwo", status: "open", sortingValues: Restaurant.SortingValues(bestMatch: 2.3, newest: 3.4, ratingAverage: 0.3, distance: 3, popularity: 2, averageProductPrice: 4, deliveryCosts: 3, minCost: 3))))
    
    let newestThree = RestaurantViewModel(item: RestaurantViewModelItem(model: Restaurant(name: "testThree", status: "open", sortingValues: Restaurant.SortingValues(bestMatch: 3.5, newest: 6.2, ratingAverage: 0.3, distance: 4, popularity: 2, averageProductPrice: 5, deliveryCosts: 4, minCost: 5))))
    
    subject.items = [newestTwo, newestOne, newestThree]
    subject.sortAndStoreBy(title: .newest)
    
    XCTAssertEqual(subject.items, [newestThree, newestTwo, newestOne])
  }
  
  func testSortAndStoreBySameFavAndStatusForPopularity() {
    let popularityOne = RestaurantViewModel(item: RestaurantViewModelItem(model: Restaurant(name: "testOne", status: "open", sortingValues: Restaurant.SortingValues(bestMatch: 1.1, newest: 1.2, ratingAverage: 0.3, distance: 1, popularity: 2, averageProductPrice: 3, deliveryCosts: 2, minCost: 2))))
    
    let popularityTwo = RestaurantViewModel(item: RestaurantViewModelItem(model: Restaurant(name: "testTwo", status: "open", sortingValues: Restaurant.SortingValues(bestMatch: 2.3, newest: 3.4, ratingAverage: 0.3, distance: 3, popularity: 4, averageProductPrice: 4, deliveryCosts: 3, minCost: 3))))
    
    let popularityThree = RestaurantViewModel(item: RestaurantViewModelItem(model: Restaurant(name: "testThree", status: "open", sortingValues: Restaurant.SortingValues(bestMatch: 3.5, newest: 6.2, ratingAverage: 0.3, distance: 4, popularity: 6, averageProductPrice: 5, deliveryCosts: 4, minCost: 5))))
    
    subject.items = [popularityTwo, popularityOne, popularityThree]
    subject.sortAndStoreBy(title: .popularity)
    
    XCTAssertEqual(subject.items, [popularityThree, popularityTwo, popularityOne])
  }
  
  func testSortAndStoreBySameFavAndStatusForRatingAverage() {
    let ratingAverageOne = RestaurantViewModel(item: RestaurantViewModelItem(model: Restaurant(name: "testOne", status: "open", sortingValues: Restaurant.SortingValues(bestMatch: 1.1, newest: 1.2, ratingAverage: 0.3, distance: 1, popularity: 2, averageProductPrice: 3, deliveryCosts: 2, minCost: 2))))
    
    let ratingAverageTwo = RestaurantViewModel(item: RestaurantViewModelItem(model: Restaurant(name: "testTwo", status: "open", sortingValues: Restaurant.SortingValues(bestMatch: 2.3, newest: 3.4, ratingAverage: 4.3, distance: 3, popularity: 4, averageProductPrice: 4, deliveryCosts: 3, minCost: 3))))
    
    let ratingAverageThree = RestaurantViewModel(item: RestaurantViewModelItem(model: Restaurant(name: "testThree", status: "open", sortingValues: Restaurant.SortingValues(bestMatch: 3.5, newest: 6.2, ratingAverage: 8.3, distance: 4, popularity: 6, averageProductPrice: 5, deliveryCosts: 4, minCost: 5))))
    
    subject.items = [ratingAverageTwo, ratingAverageOne, ratingAverageThree]
    subject.sortAndStoreBy(title: .popularity)
    
    XCTAssertEqual(subject.items, [ratingAverageThree, ratingAverageTwo, ratingAverageOne])
  }
}
