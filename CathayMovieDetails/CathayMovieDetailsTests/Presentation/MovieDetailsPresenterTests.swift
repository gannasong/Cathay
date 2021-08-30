//
//  MovieDetailsPresenterTests.swift
//  CathayMovieDetailsTests
//
//  Created by SUNG HAO LIN on 2021/8/30.
//

import XCTest
import CathayMovieDetails

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

  func test_load_loadMovieSuccessWithFailedImageDownloadRendersDetailsAndStopsLoading() {
    let (sut, view) = makeSUT()
    let movie = makeMovie()
    let error = makeError("uh oh, could not find image for movie")

    sut.didFinishLoadingImageData(with: error, for: movie)

    let message = view.messages.first
    XCTAssertEqual(view.messages.count, 1)

    XCTAssertEqual(message?.isLoading, false)
    XCTAssertEqual(message?.title, movie.title)
    XCTAssertEqual(message?.meta, "2 hr, 19 min | Action, Romance")
    XCTAssertEqual(message?.overview, movie.overview)
    XCTAssertNil(message?.image)
    XCTAssertNil(message?.error)
  }

  func test_load_loadMovieAndImageSuccessDisplaysImageOnSuccessfulTransformation() {
    let transformedData = SomeImage()
    let (sut, view) = makeSUT(imageTransformer: { _ in transformedData })
    let movie = makeMovie()

    sut.didFinishLoadingImageData(with: makeData(), for: movie)

    let message = view.messages.first
    XCTAssertEqual(view.messages.count, 1)

    XCTAssertEqual(message?.isLoading, false)
    XCTAssertEqual(message?.title, movie.title)
    XCTAssertEqual(message?.meta, "2 hr, 19 min | Action, Romance")
    XCTAssertEqual(message?.overview, movie.overview)
    XCTAssertEqual(message?.image, transformedData)
    XCTAssertNil(message?.error)
  }

  // MARK: - Helpers

  func makeSUT(imageTransformer: @escaping (Data) -> SomeImage? = { _ in nil }, file: StaticString = #file, line: UInt = #line) -> (sut: MovieDetailsPresenter<ViewSpy, SomeImage>, view: ViewSpy) {
    let view = ViewSpy()
    let sut = MovieDetailsPresenter<ViewSpy, SomeImage>(view: view, imageTransformer: imageTransformer)
    trackForMemoryLeaks(view, file: file, line: line)
    trackForMemoryLeaks(sut, file: file, line: line)
    return (sut, view)
  }

  func makeMovie() -> Movie {
     return Movie(id: 1,
                  title: "A movie",
                  rating: 8.4,
                  length: 139,
                  genres: ["Action", "Romance"],
                  overview: "A romantic action movie",
                  backdropImagePath: "any.png")
   }

  struct SomeImage: Equatable { }

  class ViewSpy: MovieDetailsView {
    private(set) var messages: [MovieDetailsViewModel<SomeImage>] = []

    func display(_ model: MovieDetailsViewModel<SomeImage>) {
      messages.append(model)
    }
  }
}
