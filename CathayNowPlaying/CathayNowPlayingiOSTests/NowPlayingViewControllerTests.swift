//
//  NowPlayingViewControllerTests.swift
//  CathayNowPlayingiOSTests
//
//  Created by SUNG HAO LIN on 2021/8/29.
//

import XCTest
import CathayMedia
import CathayNowPlaying
import CathayNowPlayingiOS

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

    sut.loadViewIfNeeded()
    XCTAssertTrue(sut.loadingIndicatorIsVisible)

    loader.loadFeedCompletes(with: .success(.init(items: [], page: 1, totalPages: 1)))
    XCTAssertFalse(sut.loadingIndicatorIsVisible)

    sut.simulateUserRefresh()
    XCTAssertTrue(sut.loadingIndicatorIsVisible)

    loader.loadFeedCompletes(with: .failure(makeError()))
    XCTAssertFalse(sut.loadingIndicatorIsVisible)
  }

  func test_loadCompletion_rendersSuccessfullyLoadedNowPlayingFeed() {
    let (sut, loader) = makeSUT()
    let items = Array(0..<10).map { index in makeNowPlayingCard(id: index, title: "Card #\(index)") }
    let feedPage = makeNowPlayingFeed(items: items, pageNumber: 1, totalPages: 1)

    sut.loadViewIfNeeded()
    assertThat(sut, isRendering: [])

    loader.loadFeedCompletes(with: .success(feedPage))
    assertThat(sut, isRendering: items)
  }

  func test_load_nowPlayingCardLoadsImageUrlWhenVisible() {
    let (sut, loader) = makeSUT()
    let itemZero = makeNowPlayingCard(id: 0)
    let itemOne = makeNowPlayingCard(id: 1)
    let feedPage = makeNowPlayingFeed(items: [itemZero, itemOne], pageNumber: 1, totalPages: 1)

    let expectedURLZero = makeURL("https://image.tmdb.org/t/p/w500/\(itemZero.imagePath)")
    let expectedURLOne = makeURL("https://image.tmdb.org/t/p/w500/\(itemOne.imagePath)")

    sut.loadViewIfNeeded()
    loader.loadFeedCompletes(with: .success(feedPage))
    XCTAssertTrue(loader.loadedImageURLs.isEmpty)

    sut.simulateItemVisible(at: 0)
    XCTAssertEqual(loader.loadedImageURLs, [expectedURLZero])

    sut.simulateItemVisible(at: 1)
    XCTAssertEqual(loader.loadedImageURLs, [expectedURLZero, expectedURLOne])
  }

  func test_load_nowPlayingCardCancelsImageLoadWhenNoLongerVisible() {
    let (sut, loader) = makeSUT()
    let itemZero = makeNowPlayingCard(id: 0)
    let itemOne = makeNowPlayingCard(id: 1)
    let feedPage = makeNowPlayingFeed(items: [itemZero, itemOne], pageNumber: 1, totalPages: 1)

    let expectedURLZero = makeURL("https://image.tmdb.org/t/p/w500/\(itemZero.imagePath)")
    let expectedURLOne = makeURL("https://image.tmdb.org/t/p/w500/\(itemOne.imagePath)")

    sut.loadViewIfNeeded()
    loader.loadFeedCompletes(with: .success(feedPage))
    XCTAssertTrue(loader.loadedImageURLs.isEmpty)

    sut.simulateItemNotVisible(at: 0)
    XCTAssertEqual(loader.cancelledImageURLs, [expectedURLZero])

    sut.simulateItemNotVisible(at: 1)
    XCTAssertEqual(loader.cancelledImageURLs, [expectedURLZero, expectedURLOne])
  }

  // MARK: - Helpers

  func makeSUT(file: StaticString = #file, line: UInt = #line) -> (NowPlayingViewController, LoaderSpy) {
    let loader = LoaderSpy()
    let sut = NowPlayingUIComposer.compose(loader: loader, imageLoader: loader)

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

  func assertThat(_ sut: NowPlayingViewController, isRendering feed: [NowPlayingCard], file: StaticString = #file, line: UInt = #line) {
    guard sut.numberOfItems == feed.count else {
      return XCTFail("Expected \(feed.count) cards, got \(sut.numberOfItems) instead.", file: file, line: line)
    }

    feed.enumerated().forEach { index, card in
      assertThat(sut, hasViewConfiguredFor: card, at: index)
    }
  }

  func assertThat(_ sut: NowPlayingViewController, hasViewConfiguredFor item: NowPlayingCard, at index: Int, file: StaticString = #file, line: UInt = #line) {
    let cell = sut.itemAt(index)
    guard let _ = cell as? NowPlayingCardFeedCell else {
      return XCTFail("Expected \(NowPlayingCardFeedCell.self) instance, got \(String(describing: cell)) instead", file: file, line: line)
    }
  }

  class LoaderSpy: NowPlayingLoader, ImageDataLoader {
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

    private struct TaskSpy: ImageDataLoaderTask {
      let cancelCallback: () -> Void
      func cancel() {
        cancelCallback()
      }
    }

    private var imageRequests = [(url: URL, completion: (ImageDataLoader.Result) -> Void)]()

    var loadedImageURLs: [URL] {
      return imageRequests.map { $0.url }
    }

    private(set) var cancelledImageURLs = [URL]()

    func load(from url: URL, completion: @escaping (ImageDataLoader.Result) -> Void) -> ImageDataLoaderTask {
      imageRequests.append((url, completion))
      return TaskSpy { [weak self] in self?.cancelledImageURLs.append(url) }
    }

    func completeImageLoading(with imageData: Data = Data(), at index: Int = 0) {
      imageRequests[index].completion(.success(imageData))
    }

    func completeImageLoadingWithError(at index: Int = 0) {
      let error = NSError(domain: "an error", code: 0)
      imageRequests[index].completion(.failure(error))
    }
  }
}
