//
//  NowPlayingUIComposer.swift
//  CathayNowPlayingiOS
//
//  Created by SUNG HAO LIN on 2021/8/29.
//

import Foundation
import CathayMedia
import CathayCommon
import CathayNowPlaying

public final class NowPlayingUIComposer {
  private init() {}

  public static func compose(loader: NowPlayingLoader, imageLoader: ImageDataLoader, onSelectCallback: @escaping (Int) -> Void) -> NowPlayingViewController {
    let adapter = NowPlayingPresentationAdapter(loader: MainQueueDispatchDecorator(decoratee: loader))
    let refreshController = NowPlayingRefreshController(delegate: adapter)
    let pagingController = NowPlayingPagingController(delegate: adapter)
    let viewController = NowPlayingViewController(refreshController: refreshController, pagingController: pagingController)

    adapter.presenter = NowPlayingPresenter(view: NowPlayingViewAdapter(controller: viewController,
                                                                        imageLoader: MainQueueDispatchDecorator(decoratee: imageLoader),
                                                                        onSelectCallback: onSelectCallback),
                                            loadingView: WeakRefVirtualProxy(refreshController),
                                            errorView: WeakRefVirtualProxy(viewController),
                                            pagingView: WeakRefVirtualProxy(pagingController))
    
    viewController.title = NowPlayingPresenter.title
    return viewController
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

extension WeakRefVirtualProxy: NowPlayingPagingView where T: NowPlayingPagingView {
  public func display(_ viewModel: NowPlayingPagingViewModel) {
    object?.display(viewModel)
  }
}

extension MainQueueDispatchDecorator: NowPlayingLoader where T == NowPlayingLoader {
  public func execute(_ request: PagedNowPlayingRequest, completion: @escaping (NowPlayingLoader.Result) -> Void) {
    decoratee.execute(request, completion: { [weak self] result in
      self?.dispatch { completion(result) }
    })
  }
}

extension MainQueueDispatchDecorator: ImageDataLoader where T == ImageDataLoader {
  public func load(from imageURL: URL, completion: @escaping (ImageDataLoader.Result) -> Void) -> ImageDataLoaderTask {
    decoratee.load(from: imageURL, completion: { [weak self] result in
      self?.dispatch { completion(result) }
    })
  }
}
