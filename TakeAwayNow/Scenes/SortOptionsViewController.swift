//
//  SortOptionsViewController.swift
//  TakeAwayNow
//
//  Created by Reshma Unnikrishnan on 12.01.20.
//  Copyright © 2020 ruvlmoon. All rights reserved.
//
import UIKit
import RxSwift
import RxCocoa

final class SortOptionsViewController: UIViewController {
  @IBOutlet weak var bestMatchSortButton: UIButton!
  @IBOutlet weak var newestSortButton: UIButton!
  @IBOutlet weak var ratingSortButton: UIButton!
  @IBOutlet weak var distanceSortButton: UIButton!
  @IBOutlet weak var popularityButton: UIButton!
  @IBOutlet weak var deliveryCostButton: UIButton!
  @IBOutlet weak var avgProductPriceButton: UIButton!
  @IBOutlet weak var minimumCostButton: UIButton!
    
  var viewModel: SortOptionsModelType = SortOptionsViewModel()
  
  override func viewDidLoad() {
    super.viewDidLoad()
  }
  
  @IBAction func presentMainView(_ sender: Any) {
    self.dismiss(animated: true, completion: nil)
  }
  
  @IBAction func changeSort(_ sender: UIButton) {
    switch sender {
    case bestMatchSortButton:
      viewModel.changeSort(sortType: .bestMatch)
    case newestSortButton:
      viewModel.changeSort(sortType: .newest)
    case ratingSortButton:
      viewModel.changeSort(sortType: .ratingAverage)
    case distanceSortButton:
      viewModel.changeSort(sortType: .distance)
    case popularityButton:
      viewModel.changeSort(sortType: .popularity)
    case deliveryCostButton:
      viewModel.changeSort(sortType: .deliveryCosts)
    case avgProductPriceButton:
      viewModel.changeSort(sortType: .averageProductPrice)
    case minimumCostButton:
      viewModel.changeSort(sortType: .minCost)
    default:
      viewModel.changeSort(sortType: .bestMatch)
    }
  }
}
