//
//  NowPlayingViewController.swift
//  CathayNowPlayingiOS
//
//  Created by SUNG HAO LIN on 2021/8/29.
//

import UIKit
import CathayNowPlaying

public final class NowPlayingCardFeedCell: UICollectionViewCell { }

public final class NowPlayingViewController: UIViewController {
  public let refreshControl = UIRefreshControl(frame: .zero)

  public private(set) lazy var collectionView: UICollectionView = {
    let collectionView = UICollectionView(frame: self.view.frame, collectionViewLayout: UICollectionViewFlowLayout())
    collectionView.autoresizingMask = [.flexibleHeight, .flexibleWidth]
    collectionView.backgroundColor = .systemBackground
    collectionView.delegate = self
    collectionView.dataSource = self

    collectionView.register(NowPlayingCardFeedCell.self, forCellWithReuseIdentifier: "NowPlayingCardFeedCell")

    refreshControl.addTarget(self, action: #selector(load), for: .valueChanged)
    collectionView.refreshControl = refreshControl
    return collectionView
  }()

  private var loader: NowPlayingLoader?

  private var items: [NowPlayingCard] = [] {
    didSet {
      collectionView.reloadData()
    }
  }

  public convenience init(loader: NowPlayingLoader) {
    self.init()
    self.loader = loader
  }

  public override func viewDidLoad() {
    super.viewDidLoad()
    view.addSubview(collectionView)
    load()
  }

  @objc func load() {
    refreshControl.beginRefreshing()
    loader?.execute(PagedNowPlayingRequest(page: 1), completion: { [weak self] result in
      if let page = try? result.get() {
        self?.items = page.items
      }

      self?.refreshControl.endRefreshing()
    })
  }
}

extension NowPlayingViewController: UICollectionViewDelegateFlowLayout {
  public func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
    guard refreshControl.isRefreshing == true else { return }
    load()
  }
}

extension NowPlayingViewController: UICollectionViewDataSource {
  public func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
    return items.count
  }

  public func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
    let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "NowPlayingCardFeedCell", for: indexPath)
    return cell
  }
}
