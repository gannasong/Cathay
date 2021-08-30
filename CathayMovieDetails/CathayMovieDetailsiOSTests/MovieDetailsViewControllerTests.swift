//
//  MovieDetailsViewControllerTests.swift
//  CathayMovieDetailsiOSTests
//
//  Created by SUNG HAO LIN on 2021/8/30.
//

import XCTest
import UIKit
import CathayMovieDetails
import CathayMovieDetailsiOS

final class MovieDetailsViewController: UIViewController {
  private var id: Int?
  private var loader: MovieLoader?

  private(set) public var loadingIndicator: UIActivityIndicatorView = {
    let view = UIActivityIndicatorView(style: .large)
    view.translatesAutoresizingMaskIntoConstraints = false
    return view
  }()

  private(set) public var titleLabel: UILabel = {
    let view = UILabel(frame: .zero)
    return view
  }()

  private(set) public var metaLabel: UILabel = {
    let view = UILabel(frame: .zero)
    return view
  }()

  private(set) public var overviewLabel: UILabel = {
    let view = UILabel(frame: .zero)
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
    loader?.load(id: id!, completion: { [weak self] result in
      if let movie = try? result.get() {
        self?.titleLabel.text = movie.title

        let runTime = Double(movie.length * 60).asString(style: .short)
        let genres = movie.genres.map { $0.capitalizingFirstLetter() }.joined(separator: ", ")
        self?.metaLabel.text = "\(runTime) | \(genres)"
        self?.overviewLabel.text = movie.overview
      }

      self?.loadingIndicator.stopAnimating()
    })
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
    let (sut, loader) = makeSUT()
    let movie = makeMovie()

    sut.loadViewIfNeeded()
    XCTAssertTrue(sut.loadingIndicatorIsVisible)

    loader.loadCompletes(with: .success(movie))
    XCTAssertFalse(sut.loadingIndicatorIsVisible)
  }

  func test_load_successRendersDetails() {
    let (sut, loader) = makeSUT()
    let movie = makeMovie()

    sut.loadViewIfNeeded()
    loader.loadCompletes(with: .success(movie))

    assertThat(sut, hasViewConfiguredFor: movie)
  }

  // MARK: - Helpers

  func makeSUT(id: Int = 0, file: StaticString = #file, line: UInt = #line) -> (MovieDetailsViewController, LoaderSpy) {
    let loader = LoaderSpy()
    let sut = MovieDetailsViewController(id: id, loader: loader)
    trackForMemoryLeaks(loader, file: file, line: line)
    trackForMemoryLeaks(sut, file: file, line: line)

    return (sut, loader)
  }

  func assertThat(_ sut: MovieDetailsViewController, hasViewConfiguredFor item: Movie, file: StaticString = #file, line: UInt = #line) {
    XCTAssertEqual(sut.titleText, item.title, file: file, line: line)
    XCTAssertEqual(sut.metaText, "2 hr, 10 min | Action", file: file, line: line)
    XCTAssertEqual(sut.overviewText, item.overview, file: file, line: line)
  }

  func makeMovie() -> Movie {
    return Movie(id: 1,
                 title: "Any Movie",
                 rating: 8.2,
                 length: 130,
                 genres: ["action"],
                 overview: "An action movie",
                 backdropImagePath: "some-action-movie-background.png")
  }

  class LoaderSpy: MovieLoader {

    enum Message: Equatable {
      case load(Int)
    }

    private(set) var messages: [Message] = []
    private var loadCompletions: [(Result) -> Void] = []

    typealias Result = MovieLoader.Result

    func load(id: Int, completion: @escaping (Result) -> Void) {
      messages.append(.load(id))
      loadCompletions.append(completion)
    }

    func loadCompletes(with result: Result, at index: Int = 0) {
      loadCompletions[index](result)
    }
  }
}

extension MovieDetailsViewController {
  var loadingIndicatorIsVisible: Bool {
    return loadingIndicator.isAnimating
  }

  var titleText: String? {
    return titleLabel.text
  }

  var metaText: String? {
    return metaLabel.text
  }

  var overviewText: String? {
    return overviewLabel.text
  }
}
