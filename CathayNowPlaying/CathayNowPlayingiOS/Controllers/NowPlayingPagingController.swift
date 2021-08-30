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
  private var viewModel: NowPlayingPagingViewModel?

  init(delegate: NowPlayingPagingControllerDelegate) {
    self.delegate = delegate
  }

  func load() {
    guard let viewModel = viewModel, let nextPage = viewModel.nextPage, !viewModel.isLoading else { return }
    delegate.didRequestPage(page: nextPage)
  }
}

extension NowPlayingPagingController: NowPlayingPagingView {
  func display(_ viewModel: NowPlayingPagingViewModel) {
    self.viewModel = viewModel
  }
}
