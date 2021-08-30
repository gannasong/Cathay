//
//  MovieDetailsUIComposer.swift
//  CathayMovieDetailsiOS
//
//  Created by SUNG HAO LIN on 2021/8/30.
//

import UIKit
import CathayMedia
import CathayCommon
import CathayMovieDetails

public final class MovieDetailsUIComposer {
  
  private init() {}

  public static func compose(id: Int, loader: MovieLoader, imageLoader: ImageDataLoader, onPurchaseCallback: @escaping () -> Void) -> MovieDetailsViewController {
    let adapter = MovieLoaderPresentationAdapter<WeakRefVirtualProxy<MovieDetailsViewController>, UIImage>(
      id: id,
      loader: MainQueueDispatchDecorator(decoratee: loader),
      imageLoader: MainQueueDispatchDecorator(decoratee: imageLoader)
    )

    let viewController = MovieDetailsViewController(delegate: adapter)
    viewController.onBuyTicket = onPurchaseCallback
    adapter.presenter = MovieDetailsPresenter(view: WeakRefVirtualProxy(viewController), imageTransformer: UIImage.init)
    return viewController
  }
}

extension MainQueueDispatchDecorator: MovieLoader where T == MovieLoader {
  public func load(id: Int, completion: @escaping (MovieLoader.Result) -> Void) {
    decoratee.load(id: id, completion: { [weak self] result in
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

extension WeakRefVirtualProxy: MovieDetailsView where T: MovieDetailsView, T.Image == UIImage {
  public func display(_ model: MovieDetailsViewModel<UIImage>) {
    object?.display(model)
  }
}
