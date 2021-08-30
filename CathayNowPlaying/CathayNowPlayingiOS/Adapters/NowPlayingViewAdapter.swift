//
//  NowPlayingViewAdapter.swift
//  CathayNowPlayingiOS
//
//  Created by SUNG HAO LIN on 2021/8/30.
//

import UIKit
import CathayMedia
import CathayNowPlaying

final class NowPlayingViewAdapter {

  private weak var controller: NowPlayingViewController?
  private let imageLoader: ImageDataLoader

  init(controller: NowPlayingViewController, imageLoader: ImageDataLoader) {
    self.controller = controller
    self.imageLoader = imageLoader
  }

  private func makeCellController(for model: NowPlayingCard) -> NowPlayingCardCellController {
    let adapter = NowPlayingImageDataLoaderPresentationAdapter<WeakRefVirtualProxy<NowPlayingCardCellController>, UIImage>(
      baseURL: URL(string: "https://image.tmdb.org/t/p/w500/")!, // TODO: Create URL factory
      model: model,
      imageLoader: imageLoader
    )

    let view = NowPlayingCardCellController(delegate: adapter)
    return view
   }
}

extension NowPlayingViewAdapter: NowPlayingView {
  func display(_ viewModel: NowPlayingViewModel) {
    controller?.items = viewModel.items.map(makeCellController(for:))
  }
}

extension WeakRefVirtualProxy: NowPlayingImageView where T: NowPlayingImageView, T.Image == UIImage {
  public func display(_ model: NowPlayingImageViewModel<UIImage>) {
    object?.display(model)
  }
}
