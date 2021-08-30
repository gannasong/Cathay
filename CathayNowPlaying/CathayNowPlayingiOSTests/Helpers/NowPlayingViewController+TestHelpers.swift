//
//  NowPlayingViewController+TestHelpers.swift
//  CathayNowPlayingiOSTests
//
//  Created by SUNG HAO LIN on 2021/8/29.
//

import UIKit
import CathayNowPlayingiOS

extension NowPlayingViewController {
  public override func loadViewIfNeeded() {
    super.loadViewIfNeeded()
    // make view small to prevent rendering cells
    collectionView.frame = CGRect(x: 0, y: 0, width: 1, height: 1)
  }

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

  func simulateItemNearVisible(at index: Int) {
    let prefetchDataSource = collectionView.prefetchDataSource
    let indexPath = IndexPath(item: index, section: 0)
    prefetchDataSource?.collectionView(collectionView, prefetchItemsAt: [indexPath])
  }

  func simulateItemNoLongerNearVisible(at index: Int) {
    simulateItemNearVisible(at: index)
    let prefetchDataSource = collectionView.prefetchDataSource
    let indexPath = IndexPath(item: index, section: 0)
    prefetchDataSource?.collectionView?(collectionView, cancelPrefetchingForItemsAt: [indexPath])
  }

  func simulateSelectItem(at index: Int) {
    let delegate = collectionView.delegate
    let indexPath = IndexPath(item: index, section: 0)
    delegate?.collectionView?(collectionView, didSelectItemAt: indexPath)
  }

  func simulatePagingRequest() {
    let scrollView = DraggingScrollView()
    scrollView.contentOffset.y = 1000
    scrollViewDidScroll(scrollView)
  }
}

private class DraggingScrollView: UIScrollView {
  override var isDragging: Bool {
    return true
  }
}
