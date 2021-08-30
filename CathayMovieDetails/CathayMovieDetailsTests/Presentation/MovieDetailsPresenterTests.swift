//
//  MovieDetailsPresenterTests.swift
//  CathayMovieDetailsTests
//
//  Created by SUNG HAO LIN on 2021/8/30.
//

import XCTest

class MovieDetailsPresenter {

}

class MovieDetailsPresenterTests: XCTestCase {

  func test_init_doesNotMessageView() {
    let (_, view) = makeSUT()

    XCTAssertTrue(view.messages.isEmpty)
  }

  // MARK: - Helpers

  func makeSUT(file: StaticString = #file, line: UInt = #line) -> (sut: MovieDetailsPresenter, view: ViewSpy) {
    let view = ViewSpy()
    let sut = MovieDetailsPresenter()
    trackForMemoryLeaks(view, file: file, line: line)
    trackForMemoryLeaks(sut, file: file, line: line)
    return (sut, view)
  }

  class ViewSpy {
    private(set) var messages: [Any] = []
  }
}
