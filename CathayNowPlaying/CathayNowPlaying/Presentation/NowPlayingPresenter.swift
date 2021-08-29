//
//  NowPlayingPresenter.swift
//  CathayNowPlaying
//
//  Created by SUNG HAO LIN on 2021/8/30.
//

import Foundation

public protocol NowPlayingLoadingView {
  func display(_ viewModel: NowPlayingLoadingViewModel)
}

public protocol NowPlayingErrorView {
  func display(_ viewModel: NowPlayingErrorViewModel)
}

public protocol NowPlayingView {
  func display(_ viewModel: NowPlayingViewModel)
}

public class NowPlayingPresenter {
  private let view: NowPlayingView
  private let loadingView: NowPlayingLoadingView
  private let errorView: NowPlayingErrorView

  public init(view: NowPlayingView, loadingView: NowPlayingLoadingView, errorView: NowPlayingErrorView) {
    self.view = view
    self.loadingView = loadingView
    self.errorView = errorView
  }

  public func didStartLoading() {
    loadingView.display(.init(isLoading: true))
    errorView.display(.noError)
  }

  public func didFinishLoading(with feed: NowPlayingFeed) {
    loadingView.display(.init(isLoading: false))
    view.display(.init(items: feed.items))
  }

  public func didFinishLoading(with error: Error) {
    loadingView.display(.init(isLoading: false))
    errorView.display(.error(message: error.localizedDescription))
  }
}
