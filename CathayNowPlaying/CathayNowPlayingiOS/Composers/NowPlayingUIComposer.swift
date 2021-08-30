//
//  NowPlayingUIComposer.swift
//  CathayNowPlayingiOS
//
//  Created by SUNG HAO LIN on 2021/8/29.
//

import Foundation
import CathayNowPlaying

public final class NowPlayingUIComposer {
  private init() {}

  public static func compose(loader: NowPlayingLoader) -> NowPlayingViewController {
    let adapter = NowPlayingPresentationAdapter(loader: loader)
    let refreshController = NowPlayingRefreshController(delegate: adapter)
    let viewController = NowPlayingViewController(refreshController: refreshController)

    adapter.presenter = NowPlayingPresenter(view: WeakRefVirtualProxy(viewController),
                                            loadingView: WeakRefVirtualProxy(refreshController),
                                            errorView: WeakRefVirtualProxy(viewController))
    return viewController
  }
}

extension WeakRefVirtualProxy: NowPlayingView where T: NowPlayingView {
  public func display(_ viewModel: NowPlayingViewModel) {
    object?.display(viewModel)
  }
}

extension WeakRefVirtualProxy: NowPlayingLoadingView where T: NowPlayingLoadingView {
  public func display(_ viewModel: NowPlayingLoadingViewModel) {
    object?.display(viewModel)
  }
}

extension WeakRefVirtualProxy: NowPlayingErrorView where T: NowPlayingErrorView {
  public func display(_ viewModel: NowPlayingErrorViewModel) {
    object?.display(viewModel)
  }
}