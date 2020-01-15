//
//  TakeAwayNowAPI.swift
//  TakeAwayNow
//
//  Created by Reshma Unnikrishnan on 10.01.20.
//  Copyright © 2020 ruvlmoon. All rights reserved.
//

import Foundation

struct TakeAwayNowAPI {
  static let baseUrl = "https://www.takeway.com"
}

/// API endpoints
public enum TakeAwayNowAPIEndPoint {
  case showRestaurants
}

/// End point types
public protocol EndpointType {
  var url: String { get }
  var path: String { get }
}

/// Extension to the endpoint type
extension TakeAwayNowAPIEndPoint: EndpointType {
  public var path: String {
    switch self {
    case .showRestaurants:
      return "restaurants"
    }
  }
  
  public var url: String {
    switch self {
    case .showRestaurants:
      return "\(TakeAwayNowAPI.baseUrl)/\(path)"
    }
  }
}
