//
//  MovieDetailsViewController+TestHelpers.swift
//  CathayMovieDetailsiOSTests
//
//  Created by SUNG HAO LIN on 2021/8/30.
//

import Foundation
import CathayMovieDetailsiOS

extension MovieDetailsViewController {
  var loadingIndicatorIsVisible: Bool {
    return customView.loadingIndicator.isAnimating
  }
  
  var titleText: String? {
    return customView.titleLabel.text
  }
  
  var metaText: String? {
    return customView.metaLabel.text
  }
  
  var overviewText: String? {
    return customView.overviewLabel.text
  }
  
  func simulateBuyTicket() {
    customView.buyTicketButton.simulateTap()
  }
  
  var renderedImage: Data? {
    return customView.bakcgroundImageView.image?.pngData()
  }
}
