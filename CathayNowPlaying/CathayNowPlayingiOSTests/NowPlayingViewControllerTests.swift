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
  private var loader: NowPlayingLoader?

  convenience init(loader: NowPlayingLoader) {
    self.init()
    self.loader = loader
  }

  override func viewDidLoad() {
    super.viewDidLoad()
    load()
  }

  func load() {
    loader?.execute(PagedNowPlayingRequest(page: 1), completion: { _ in })
  }
}

class NowPlayingViewControllerTests: XCTestCase {

  func test_loadActions_requestNowPlayingFromLoader() {
    let (sut, loader) = makeSUT()
    XCTAssertTrue(loader.messages.isEmpty)

    sut.loadViewIfNeeded()
    XCTAssertEqual(loader.messages, [.load(PagedNowPlayingRequest(page: 1))])
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
