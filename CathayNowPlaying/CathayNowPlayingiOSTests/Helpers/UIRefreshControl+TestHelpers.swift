//
//  UIRefreshControl+TestHelpers.swift
//  CathayNowPlayingiOSTests
//
//  Created by SUNG HAO LIN on 2021/8/29.
//

import UIKit

extension UIRefreshControl {
  func simulatePullToRefresh() {
    simulate(event: .valueChanged)
  }
}
