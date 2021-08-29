//
//  UIControl+TestHelpers.swift
//  CathayNowPlayingiOSTests
//
//  Created by SUNG HAO LIN on 2021/8/29.
//

import UIKit

extension UIControl {
  func simulate(event: UIControl.Event) {
    allTargets.forEach { target in
      actions(forTarget: target, forControlEvent: event)?.forEach {
        (target as NSObject).perform(Selector($0))
      }
    }
  }
}
