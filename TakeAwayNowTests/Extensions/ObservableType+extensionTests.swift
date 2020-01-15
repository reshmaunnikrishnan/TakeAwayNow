//
//  ObservableType+extensionTests.swift
//  TakeAwayNowTests
//
//  Created by Reshma Unnikrishnan on 14.01.20.
//  Copyright © 2020 ruvlmoon. All rights reserved.
//

import XCTest
import RxSwift
import RxTest

@testable import TakeAwayNow

enum InvalidMockError: Error {
  case Invalid
}

class ObservableType_extensionTests: XCTestCase {
  var disposeBag: DisposeBag!
  var scheduler: TestScheduler!
  
  override func setUp() {
    scheduler = TestScheduler(initialClock: 0)
    disposeBag = DisposeBag()
  }
  
  override func tearDown() {
    scheduler = nil
    disposeBag = nil
  }
  
  func testAsDriverCompleteReturnsDriverEmptyOnError() {
    let observable = scheduler.createHotObservable([
      .next(150, 1),
      .error(180, InvalidMockError.Invalid)
    ])
    let observer = scheduler.createObserver(Int.self)
    
    scheduler.scheduleAt(100) {
      observable
        .asDriverComplete()
        .drive(observer)
        .disposed(by: self.disposeBag)
    }
    
    scheduler.start()
    
    XCTAssertEqual(observer.events, [
      .next(150, 1),
      .completed(180)
    ])
  }
  
  func testMapToVoidReturnsNothing() {
    let observable = scheduler.createHotObservable([
      .next(150, 1),
      .next(180, 2)
    ])
    let observer = scheduler.createObserver(Void.self)
    
    scheduler.scheduleAt(100) {
      observable
        .mapToVoid()
        .subscribe(observer)
        .disposed(by: self.disposeBag)
    }
    
    scheduler.start()
    
    let expectedEvents = [
      Recorded.next(150, ()),
      Recorded.next(180, ())
    ]
    
    XCTAssert("\(observer.events)" == "\(expectedEvents)")
  }
}
