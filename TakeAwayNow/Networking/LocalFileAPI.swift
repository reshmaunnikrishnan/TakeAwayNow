//
//  LocalFileAPI.swift
//  TakeAwayNow
//
//  Created by Reshma Unnikrishnan on 10.01.20.
//  Copyright © 2020 ruvlmoon. All rights reserved.
//

import Foundation
import RxSwift

public struct RequestData {
  public let path: String
  
  public init (
    path: String
  ) {
    self.path = path
  }
}

protocol RestaurantAccessAPI {
  func fetchRestaurants(data: RequestData) -> Observable<[Restaurant]?>
}

class LocalFileAPI: RestaurantAccessAPI {
    
  func fetchRestaurants(data: RequestData) -> Observable<[Restaurant]?> {
    var restaurants: Restaurants = Restaurants(restaurants: [])
    
    if let path = Bundle.main.path(forResource: data.path, ofType: "json") {
      do {
        let responseData = try Data(contentsOf: URL(fileURLWithPath: path), options: .mappedIfSafe)
        restaurants = try JSONDecoder().decode(Restaurants.self, from: responseData)
      } catch {}
    }
    
    return Observable.create { observer in
      observer.onNext(restaurants.restaurants)
      observer.onCompleted()
      
      return Disposables.create {}
    }
  }
}
