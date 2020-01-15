//
//  StorageAPI.swift
//  TakeAwayNow
//
//  Created by Reshma Unnikrishnan on 14.01.20.
//  Copyright © 2020 ruvlmoon. All rights reserved.
//

import Foundation

protocol CacheStoreType {
  func isFavorite(item: String) -> Bool
  func addFavorite(item: String)
  func removeFavorite(item: String)
}

class StorageAPI: CacheStoreType {
  static let shared = StorageAPI()
  
  let defaults: UserDefaults
  let defaultKey: String
  
  var items: [String]
    
  init(defaults: UserDefaults = UserDefaults.standard, defaultkey: String = "userfavorites") {
    self.defaults = defaults
    self.defaultKey = defaultkey
    
    items = defaults.stringArray(forKey: defaultKey) ?? [String]()
  }
  
  func addFavorite(item: String) {
    if !self.items.contains(item) {
      self.items.append(item)
      saveValues()
    }
  }
  
  func removeFavorite(item: String) {
    guard let index = self.items.firstIndex(of: item) else { return }
    
    self.items.remove(at: index)
    saveValues()
  }
  
  func isFavorite(item: String) -> Bool {
    return self.items.contains(item)
  }
  
  private func saveValues() {
    defaults.set(items, forKey: defaultKey)
  }
}
