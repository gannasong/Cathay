//
//  UIImageView+Extensions.swift
//  CathayNowPlayingiOS
//
//  Created by SUNG HAO LIN on 2021/8/30.
//

import UIKit

extension UIImageView {
  func setImageAnimated(_ newImage: UIImage?) {
    image = newImage

    guard newImage != nil else { return }

    alpha = 0
    UIView.animate(withDuration: 0.25) {
      self.alpha = 1
    }
  }
}
