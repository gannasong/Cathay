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
  let refreshControl = UIRefreshControl(frame: .zero)

  private(set) lazy var collectionView: UICollectionView = {
    let collectionView = UICollectionView(frame: self.view.frame, collectionViewLayout: UICollectionViewFlowLayout())
    collectionView.autoresizingMask = [.flexibleHeight, .flexibleWidth]
    collectionView.backgroundColor = .systemBackground
    collectionView.delegate = self

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
    refreshControl.beginRefreshing()
    loader?.execute(PagedNowPlayingRequest(page: 1), completion: { [weak self] result in
      self?.refreshControl.endRefreshing()
    })
  }
}

extension NowPlayingViewController: UICollectionViewDelegateFlowLayout {
  func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
    guard refreshControl.isRefreshing == true else { return }
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

  func test_loadingIndicator_isVisibleDuringLoadingState() {
    let (sut, loader) = makeSUT()

    XCTAssertFalse(sut.loadingIndicatorIsVisible)

    sut.loadViewIfNeeded()
    XCTAssertTrue(sut.loadingIndicatorIsVisible)

    loader.loadFeedCompletes(with: .success(.init(items: [], page: 1, totalPages: 1)))
    XCTAssertFalse(sut.loadingIndicatorIsVisible)
  }

  // MARK: - Helpers

  func makeSUT(file: StaticString = #file, line: UInt = #line) -> (NowPlayingViewController, LoaderSpy) {
    let loader = LoaderSpy()
    let sut = NowPlayingViewController(loader: loader)

    trackForMemoryLeaks(loader, file: file, line: line)
    trackForMemoryLeaks(sut, file: file, line: line)
    return (sut, loader)
  }

  func makeNowPlayingFeed(items: [NowPlayingCard] = [], pageNumber: Int = 0, totalPages: Int = 1) -> NowPlayingFeed {
    return NowPlayingFeed(items: items, page: pageNumber, totalPages: totalPages)
  }

  func makeNowPlayingCard(id: Int, title: String? = nil, imagePath: String? = nil ) -> NowPlayingCard {
    return NowPlayingCard(id: id, title: title ?? UUID().uuidString, imagePath: imagePath ?? "\(UUID().uuidString).jpg")
  }

  class LoaderSpy: NowPlayingLoader {
    private(set) var messages: [Message] = []
    private var loadCompletions: [(NowPlayingLoader.Result) -> Void] = []

    enum Message: Equatable {
      case load(PagedNowPlayingRequest)
    }

    func execute(_ request: PagedNowPlayingRequest, completion: @escaping (NowPlayingLoader.Result) -> Void) {
      messages.append(.load(request))
      loadCompletions.append(completion)
    }

    func loadFeedCompletes(with result: NowPlayingLoader.Result, at index: Int = 0) {
      loadCompletions[index](result)
    }
  }
}

extension NowPlayingViewController {
  var loadingIndicatorIsVisible: Bool {
    return refreshControl.isRefreshing
  }

  func simulateUserRefresh() {
    refreshControl.beginRefreshing()
    refreshControl.simulatePullToRefresh()
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
