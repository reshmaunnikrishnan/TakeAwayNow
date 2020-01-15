//
//  ObservableType+extension.swift
//  TakeAwayNow
//
//  Created by Reshma Unnikrishnan on 10.01.20.
//  Copyright © 2020 ruvlmoon. All rights reserved.
//

import RxSwift
import RxCocoa

extension ObservableType {
  func asDriverComplete() -> SharedSequence<DriverSharingStrategy, Element> {
    return asDriver(onErrorRecover: { (error)  in
      return Driver.empty()
    })
  }
  
  func mapToVoid() -> Observable<Void> {
    return map { _ in }
  }
}
