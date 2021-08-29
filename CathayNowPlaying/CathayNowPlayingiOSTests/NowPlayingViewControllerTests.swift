//
//  NowPlayingViewControllerTests.swift
//  CathayNowPlayingiOSTests
//
//  Created by SUNG HAO LIN on 2021/8/29.
//

import XCTest
import UIKit
import CathayNowPlaying

final class NowPlayingViewController: UIViewController {
  private(set) lazy var collectionView: UICollectionView = {
    let collectionView = UICollectionView(frame: self.view.frame, collectionViewLayout: UICollectionViewFlowLayout())
    collectionView.autoresizingMask = [.flexibleHeight, .flexibleWidth]
    collectionView.backgroundColor = .systemBackground
    collectionView.delegate = self

    let refreshControl = UIRefreshControl(frame: .zero)
    refreshControl.addTarget(self, action: #selector(load), for: .valueChanged)

    collectionView.refreshControl = refreshControl
    return collectionView
  }()

  private var loader: NowPlayingLoader?

  convenience init(loader: NowPlayingLoader) {
    self.init()
    self.loader = loader
  }

  override func viewDidLoad() {
    super.viewDidLoad()
    view.addSubview(collectionView)
    load()
  }

  @objc func load() {
    loader?.execute(PagedNowPlayingRequest(page: 1), completion: { _ in })
  }
}

extension NowPlayingViewController: UICollectionViewDelegateFlowLayout {
  func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
    guard collectionView.refreshControl?.isRefreshing == true else { return }
    load()
  }
}

class NowPlayingViewControllerTests: XCTestCase {

  func test_loadActions_requestNowPlayingFromLoader() {
    let request: LoaderSpy.Message = .load(PagedNowPlayingRequest(page: 1))
    let (sut, loader) = makeSUT()
    XCTAssertTrue(loader.messages.isEmpty)

    sut.loadViewIfNeeded()
    XCTAssertEqual(loader.messages, [request])

    sut.simulateUserRefresh()
    XCTAssertEqual(loader.messages, [request, request])
  }

  // MARK: - Helpers

  func makeSUT(file: StaticString = #file, line: UInt = #line) -> (NowPlayingViewController, LoaderSpy) {
    let loader = LoaderSpy()
    let sut = NowPlayingViewController(loader: loader)

    trackForMemoryLeaks(loader, file: file, line: line)
    trackForMemoryLeaks(sut, file: file, line: line)
    return (sut, loader)
  }

  class LoaderSpy: NowPlayingLoader {
    enum Message: Equatable {
      case load(PagedNowPlayingRequest)
    }

    private(set) var messages: [Message] = []

    func execute(_ request: PagedNowPlayingRequest, completion: @escaping (NowPlayingLoader.Result) -> Void) {
      messages.append(.load(request))
    }
  }
}

extension NowPlayingViewController {
  func simulateUserRefresh() {
    collectionView.refreshControl?.beginRefreshing()
    collectionView.refreshControl?.simulatePullToRefresh()
  }
}

extension UIControl {
  func simulate(event: UIControl.Event) {
    allTargets.forEach { target in
      actions(forTarget: target, forControlEvent: event)?.forEach { (target as NSObject).perform(Selector($0)) }
    }
  }
}

extension UIRefreshControl {
  func simulatePullToRefresh() {
    simulate(event: .valueChanged)
  }
}
