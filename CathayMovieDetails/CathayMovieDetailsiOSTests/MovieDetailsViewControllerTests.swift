//
//  MovieDetailsViewControllerTests.swift
//  CathayMovieDetailsiOSTests
//
//  Created by SUNG HAO LIN on 2021/8/30.
//

import XCTest
import UIKit
import CathayMovieDetails

final class MovieDetailsViewController: UIViewController {
  private var id: Int?
  private var loader: MovieLoader?

  private(set) public var loadingIndicator: UIActivityIndicatorView = {
    let view = UIActivityIndicatorView(style: .large)
    view.translatesAutoresizingMaskIntoConstraints = false
    return view
  }()

  convenience init(id: Int, loader: MovieLoader) {
    self.init(nibName: nil, bundle: nil)
    self.id = id
    self.loader = loader
  }

  override func viewDidLoad() {
    super.viewDidLoad()
    loadingIndicator.startAnimating()
    loader?.load(id: id!, completion: { _ in })
  }
}

class MovieDetailsViewControllerTests: XCTestCase {

  func test_load_actionsRequestDetailsFromLoader() {
    let movieID = 100
    let (sut, loader) = makeSUT(id: movieID)

    XCTAssertTrue(loader.messages.isEmpty)

    sut.loadViewIfNeeded()
    XCTAssertEqual(loader.messages, [.load(movieID)])
  }

  func test_load_indicatorIsVisibleDuringLoadingState() {
    let (sut, _) = makeSUT()

    sut.loadViewIfNeeded()
    XCTAssertTrue(sut.loadingIndicatorIsVisible)
  }

  // MARK: - Helpers

  func makeSUT(id: Int = 0, file: StaticString = #file, line: UInt = #line) -> (MovieDetailsViewController, LoaderSpy) {
    let loader = LoaderSpy()
    let sut = MovieDetailsViewController(id: id, loader: loader)
    trackForMemoryLeaks(loader, file: file, line: line)
    trackForMemoryLeaks(sut, file: file, line: line)

    return (sut, loader)
  }

  class LoaderSpy: MovieLoader {

    enum Message: Equatable {
      case load(Int)
    }

    private(set) var messages: [Message] = []

    typealias Result = MovieLoader.Result

    func load(id: Int, completion: @escaping (Result) -> Void) {
      messages.append(.load(id))
    }
  }
}

extension MovieDetailsViewController {
  var loadingIndicatorIsVisible: Bool {
    return loadingIndicator.isAnimating
  }
}
