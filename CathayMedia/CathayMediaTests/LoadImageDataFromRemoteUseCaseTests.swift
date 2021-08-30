//
//  LoadImageDataFromRemoteUseCaseTests.swift
//  CathayMediaTests
//
//  Created by SUNG HAO LIN on 2021/8/30.
//

import XCTest
import CathayNetworking

class RemoteImageDataLoader {
  enum Error: Swift.Error {
    case connectivity
  }

  typealias Result = Swift.Result<Void, Error>

  private let client: HTTPClient

  init(client: HTTPClient) {
    self.client = client
  }

  func load(from imageURL: URL, completions: @escaping (Result) -> Void = { _ in }) {
    client.dispatch(URLRequest(url: imageURL), completion: { _ in
      completions(.failure(Error.connectivity))
    })
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

  func test_execute_deliversErrorOnClientError() {
    let (sut, client) = makeSUT()
    let error = makeError()

    expect(sut, toCompleteWith: failure(.connectivity), when: {
      client.completes(with: error)
    })
  }

  // MARK: - Helpers

  func makeSUT(file: StaticString = #file, line: UInt = #line) -> (sut: RemoteImageDataLoader, client: HTTPClientSpy) {
    let client = HTTPClientSpy()
    let sut = RemoteImageDataLoader(client: client)
    trackForMemoryLeaks(sut, file: file, line: line)
    trackForMemoryLeaks(client, file: file, line: line)
    return (sut, client)
  }

  func expect(_ sut: RemoteImageDataLoader, toCompleteWith expectedResult: RemoteImageDataLoader.Result, when action: () -> Void, file: StaticString = #file, line: UInt = #line) {
    let exp = expectation(description: "Wait for load completion")
    let imageURL = makeURL()

    sut.load(from: imageURL, completions: { receivedResult in
      switch (receivedResult, expectedResult) {
        case let (.failure(receivedError as RemoteImageDataLoader.Error), .failure(expectedError as RemoteImageDataLoader.Error)):
          XCTAssertEqual(receivedError, expectedError, file: file, line: line)
        default:
          XCTFail("Expected result \(expectedResult) got \(receivedResult) instead", file: file, line: line)
      }
      exp.fulfill()
    })

    action()

    wait(for: [exp], timeout: 1.0)
  }

  func failure(_ error: RemoteImageDataLoader.Error) -> RemoteImageDataLoader.Result {
    return .failure(error)
  }
}
