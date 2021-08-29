//
//  NowPlayingPresenterTests.swift
//  CathayNowPlayingTests
//
//  Created by SUNG HAO LIN on 2021/8/29.
//

import XCTest
import CathayNowPlaying

class NowPlayingPresenterTests: XCTestCase {

  func test_init_doesNotMessageView() {
    let (_, view) = makeSUT()

    XCTAssertTrue(view.messages.isEmpty)
  }

  func test_didStartLoading_displaysNoErrorsAndStartsLoading() {
    let (sut, view) = makeSUT()

    sut.didStartLoading()

    XCTAssertEqual(view.messages, [.display(isLoading: true), .display(message: nil)])
  }

  func test_didFinishLoading_successDisplaysFeedAndStopsLoading() {
    let (sut, view) = makeSUT()
    let items = Array(0..<5).map { index in NowPlayingCard(id: index, title: "Card #\(index)", imagePath: "image-\(index).png") }
    let feed = NowPlayingFeed(items: items, page: 1, totalPages: 1)

    sut.didFinishLoading(with: feed)

    XCTAssertEqual(view.messages, [.display(isLoading: false), .display(items: items)])
  }

  func test_didFinishLoading_errorDisplaysErrorAndStopsLoading() {
    let (sut, view) = makeSUT()
    let errorDesc = "uh oh, could not update feed"
    let error = makeError(errorDesc)

    sut.didFinishLoading(with: error)

    XCTAssertEqual(view.messages, [.display(isLoading: false), .display(message: errorDesc)])
  }

  // MARK: - Helpers

  func makeSUT(file: StaticString = #file, line: UInt = #line) -> (sut: NowPlayingPresenter, view: ViewSpy) {
    let view = ViewSpy()
    let sut = NowPlayingPresenter(view: view, loadingView: view, errorView: view)

    trackForMemoryLeaks(view, file: file, line: line)
    trackForMemoryLeaks(sut, file: file, line: line)
    return (sut, view)
  }

  class ViewSpy: NowPlayingLoadingView, NowPlayingErrorView, NowPlayingView {
    enum Message: Equatable {
      case display(isLoading: Bool)
      case display(message: String?)
      case display(items: [NowPlayingCard])
    }

    private(set) var messages: [Message] = []

    func display(_ viewModel: NowPlayingLoadingViewModel) {
      messages.append(.display(isLoading: viewModel.isLoading))
    }

    func display(_ viewModel: NowPlayingErrorViewModel) {
      messages.append(.display(message: viewModel.message))
    }

    func display(_ viewModel: NowPlayingViewModel) {
      messages.append(.display(items: viewModel.items))
    }
  }
}
