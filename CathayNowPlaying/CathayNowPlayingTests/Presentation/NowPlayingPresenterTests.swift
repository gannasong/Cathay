//
//  NowPlayingPresenterTests.swift
//  CathayNowPlayingTests
//
//  Created by SUNG HAO LIN on 2021/8/29.
//

import XCTest
import CathayNowPlaying

struct NowPlayingLoadingViewModel: Equatable {
  let isLoading: Bool
}

struct NowPlayingErrorViewModel: Equatable {
  let message: String?

  static var noError: NowPlayingErrorViewModel {
    return NowPlayingErrorViewModel(message: nil)
  }

  static func error(message: String) -> NowPlayingErrorViewModel {
    return NowPlayingErrorViewModel(message: message)
  }
}

protocol NowPlayingLoadingView {
  func display(_ viewModel: NowPlayingLoadingViewModel)
}

protocol NowPlayingErrorView {
  func display(_ viewModel: NowPlayingErrorViewModel)
}

class NowPlayingPresenter {
  private let loadingView: NowPlayingLoadingView
  private let errorView: NowPlayingErrorView

  init(loadingView: NowPlayingLoadingView, errorView: NowPlayingErrorView) {
    self.loadingView = loadingView
    self.errorView = errorView
  }

  func didStartLoading() {
    loadingView.display(.init(isLoading: true))
    errorView.display(.noError)
  }
}

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

  // MARK: - Helpers

  func makeSUT(file: StaticString = #file, line: UInt = #line) -> (sut: NowPlayingPresenter, view: ViewSpy) {
    let view = ViewSpy()
    let sut = NowPlayingPresenter(loadingView: view, errorView: view)

    trackForMemoryLeaks(view, file: file, line: line)
    trackForMemoryLeaks(sut, file: file, line: line)
    return (sut, view)
  }

  class ViewSpy: NowPlayingLoadingView, NowPlayingErrorView {
    enum Message: Equatable {
      case display(isLoading: Bool)
      case display(message: String?)
    }

    private(set) var messages: [Message] = []

    func display(_ viewModel: NowPlayingLoadingViewModel) {
      messages.append(.display(isLoading: viewModel.isLoading))
    }

    func display(_ viewModel: NowPlayingErrorViewModel) {
      messages.append(.display(message: viewModel.message))
    }
  }
}
