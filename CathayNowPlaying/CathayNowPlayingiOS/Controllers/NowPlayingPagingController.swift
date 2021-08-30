//
//  NowPlayingPagingController.swift
//  CathayNowPlayingiOS
//
//  Created by SUNG HAO LIN on 2021/8/30.
//

import Foundation
import CathayNowPlaying

protocol NowPlayingPagingControllerDelegate {
  func didRequestPage(page: Int)
}

final class NowPlayingPagingController {

  private let delegate: NowPlayingPagingControllerDelegate

  private var isLoading = false
  private var pageNumber: Int = 1
  private var isLast: Bool = false

  init(delegate: NowPlayingPagingControllerDelegate) {
    self.delegate = delegate
  }

  func load() {
    guard !isLoading && !isLast else { return }
    isLoading = true
    delegate.didRequestPage(page: pageNumber + 1)
  }

}

extension NowPlayingPagingController: NowPlayingPagingView {
  func display(_ viewModel: NowPlayingPagingViewModel) {
    isLoading = viewModel.isLoading
    pageNumber = viewModel.pageNumber
    isLast = viewModel.isLast
  }
}
