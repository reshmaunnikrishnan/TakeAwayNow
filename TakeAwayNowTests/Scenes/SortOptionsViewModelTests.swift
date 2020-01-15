//
//  SortOptionsViewModelTests.swift
//  TakeAwayNowTests
//
//  Created by Reshma Unnikrishnan on 15.01.20.
//  Copyright © 2020 ruvlmoon. All rights reserved.
//

import XCTest
import RxSwift
import RxTest

@testable import TakeAwayNow

class SortOptionsViewModelTests: XCTestCase {
  var subject: SortOptionsViewModel!
  
  var scheduler: TestScheduler!
  var disposeBag: DisposeBag!
  
  override func setUp() {
    subject = SortOptionsViewModel()
    
    scheduler = TestScheduler(initialClock: 0)
    disposeBag = DisposeBag()
  }
  
  override func tearDown() {
    subject = nil
    
    scheduler = nil
    disposeBag = nil
  }
  
  func testChangeSortDoesOnNext() {
    let observer = scheduler.createObserver(SortOptions.self)
    
    subject
      .task
      .subscribe(observer)
      .disposed(by: disposeBag)
    
    scheduler.scheduleAt(30) {
      self
        .subject
        .changeSort(sortType: .averageProductPrice)
    }
    
    scheduler.start()
    
    XCTAssertEqual(observer.events.count, 1)
    XCTAssertEqual(observer.events.first?.value.element?.sortType, SortType.averageProductPrice)

  }
}
