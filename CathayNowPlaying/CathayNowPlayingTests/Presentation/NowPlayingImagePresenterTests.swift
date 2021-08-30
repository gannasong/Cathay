//
//  NowPlayingImagePresenterTests.swift
//  CathayNowPlayingTests
//
//  Created by SUNG HAO LIN on 2021/8/30.
//

import XCTest
import CathayNowPlaying

struct NowPlayingImageViewModel<Image> {
  let image: Image?
  let title: String
  let isLoading: Bool
}

protocol NowPlayingImageView {
  associatedtype Image

  func display(_ model: NowPlayingImageViewModel<Image>)
}

final class NowPlayingImagePresenter<View: NowPlayingImageView, Image> where View.Image == Image {
  private let view: View

  init(view: View) {
    self.view = view
  }

  func didStartLoadingImageData(for model: NowPlayingCard) {
    view.display(NowPlayingImageViewModel<Image>(image: nil, title: model.title, isLoading: true))
  }
}

class NowPlayingImagePresenterTests: XCTestCase {

  func test_init_doesNotMessageView() {
    let (_, view) = makeSUT()

    XCTAssertTrue(view.messages.isEmpty)
  }

  func test_load_didStartLoadingImageDataAndStartsLoadingState() {
    let (sut, view) = makeSUT()
    let item = makeNowPlayingCard(id: 123)

    sut.didStartLoadingImageData(for: item)
    let message = view.messages.first

    XCTAssertEqual(view.messages.count, 1)
    XCTAssertEqual(message?.isLoading, true)
    XCTAssertEqual(message?.title, item.title)
    XCTAssertNil(message?.image)
  }

  // MARK: - Helpers

  func makeSUT(file: StaticString = #file, line: UInt = #line) -> (sut: NowPlayingImagePresenter<ViewSpy, SomeImage>, view: ViewSpy) {
    let view = ViewSpy()
    let sut = NowPlayingImagePresenter(view: view)
    trackForMemoryLeaks(view, file: file, line: line)
    trackForMemoryLeaks(sut, file: file, line: line)
    return (sut, view)
  }

  func makeNowPlayingCard(id: Int) -> NowPlayingCard {
    return NowPlayingCard(id: id, title: "Card #\(id)", imagePath: "image-for-card-\(id).png")
  }

  struct SomeImage: Equatable { }

  class ViewSpy: NowPlayingImageView {
    private(set) var messages: [NowPlayingImageViewModel<SomeImage>] = []

    func display(_ model: NowPlayingImageViewModel<SomeImage>) {
      messages.append(model)
    }
  }
}
