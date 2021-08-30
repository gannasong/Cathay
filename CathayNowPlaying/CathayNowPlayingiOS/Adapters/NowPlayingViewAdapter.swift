//
//  NowPlayingViewAdapter.swift
//  CathayNowPlayingiOS
//
//  Created by SUNG HAO LIN on 2021/8/30.
//

import Foundation
import CathayMedia
import CathayNowPlaying

final class NowPlayingViewAdapter {

  private weak var controller: NowPlayingViewController?
  private let imageLoader: ImageDataLoader

  init(controller: NowPlayingViewController, imageLoader: ImageDataLoader) {
    self.controller = controller
    self.imageLoader = imageLoader
  }
}

extension NowPlayingViewAdapter: NowPlayingView {
  func display(_ viewModel: NowPlayingViewModel) {
    controller?.items = viewModel.items
  }
}
