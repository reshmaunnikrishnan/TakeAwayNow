//
//  RestaurantViewModel.swift
//  TakeAwayNow
//
//  Created by Reshma Unnikrishnan on 14.01.20.
//  Copyright © 2020 ruvlmoon. All rights reserved.
//

import Foundation

struct RestaurantViewModelItem {
  let name: String
  let status: String
  let bestMatch: Float
  let newest: Float
  let ratingAverage: Float
  let distance: Int
  let popularity: Float
  let averageProductPrice: Int
  let deliveryCosts: Int
  let minCost: Int
  
  var isFavorite: Bool
}

extension RestaurantViewModelItem {
  init(model: Restaurant, isFavorite: Bool = false) {
    name = model.name
    status = model.status
    bestMatch = model.sortingValues.bestMatch
    newest = model.sortingValues.newest
    ratingAverage = model.sortingValues.ratingAverage
    distance = model.sortingValues.distance
    popularity = model.sortingValues.popularity
    averageProductPrice = model.sortingValues.averageProductPrice
    deliveryCosts = model.sortingValues.deliveryCosts
    minCost = model.sortingValues.minCost
    
    self.isFavorite = isFavorite
  }
}

enum RestaurantStatusType: String, Equatable, Comparable {
  case open = "open"
  case orderAhead = "order ahead"
  case closed = "closed"
  
  public static func < (a: RestaurantStatusType, b: RestaurantStatusType) -> Bool {
    switch (a, b) {
      
    case (.orderAhead, .open):
      return false
      
    case (.closed, .open), (.closed, .orderAhead):
      return false
      
    default:
      return true
    }
  }
}

final class RestaurantViewModel: Equatable {
  var item: RestaurantViewModelItem
  let cacheStore: CacheStoreType
  
  init(item: RestaurantViewModelItem, cacheStore: CacheStoreType = StorageAPI.shared) {
    self.item = item
    self.cacheStore = cacheStore
  }
  
  func toggleFavorite() {
    item.isFavorite = !item.isFavorite
    
    if item.isFavorite {
      cacheStore.addFavorite(item: item.name)
    } else {
      cacheStore.removeFavorite(item: item.name)
    }
  }
  
  func isFavorite() -> Bool {
    item.isFavorite = cacheStore.isFavorite(item: item.name)
    
    return item.isFavorite
  }
  
  func status() -> RestaurantStatusType {
    if item.status == "open" {
      return RestaurantStatusType.open
    } else if item.status == "closed" {
      return RestaurantStatusType.closed
    } else {
      return RestaurantStatusType.orderAhead
    }
  }
}

func ==(lhs: RestaurantViewModel, rhs: RestaurantViewModel) -> Bool {
  return lhs.item.name == rhs.item.name
}
