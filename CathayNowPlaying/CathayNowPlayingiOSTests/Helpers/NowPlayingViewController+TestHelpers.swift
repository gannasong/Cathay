//
//  NowPlayingViewController+TestHelpers.swift
//  CathayNowPlayingiOSTests
//
//  Created by SUNG HAO LIN on 2021/8/29.
//

import UIKit
import CathayNowPlayingiOS

extension NowPlayingViewController {
  var loadingIndicatorIsVisible: Bool {
    return collectionView.refreshControl?.isRefreshing == true
  }

  var numberOfItems: Int {
    return collectionView.numberOfSections == 0 ? 0 : collectionView.numberOfItems(inSection: 0)
  }

  func itemAt(_ item: Int, section: Int = 0) -> UICollectionViewCell? {
    let dataSource = collectionView.dataSource
    let indexPath = IndexPath(item: item, section: section)
    return dataSource?.collectionView(collectionView, cellForItemAt: indexPath)
  }

  func simulateUserRefresh() {
    collectionView.refreshControl?.beginRefreshing()
    scrollViewDidEndDragging(collectionView, willDecelerate: true)
  }

  @discardableResult
  func simulateItemVisible(at index: Int) -> UICollectionViewCell? {
    return itemAt(index)
  }

  @discardableResult
  func simulateItemNotVisible(at index: Int) -> UICollectionViewCell? {
    let view = simulateItemVisible(at: index)

    let delegate = collectionView.delegate
    let indexPath = IndexPath(item: index, section: 0)
    delegate?.collectionView?(collectionView, didEndDisplaying: view!, forItemAt: indexPath)

    return view
  }
}
