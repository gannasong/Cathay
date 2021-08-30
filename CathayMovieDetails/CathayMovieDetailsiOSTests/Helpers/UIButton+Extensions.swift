//
//  UIButton+Extensions.swift
//  CathayMovieDetailsiOSTests
//
//  Created by SUNG HAO LIN on 2021/8/30.
//

import UIKit

extension UIButton {
  func simulateTap() {
    simulate(event: .touchUpInside)
  }
}
