//
//  NowPlayingPresentationAdapter.swift
//  CathayNowPlayingiOS
//
//  Created by SUNG HAO LIN on 2021/8/30.
//

import Foundation
import CathayNowPlaying

final class NowPlayingPresentationAdapter: NowPlayingRefreshControllerDelegate {
  var presenter: NowPlayingPresenter?
  private let loader: NowPlayingLoader
  
  init(loader: NowPlayingLoader) {
    self.loader = loader
  }

  func didRequestLoad() {
    presenter?.didStartLoading()
    load(page: 1)
  }

  private func load(page: Int) {
    loader.execute(.init(page: page), completion: { [weak self] result in
      guard let self = self else { return }

      switch result {
      case let .success(feed):
        self.presenter?.didFinishLoading(with: feed)
      case let .failure(error):
        self.presenter?.didFinishLoading(with: error)
      }
    })
  }
}

extension NowPlayingPresentationAdapter: NowPlayingPagingControllerDelegate {
  func didRequestPage(page: Int) {
    load(page: page)
  }
}
