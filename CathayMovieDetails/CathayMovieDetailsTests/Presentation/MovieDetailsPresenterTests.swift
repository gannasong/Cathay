//
//  MovieDetailsPresenterTests.swift
//  CathayMovieDetailsTests
//
//  Created by SUNG HAO LIN on 2021/8/30.
//

import XCTest

struct MovieDetailsViewModel<Image> {
  let image: Image?
  let title: String?
  let meta: String?
  let overview: String?

  let isLoading: Bool
  let error: String?

  static var showLoading: MovieDetailsViewModel<Image> {
    return MovieDetailsViewModel<Image>(image: nil, title: nil, meta: nil, overview: nil, isLoading: true, error: nil)
  }

  static func showError(message: String?) -> MovieDetailsViewModel<Image> {
    return MovieDetailsViewModel<Image>(image: nil, title: nil, meta: nil, overview: nil, isLoading: false, error: message)
  }
}

protocol MovieDetailsView {
  associatedtype Image

  func display(_ model: MovieDetailsViewModel<Image>)
}


class MovieDetailsPresenter<View: MovieDetailsView, Image> where View.Image == Image {

  private let view: View
  private let imageTransformer: (Data) -> Image?

  init(view: View, imageTransformer: @escaping (Data) -> Image?) {
    self.view = view
    self.imageTransformer = imageTransformer
  }

  func didStartLoading() {
    view.display(.showLoading)
  }

  func didFinishLoading(with error: Error) {
    view.display(.showError(message: error.localizedDescription))
  }
}

class MovieDetailsPresenterTests: XCTestCase {

  func test_init_doesNotMessageView() {
    let (_, view) = makeSUT()

    XCTAssertTrue(view.messages.isEmpty)
  }

  func test_load_startLoadingHidesErrorAndStartsLoadingState() {
    let (sut, view) = makeSUT()

    sut.didStartLoading()

    let message = view.messages.first
    XCTAssertEqual(view.messages.count, 1)

    XCTAssertEqual(message?.isLoading, true)
    XCTAssertNil(message?.title)
    XCTAssertNil(message?.meta)
    XCTAssertNil(message?.overview)
    XCTAssertNil(message?.error)
    XCTAssertNil(message?.image)
  }

  func test_load_loadMovieErrorSetsMessageAndStopsLoading() {
    let (sut, view) = makeSUT()
    let error = makeError("uh oh, could not find movie")

    sut.didFinishLoading(with: error)

    let message = view.messages.first
    XCTAssertEqual(view.messages.count, 1)

    XCTAssertEqual(message?.isLoading, false)
    XCTAssertNil(message?.title)
    XCTAssertNil(message?.meta)
    XCTAssertNil(message?.overview)
    XCTAssertEqual(message?.error, error.localizedDescription)
    XCTAssertNil(message?.image)
  }

  // MARK: - Helpers

  func makeSUT(imageTransformer: @escaping (Data) -> SomeImage? = { _ in nil }, file: StaticString = #file, line: UInt = #line) -> (sut: MovieDetailsPresenter<ViewSpy, SomeImage>, view: ViewSpy) {
    let view = ViewSpy()
    let sut = MovieDetailsPresenter<ViewSpy, SomeImage>(view: view, imageTransformer: imageTransformer)
    trackForMemoryLeaks(view, file: file, line: line)
    trackForMemoryLeaks(sut, file: file, line: line)
    return (sut, view)
  }

  struct SomeImage: Equatable { }

  class ViewSpy: MovieDetailsView {
    private(set) var messages: [MovieDetailsViewModel<SomeImage>] = []

    func display(_ model: MovieDetailsViewModel<SomeImage>) {
      messages.append(model)
    }
  }
}
