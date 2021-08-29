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
    let refreshController = NowPlayingRefreshController(loader: loader)
    let viewController = NowPlayingViewController(refreshController: refreshController)
    return viewController
  }
}
