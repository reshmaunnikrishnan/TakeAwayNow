//
//  SortOptionsViewModel.swift
//  TakeAwayNow
//
//  Created by Reshma Unnikrishnan on 12.01.20.
//  Copyright © 2020 ruvlmoon. All rights reserved.
//

import RxSwift
import RxCocoa

public struct SortOptions {
  let sortType: SortType
}

protocol SortOptionsModelType {
  var task: PublishSubject<SortOptions> { get }
  
  func changeSort(sortType: SortType)
}

final class SortOptionsViewModel: SortOptionsModelType {
  let task = PublishSubject<SortOptions>()
  
  func changeSort(sortType: SortType) {
    task.onNext(SortOptions(sortType: sortType))
  }
}
