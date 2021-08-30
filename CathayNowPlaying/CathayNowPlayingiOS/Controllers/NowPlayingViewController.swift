//
//  NowPlayingViewController.swift
//  CathayNowPlayingiOS
//
//  Created by SUNG HAO LIN on 2021/8/29.
//

import UIKit
import CathayNowPlaying

public final class NowPlayingViewController: UICollectionViewController {

  var items: [NowPlayingCardCellController] = [] {
    didSet {
      collectionView.reloadData()
    }
  }

  private var refreshController: NowPlayingRefreshController?

  convenience init(refreshController: NowPlayingRefreshController) {
    self.init(collectionViewLayout: UICollectionViewFlowLayout())
    self.refreshController = refreshController
  }

  public override func viewDidLoad() {
    super.viewDidLoad()
    collectionView.refreshControl = refreshController?.view
    collectionView.register(NowPlayingCardFeedCell.self, forCellWithReuseIdentifier: "NowPlayingCardFeedCell")
    refreshController?.load()
  }

  public override func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
    guard collectionView.refreshControl?.isRefreshing == true else { return }
    refreshController?.load()
  }

  public override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
    items.count
  }

  public override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
    let controller = cellController(forItemAt: indexPath)
    return controller.view(in: collectionView, forItemAt: indexPath)
  }

  private func cellController(forItemAt indexPath: IndexPath) -> NowPlayingCardCellController {
    let controller = items[indexPath.row]
    return controller
  }
}

extension NowPlayingViewController: NowPlayingErrorView {
  public func display(_ viewModel: NowPlayingErrorViewModel) {

  }
}
