//
//  MovieDetailsUIComposer.swift
//  CathayMovieDetailsiOS
//
//  Created by SUNG HAO LIN on 2021/8/30.
//

import Foundation
import CathayCommon
import CathayMovieDetails

public final class MovieDetailsUIComposer {
  private init() {}

  public static func compose(id: Int, loader: MovieLoader, onPurchaseCallback: @escaping () -> Void) -> MovieDetailsViewController {
    let viewController = MovieDetailsViewController(id: id, loader: MainQueueDispatchDecorator(decoratee: loader))
    viewController.onBuyTicket = onPurchaseCallback
    return viewController
  }
}

// MARK: - MainQueueDispatchDecorator

extension MainQueueDispatchDecorator: MovieLoader where T == MovieLoader {
  public func load(id: Int, completion: @escaping (MovieLoader.Result) -> Void) {
    decoratee.load(id: id, completion: { [weak self] result in
      self?.dispatch { completion(result) }
    })
  }
}
