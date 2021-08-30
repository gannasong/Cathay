//
//  NowPlayingRefreshController.swift
//  CathayNowPlayingiOS
//
//  Created by SUNG HAO LIN on 2021/8/29.
//

import UIKit
import CathayNowPlaying

protocol NowPlayingRefreshControllerDelegate {
  func didRequestLoad()
}

final class NowPlayingRefreshController: NSObject, NowPlayingLoadingView {

  var onRefresh: (([NowPlayingCard]) -> Void)?

  private let delegate: NowPlayingRefreshControllerDelegate

  private(set) lazy var view = loadView()

  init(delegate: NowPlayingRefreshControllerDelegate) {
     self.delegate = delegate
   }

  @objc func load() {
    delegate.didRequestLoad()
  }

  func loadView() -> UIRefreshControl {
    let view = UIRefreshControl(frame: .zero)
    return view
  }

  func display(_ viewModel: NowPlayingLoadingViewModel) {
    viewModel.isLoading ? view.beginRefreshing() : view.endRefreshing()
  }
}
