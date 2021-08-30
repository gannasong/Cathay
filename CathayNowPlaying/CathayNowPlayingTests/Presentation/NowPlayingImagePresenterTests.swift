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
  private let imageTransformer: (Data) -> Image?

  init(view: View, imageTransformer: @escaping (Data) -> Image?) {
    self.view = view
    self.imageTransformer = imageTransformer
  }

  func didStartLoadingImageData(for model: NowPlayingCard) {
    view.display(NowPlayingImageViewModel<Image>(image: nil, title: model.title, isLoading: true))
  }

  func didFinishLoadingImageData(with data: Data, for model: NowPlayingCard) {
    let image = imageTransformer(data)
    view.display(NowPlayingImageViewModel<Image>(image: image, title: model.title, isLoading: false))
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

  func test_finish_loading_image_data_success_set_image_on_transform_success() {
    let transformedData = SomeImage()
    let item = makeNowPlayingCard(id: 123)
    let imageData = makeData()
    let (sut, view) = makeSUT(imageTransformer: { _ in transformedData })

    sut.didFinishLoadingImageData(with: imageData, for: item)
    let message = view.messages.first

    XCTAssertEqual(view.messages.count, 1)
    XCTAssertEqual(message?.isLoading, false)
    XCTAssertEqual(message?.title, item.title)
    XCTAssertEqual(message?.image, transformedData)
  }

  // MARK: - Helpers

  func makeSUT(imageTransformer: @escaping (Data) -> SomeImage? = { _ in nil }, file: StaticString = #file, line: UInt = #line) -> (sut: NowPlayingImagePresenter<ViewSpy, SomeImage>, view: ViewSpy) {
    let view = ViewSpy()
    let sut = NowPlayingImagePresenter(view: view, imageTransformer: imageTransformer)
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
