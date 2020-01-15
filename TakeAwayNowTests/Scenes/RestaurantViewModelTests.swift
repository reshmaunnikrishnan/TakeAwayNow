//
//  RestaurantViewModelTests.swift
//  TakeAwayNowTests
//
//  Created by Reshma Unnikrishnan on 15.01.20.
//  Copyright © 2020 ruvlmoon. All rights reserved.
//

import XCTest

@testable import TakeAwayNow

class MockCacheStore: CacheStoreType {
  var isFavoriteExpectation: XCTestExpectation?
  var addExpectation: XCTestExpectation?
  var removeExpectation: XCTestExpectation?
  
  var favorite: Bool = false
  
  func isFavorite(item: String) -> Bool {
    isFavoriteExpectation?.fulfill()
    return favorite
  }
  
  func addFavorite(item: String) {
    addExpectation?.fulfill()
  }
  
  func removeFavorite(item: String) {
    removeExpectation?.fulfill()
  }
}

class RestaurantViewModelTests: XCTestCase {
  var model: Restaurant!
  var viewModelItem: RestaurantViewModelItem!
  var cacheStore: MockCacheStore!
  var subject: RestaurantViewModel!
  
  override func setUp() {
    model = Restaurant(name: "", status: "open", sortingValues: Restaurant.SortingValues(bestMatch: 0.1, newest: 0.2, ratingAverage: 0.3, distance: 1, popularity: 0.4, averageProductPrice: 2, deliveryCosts: 3, minCost: 4))
    viewModelItem = RestaurantViewModelItem(model: model, isFavorite: false)
    cacheStore = MockCacheStore()
    subject = RestaurantViewModel(item: viewModelItem, cacheStore: cacheStore)
  }
  
  override func tearDown() {
    model = nil
    viewModelItem = nil
    cacheStore = nil
    subject = nil
  }
  
  func testToggleFavoriteSetsFavoriteAndStoresInCache() {
    cacheStore.addExpectation = expectation(description: "toggleFavAdd")
    
    XCTAssertEqual(subject.item.isFavorite, false)
    subject.toggleFavorite()
    XCTAssertEqual(subject.item.isFavorite, true)
    
    waitForExpectations(timeout: 5, handler: nil)
    
    cacheStore.addExpectation = nil
    cacheStore.removeExpectation = expectation(description: "toggleFavRemove")
    
    subject.toggleFavorite()
    XCTAssertEqual(subject.item.isFavorite, false)
    
    waitForExpectations(timeout: 5, handler: nil)
  }
  
  func testIsFavoriteGetsValueFromCacheStore() {
    cacheStore.isFavoriteExpectation = expectation(description: "isFavoriteTrue")
    
    cacheStore.favorite = true
    XCTAssertTrue(subject.isFavorite())
    
    waitForExpectations(timeout: 5, handler: nil)
    
    cacheStore.isFavoriteExpectation = expectation(description: "isFavoriteFalse")
    
    cacheStore.favorite = false
    XCTAssertFalse(subject.isFavorite())
    
    waitForExpectations(timeout: 5, handler: nil)
  }
  
  func testStatusReturnsStatusType() {
    
    XCTAssertEqual(subject.status(), RestaurantStatusType.open)
    
    model = Restaurant(name: "Indian Deli", status: "closed", sortingValues: Restaurant.SortingValues(bestMatch: 0.1, newest: 0.2, ratingAverage: 0.3, distance: 1, popularity: 0.4, averageProductPrice: 2, deliveryCosts: 3, minCost: 4))
    viewModelItem = RestaurantViewModelItem(model: model, isFavorite: false)
    subject = RestaurantViewModel(item: viewModelItem, cacheStore: cacheStore)
    
    XCTAssertEqual(subject.status(), RestaurantStatusType.closed)
    
    model = Restaurant(name: "TacoBell", status: "orderAhead", sortingValues: Restaurant.SortingValues(bestMatch: 0.1, newest: 0.2, ratingAverage: 0.3, distance: 1, popularity: 0.4, averageProductPrice: 5, deliveryCosts: 3, minCost: 8))
    viewModelItem = RestaurantViewModelItem(model: model, isFavorite: false)
    subject = RestaurantViewModel(item: viewModelItem, cacheStore: cacheStore)
    
    XCTAssertEqual(subject.status(), RestaurantStatusType.orderAhead)
  }
}


class RestaurantStatusTypeTests: XCTestCase {
 
  func testWhetherTheStatusTypeDeliversCorrectly() {
  
    let statusType1 = RestaurantStatusType.open
    let statusType2 = RestaurantStatusType.orderAhead
    let statusType3 = RestaurantStatusType.closed
    
    XCTAssertTrue(statusType1 < statusType2)
    XCTAssertTrue(statusType1 < statusType3)
    XCTAssertTrue(statusType2 < statusType3)
    XCTAssertTrue(statusType1 < statusType1)
    XCTAssertTrue(statusType2 < statusType2)
    XCTAssertTrue(statusType3 < statusType3)

    
    XCTAssertFalse(statusType2 < statusType1)
    XCTAssertFalse(statusType3 < statusType1)
    XCTAssertFalse(statusType3 < statusType2)
    
  }
}

