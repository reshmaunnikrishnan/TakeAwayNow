//
//  SortableRestaurantsViewModel.swift
//  TakeAwayNow
//
//  Created by Reshma Unnikrishnan on 14.01.20.
//  Copyright © 2020 ruvlmoon. All rights reserved.
//

import Foundation

enum SortType: String {
  case bestMatch = "bestMatch"
  case newest = "newest"
  case ratingAverage = "ratingAverage"
  case distance = "distance"
  case popularity = "popularity"
  case averageProductPrice = "averageProductPrice"
  case deliveryCosts = "deliveryCosts"
  case minCost = "minCost"
}

protocol SortableRestaurantsViewModelType {
  var items: [RestaurantViewModel] { get set }
  var currentSortType: SortType { get set }
  
  func append(restaurantViewModel: RestaurantViewModel)
  
  func sortAndStoreBy(title: SortType)
  func sortNow()
  func clear()
}

class SortableRestaurantsViewModel: SortableRestaurantsViewModelType {
  var items: [RestaurantViewModel] = [RestaurantViewModel]()
  var currentSortType: SortType = .bestMatch
 
  func append(restaurantViewModel: RestaurantViewModel) {
    items.append(restaurantViewModel)
  }
  
  private func sortFunc(attribute: SortType) -> ((RestaurantViewModel, RestaurantViewModel) -> Bool) {
    func actualSort(a: RestaurantViewModel, b: RestaurantViewModel) -> Bool {
      if (a.isFavorite() == b.isFavorite()) {
        if (a.status() == b.status()) {
          switch attribute {
          case .averageProductPrice:
            return a.item.averageProductPrice < b.item.averageProductPrice
          case .bestMatch:
            return a.item.bestMatch > b.item.bestMatch
          case .deliveryCosts:
            return a.item.deliveryCosts < b.item.deliveryCosts
          case .distance:
            return a.item.distance < b.item.distance
          case .minCost:
            return a.item.minCost < b.item.minCost
          case .newest:
            return a.item.newest > b.item.newest
          case .popularity:
            return a.item.popularity > b.item.popularity
          case .ratingAverage:
            return a.item.ratingAverage > b.item.ratingAverage
          }
          
        } else {
          return a.status() < b.status()
        }
      } else {
        return a.isFavorite()
      }
    }
    
    return actualSort
  }
  
  func sortAndStoreBy(title: SortType) {
    currentSortType = title
    sortNow()
  }
  
  func sortNow() {
    items = items.sorted(by: sortFunc(attribute: currentSortType))
  }
  
  func clear() {
    items = []
  }
}
