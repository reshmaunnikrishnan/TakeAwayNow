//
//  RestaurantsViewModelInputTests.swift
//  TakeAwayNowTests
//
//  Created by Reshma Unnikrishnan on 15.01.20.
//  Copyright © 2020 ruvlmoon. All rights reserved.
//

import XCTest
import RxSwift
import RxCocoa
import RxTest

@testable import TakeAwayNow

class MockRestaurantAccessAPI: RestaurantAccessAPI {
  var restaurants: [Restaurant] = []
  
  func fetchRestaurants(data: RequestData) -> Observable<[Restaurant]?> {
    return TestableObservable.of(restaurants)
  }
}

class MockSortableRestaurantsViewModel: SortableRestaurantsViewModel {
  var appendExpectation: XCTestExpectation?
  var sortAndStoreByExpectation: XCTestExpectation?
  var sortNowExpectation: XCTestExpectation?
  var clearExpectation: XCTestExpectation?
  
  override func append(restaurantViewModel: RestaurantViewModel) {
    appendExpectation?.fulfill()
    super.append(restaurantViewModel: restaurantViewModel)
  }
  
  override func sortAndStoreBy(title: SortType) {
    sortAndStoreByExpectation?.fulfill()
    super.sortAndStoreBy(title: title)
  }
  
  override func sortNow() {
    sortNowExpectation?.fulfill()
    super.sortNow()
  }
  
  override func clear() {
    clearExpectation?.fulfill()
    super.clear()
  }
}

class RestaurantsViewModelTests: XCTestCase {
  var restaurantOne: Restaurant!
  var restaurantTwo: Restaurant!
  
  var restaurantViewModelOne: RestaurantViewModel!
  var restaurantViewModelTwo: RestaurantViewModel!
  
  var sortableRestaurantsViewModel: MockSortableRestaurantsViewModel!
  
  var restaurantAcessAPI: MockRestaurantAccessAPI!
  var subject: RestaurantsViewModel!
  
  var scheduler: TestScheduler!
  var disposeBag: DisposeBag!
  
  override func setUp() {
    restaurantOne = Restaurant(name: "Indian Curry", status: "open", sortingValues: Restaurant.SortingValues(bestMatch: 0.1, newest: 0.2, ratingAverage: 0.3, distance: 1, popularity: 2, averageProductPrice: 3, deliveryCosts: 4, minCost: 5))
    restaurantViewModelOne = RestaurantViewModel(item: RestaurantViewModelItem(model: restaurantOne))
    
    restaurantTwo = Restaurant(name: "German Sauce", status: "open", sortingValues: Restaurant.SortingValues(bestMatch: 0.1, newest: 0.2, ratingAverage: 0.3, distance: 1, popularity: 2, averageProductPrice: 3, deliveryCosts: 4, minCost: 5))
    restaurantViewModelTwo = RestaurantViewModel(item: RestaurantViewModelItem(model: restaurantTwo))
    
    restaurantAcessAPI = MockRestaurantAccessAPI()
    restaurantAcessAPI.restaurants = [
      restaurantOne,
      restaurantTwo
    ]
    
    subject = RestaurantsViewModel(networkAPI: restaurantAcessAPI)
    
    sortableRestaurantsViewModel = MockSortableRestaurantsViewModel()
    sortableRestaurantsViewModel.items = [
      restaurantViewModelOne,
      restaurantViewModelTwo
    ]
    
    subject.sortableRestaurantsViewModel = sortableRestaurantsViewModel
    
    scheduler = TestScheduler(initialClock: 0)
    disposeBag = DisposeBag()
  }
  
  override func tearDown() {
    restaurantOne = nil
    restaurantTwo = nil
    
    restaurantViewModelOne = nil
    restaurantViewModelTwo = nil
    
    sortableRestaurantsViewModel = nil
    
    restaurantAcessAPI = nil
    subject = nil
    scheduler = nil
    disposeBag = nil
  }
  
