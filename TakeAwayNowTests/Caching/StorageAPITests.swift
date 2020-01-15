//
//  StorageAPITests.swift
//  TakeAwayNowTests
//
//  Created by Reshma Unnikrishnan on 14.01.20.
//  Copyright © 2020 ruvlmoon. All rights reserved.
//

import XCTest

@testable import TakeAwayNow

class MockUserDefaults: UserDefaults {
  var expectation: XCTestExpectation?
  
  override func set(_ value: Any?, forKey defaultName: String) {
    expectation?.fulfill()
    super.set(value, forKey: defaultName)
  }
}

class StorageAPITests: XCTestCase {
  private var subject: StorageAPI!
  
  var userDefaults: MockUserDefaults!
  
  let testItem: String = "test1"
  let testItemTwo: String = "test2"
  
  override func setUp() {
    userDefaults = MockUserDefaults(suiteName: "storage")
    userDefaults?.removePersistentDomain(forName: "storage")
    
    subject = StorageAPI(defaults: userDefaults, defaultkey: "myFav")
  }
  
  override func tearDown() {
    userDefaults = nil
    subject = nil
  }
 
  func testAddFavoriteAddsToArrayAndCallsUserDefaults() {
    userDefaults.expectation = expectation(description: "addfav")
    
    XCTAssertEqual(subject.items.contains(testItem), false)
    subject.addFavorite(item: testItem)
    XCTAssertEqual(subject.items.contains(testItem), true)
    
    waitForExpectations(timeout: 5, handler: nil)
  }
  
  func testForExistingItemAddFavoriteDoesNothing() {
    subject.items.append(testItem)
    
    userDefaults.expectation = expectation(description: "addfav")
    userDefaults.expectation?.isInverted = true
    
    XCTAssertEqual(subject.items.count, 1)
    subject.addFavorite(item: testItem)
    XCTAssertEqual(subject.items.count, 1)
    
    waitForExpectations(timeout: 5, handler: nil)
  }
  
  func testRemoveFavoriteRemovesFromArrayAndCallsUserDefaults() {
    userDefaults.expectation = expectation(description: "removefav")
    
    subject.items.append(testItem)
    XCTAssertEqual(subject.items.contains(testItem), true)
    subject.removeFavorite(item: testItem)
    XCTAssertEqual(subject.items.contains(testItem), false)
    
    waitForExpectations(timeout: 5, handler: nil)
  }
  
  func testForNonExistingItemRemoveFavoriteDoesNothing() {
    userDefaults.expectation = expectation(description: "removefav")
    userDefaults.expectation?.isInverted = true
    
    subject.items.append(testItemTwo)
    XCTAssertEqual(subject.items.count, 1)
    subject.removeFavorite(item: testItem)
    XCTAssertEqual(subject.items.count, 1)
    
    waitForExpectations(timeout: 5, handler: nil)
  }

  func testIsFavoriteReturnsProperResult() {
    XCTAssertEqual(subject.isFavorite(item: testItem), false)
    subject.items.append(testItem)
    XCTAssertEqual(subject.isFavorite(item: testItem), true)
  }
}
