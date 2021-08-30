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
    view.tintColor = #colorLiteral(red: 0.6039215686, green: 0.6588235294, blue: 0.8039215686, alpha: 1)
    return view
  }

  func display(_ viewModel: NowPlayingLoadingViewModel) {
    viewModel.isLoading ? view.beginRefreshing() : view.endRefreshing()
  }
}
