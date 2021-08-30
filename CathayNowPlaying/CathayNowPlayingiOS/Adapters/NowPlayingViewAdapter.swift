//
//  NowPlayingViewAdapter.swift
//  CathayNowPlayingiOS
//
//  Created by SUNG HAO LIN on 2021/8/30.
//

import UIKit
import CathayMedia
import CathayCommon
import CathayNowPlaying

final class NowPlayingViewAdapter {

  private weak var controller: NowPlayingViewController?
  private let imageLoader: ImageDataLoader
  private let onSelectCallback: (Int) -> Void

  init(controller: NowPlayingViewController, imageLoader: ImageDataLoader, onSelectCallback: @escaping (Int) -> Void) {
    self.controller = controller
    self.imageLoader = imageLoader
    self.onSelectCallback = onSelectCallback
  }

  private func makeCellController(for model: NowPlayingCard) -> NowPlayingCardCellController {
    let adapter = NowPlayingImageDataLoaderPresentationAdapter<WeakRefVirtualProxy<NowPlayingCardCellController>, UIImage>(
      baseURL: URL(string: "https://image.tmdb.org/t/p/w500/")!, // TODO: Create URL factory
      model: model,
      imageLoader: imageLoader
    )

    let view = NowPlayingCardCellController(delegate: adapter)
    view.didSelect = { [weak self] in
      self?.onSelectCallback(model.id)
    }
    
    adapter.presenter = NowPlayingImagePresenter(view: WeakRefVirtualProxy(view), imageTransformer: UIImage.init)
    
    return view
  }
}

extension NowPlayingViewAdapter: NowPlayingView {
  func display(_ viewModel: NowPlayingViewModel) {
    let newItems = viewModel.items.map(makeCellController)

    if viewModel.pageNumber == 1 {
      controller?.items = newItems
    } else {
      let source = controller?.items ?? []
      let target = source + newItems
      controller?.items = target
    }
  }
}

extension WeakRefVirtualProxy: NowPlayingImageView where T: NowPlayingImageView, T.Image == UIImage {
  public func display(_ model: NowPlayingImageViewModel<UIImage>) {
    object?.display(model)
  }
}