  func testViewAppearTriggerOnTransformCall() {
    sortableRestaurantsViewModel.clearExpectation = expectation(description: "clear")
    sortableRestaurantsViewModel.sortNowExpectation = expectation(description: "sortNow")
    sortableRestaurantsViewModel.appendExpectation = expectation(description: "append")
    sortableRestaurantsViewModel.appendExpectation?.expectedFulfillmentCount = restaurantAcessAPI.restaurants.count
    
    let viewAppearObservable = scheduler.createHotObservable([
      .next(50, ())
    ])

    let observer = scheduler.createObserver([RestaurantViewModel].self)

    let input = RestaurantsViewModel.Input(
                  viewAppearTrigger: viewAppearObservable.asDriverComplete(),
                  sortTrigger: Driver.of(),
                  favoriteTrigger: Driver.of(),
                  searchTextTrigger: Driver.of())

    let _ = subject.transform(input: input)

    scheduler.scheduleAt(30) {
      self
        .subject
        .restaurantsRelay
        .subscribe(observer)
        .disposed(by: self.disposeBag)
    }

    scheduler.start()
    
    waitForExpectations(timeout: 5, handler: nil)

    XCTAssertEqual(observer.events.count, 1)
    XCTAssertEqual(observer.events.first?.value.element?.count, 2)
    XCTAssertEqual(observer.events.last?.value.element?.first?.item.name, restaurantOne.name)
    XCTAssertEqual(observer.events.last?.value.element?.last?.item.name, restaurantTwo.name)
    
  }
  
  func testSearchTextTriggerOnTransformCall() {
    let searchObservable = scheduler.createHotObservable([
      .next(120, "Indian")
    ])
    
    let observer = scheduler.createObserver([RestaurantViewModel].self)
    
    let input = RestaurantsViewModel.Input(
                  viewAppearTrigger: Driver.of(),
                  sortTrigger: Driver.of(),
                  favoriteTrigger: Driver.of(),
                  searchTextTrigger: searchObservable.asDriverComplete())
    
    let _ = subject.transform(input: input)
    
    scheduler.scheduleAt(30) {
      self
        .subject
        .restaurantsRelay
        .subscribe(observer)
        .disposed(by: self.disposeBag)
    }
    
    scheduler.start()
    
    XCTAssertEqual(observer.events.count, 1)
    XCTAssertEqual(observer.events.last?.value.element?.first?.item.name, restaurantOne.name)
  }
  
  func testFavoriteTriggerOnTransformCall() {
    sortableRestaurantsViewModel.sortNowExpectation = expectation(description: "sortNow")
    
    let favoriteObservable = scheduler.createHotObservable([
      .next(120, true)
    ])
    
    let observer = scheduler.createObserver([RestaurantViewModel].self)
    
    let input = RestaurantsViewModel.Input(
                  viewAppearTrigger: Driver.of(),
                  sortTrigger: Driver.of(),
                  favoriteTrigger: favoriteObservable.asDriverComplete(),
                  searchTextTrigger: Driver.of())
    
    let _ = subject.transform(input: input)
    
    scheduler.scheduleAt(30) {
      self
        .subject
        .restaurantsRelay
        .subscribe(observer)
        .disposed(by: self.disposeBag)
    }
    
    scheduler.start()
    
    waitForExpectations(timeout: 5, handler: nil)

    XCTAssertEqual(observer.events.count, 1)
    XCTAssertEqual(observer.events.first?.value.element?.count, 2)
    XCTAssertEqual(observer.events.last?.value.element?.first?.item.name, restaurantOne.name)
    XCTAssertEqual(observer.events.last?.value.element?.last?.item.name, restaurantTwo.name)
  }
  
  func testSortTriggerOnTransformCall() {
    sortableRestaurantsViewModel.sortAndStoreByExpectation = expectation(description: "sortAndStoreBy")
    
    let sortObservable = scheduler.createHotObservable([
      .next(120, SortType.bestMatch)
    ])
    
    let observer = scheduler.createObserver([RestaurantViewModel].self)
    
    let input = RestaurantsViewModel.Input(
                  viewAppearTrigger: Driver.of(),
                  sortTrigger: sortObservable.asDriverComplete(),
                  favoriteTrigger: Driver.of(),
                  searchTextTrigger: Driver.of())
    
    let _ = subject.transform(input: input)
    
    scheduler.scheduleAt(30) {
      self
        .subject
        .restaurantsRelay
        .subscribe(observer)
        .disposed(by: self.disposeBag)
    }
    
    scheduler.start()
    
    waitForExpectations(timeout: 5, handler: nil)

    XCTAssertEqual(observer.events.count, 1)
    XCTAssertEqual(observer.events.first?.value.element?.count, 2)
    XCTAssertEqual(observer.events.last?.value.element?.first?.item.name, restaurantOne.name)
    XCTAssertEqual(observer.events.last?.value.element?.last?.item.name, restaurantTwo.name)
  }
}

