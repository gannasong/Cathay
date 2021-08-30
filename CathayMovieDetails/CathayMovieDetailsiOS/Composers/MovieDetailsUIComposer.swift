//
//  MovieDetailsUIComposer.swift
//  CathayMovieDetailsiOS
//
//  Created by SUNG HAO LIN on 2021/8/30.
//

import Foundation
import CathayMovieDetails

public final class MovieDetailsUIComposer {
  private init() {}

  public static func compose(id: Int, loader: MovieLoader, onPurchaseCallback: @escaping () -> Void) -> MovieDetailsViewController {
    let viewController = MovieDetailsViewController(id: id, loader: loader)
    viewController.onBuyTicket = onPurchaseCallback
    return viewController
  }
}
