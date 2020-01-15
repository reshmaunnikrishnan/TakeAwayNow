//
//  Restaurant.swift
//  TakeAwayNow
//
//  Created by Reshma Unnikrishnan on 10.01.20.
//  Copyright © 2020 ruvlmoon. All rights reserved.
//

struct Restaurant: Codable {
  struct SortingValues: Codable {
    let bestMatch: Float
    let newest: Float
    let ratingAverage: Float
    let distance: Int
    let popularity: Float
    let averageProductPrice: Int
    let deliveryCosts: Int
    let minCost: Int
  }
  
  let name: String
  let status: String
  let sortingValues: SortingValues
}

struct Restaurants: Codable {
  let restaurants: [Restaurant]
}
