//
//  NowPlayingRefreshController.swift
//  CathayNowPlayingiOS
//
//  Created by SUNG HAO LIN on 2021/8/29.
//

import UIKit
import CathayNowPlaying

final class NowPlayingRefreshController: NSObject {

  var onRefresh: (([NowPlayingCard]) -> Void)?

  private let loader: NowPlayingLoader

  private(set) lazy var view = loadView()

  init(loader: NowPlayingLoader) {
    self.loader = loader
  }

  @objc func load() {
    view.beginRefreshing()

    loader.execute(PagedNowPlayingRequest(page: 1), completion: { [weak self] result in
      if let page = try? result.get() {
        self?.onRefresh?(page.items)
      }
      self?.view.endRefreshing()
    })
  }

  func loadView() -> UIRefreshControl {
    let view = UIRefreshControl(frame: .zero)
    return view
  }
}
