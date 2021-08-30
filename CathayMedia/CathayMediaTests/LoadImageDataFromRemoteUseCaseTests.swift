//
//  LoadImageDataFromRemoteUseCaseTests.swift
//  CathayMediaTests
//
//  Created by SUNG HAO LIN on 2021/8/30.
//

import XCTest
import CathayNetworking

class RemoteImageDataLoader {
  private let client: HTTPClient

  init(client: HTTPClient) {
    self.client = client
  }

  func load(from imageURL: URL) {
    client.dispatch(URLRequest(url: imageURL), completion: { _ in })
  }
}

class LoadImageDataFromRemoteUseCaseTests: XCTestCase {

  func test_init_doesNotRequestDataFromRemote() {
    let (_, client) = makeSUT()

    XCTAssertTrue(client.requestedURLs.isEmpty)
  }

  func test_load_requestsDataFromUrl() {
    let requestURL = makeURL("https://some-remote-image.com")
    let (sut, client) = makeSUT()

    sut.load(from: requestURL)

    XCTAssertEqual(client.requestedURLs, [requestURL])
  }

  func test_load_requestsDataFromURLTwice() {
    let requestURL = makeURL("https://some-remote-image.com")
    let (sut, client) = makeSUT()

    sut.load(from: requestURL)
    sut.load(from: requestURL)

    XCTAssertEqual(client.requestedURLs, [requestURL, requestURL])
  }

  // MARK: - Helpers

  func makeSUT(file: StaticString = #file, line: UInt = #line) -> (sut: RemoteImageDataLoader, client: HTTPClientSpy) {
    let client = HTTPClientSpy()
    let sut = RemoteImageDataLoader(client: client)
    trackForMemoryLeaks(sut, file: file, line: line)
    trackForMemoryLeaks(client, file: file, line: line)
    return (sut, client)
  }
}
