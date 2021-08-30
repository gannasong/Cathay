//
//  NowPlayingCardFeedCell+TestHelpers.swift
//  CathayNowPlayingiOSTests
//
//  Created by SUNG HAO LIN on 2021/8/30.
//

import Foundation
import CathayNowPlayingiOS

extension NowPlayingCardFeedCell {
  var loadingIndicatorIsVisible: Bool {
    return isShimmering
  }

  var renderedImage: Data? {
    return imageView.image?.pngData()
  }
}
