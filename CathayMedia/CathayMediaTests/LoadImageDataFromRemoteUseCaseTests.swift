//
//  LoadImageDataFromRemoteUseCaseTests.swift
//  CathayMediaTests
//
//  Created by SUNG HAO LIN on 2021/8/30.
//

import XCTest
import CathayMedia

class LoadImageDataFromRemoteUseCaseTests: XCTestCase {

  func test_init_doesNotRequestDataFromRemote() {
    let (_, client) = makeSUT()

    XCTAssertTrue(client.requestedURLs.isEmpty)
  }

  func test_load_requestsDataFromUrl() {
    let requestURL = makeURL("https://some-remote-image.com")
    let (sut, client) = makeSUT()

    _ = sut.load(from: requestURL) { _ in }

    XCTAssertEqual(client.requestedURLs, [requestURL])
  }

  func test_load_requestsDataFromURLTwice() {
    let requestURL = makeURL("https://some-remote-image.com")
    let (sut, client) = makeSUT()

    _ = sut.load(from: requestURL) { _ in }
    _ = sut.load(from: requestURL) { _ in }

    XCTAssertEqual(client.requestedURLs, [requestURL, requestURL])
  }

  func test_load_deliversErrorOnClientError() {
    let (sut, client) = makeSUT()
    let error = makeError()

    expect(sut, toCompleteWith: failure(.connectivity)) {
      client.completes(with: error)
    }
  }

  func test_load_deliversErrorOnNonSuccessResponse() {
    let (sut, client) = makeSUT()
    let samples = [299, 300, 399, 400, 418, 499, 500]

    samples.enumerated().forEach { index, code in
      expect(sut, toCompleteWith: failure(.invalidResponse)) {
        let data = makeData()
        client.completes(withStatusCode: code, data: data, at: index)
      }
    }
  }

  func test_load_deliversErrorOnSuccessResponseWithEmptyData() {
    let (sut, client) = makeSUT()
    let emptyData = makeData(isEmpty: true)

    expect(sut, toCompleteWith: failure(.invalidResponse)) {
      client.completes(withStatusCode: 200, data: emptyData)
    }
  }

  func test_delivers_successOnSuccessResponseWithNonEmptyData() {
    let (sut, client) = makeSUT()
    let nonEmptyData = makeData()

    expect(sut, toCompleteWith: .success(nonEmptyData)) {
      client.completes(withStatusCode: 200, data: nonEmptyData)
    }
  }

  func test_cancel_pendingTaskCancelsClientRequest() {
    let requestURL = makeURL("https://some-remote-image.com")
    let (sut, client) = makeSUT()

    let task = sut.load(from: requestURL, completion: { _ in })
    XCTAssertTrue(client.cancelledURLs.isEmpty)

    task.cancel()
    XCTAssertEqual(client.cancelledURLs, [requestURL])
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

    _ = sut.load(from: imageURL, completion: { receivedResult in
      switch (receivedResult, expectedResult) {
      case let (.success(receivedData), .success(expectedData)):
        XCTAssertEqual(receivedData, expectedData, file: file, line: line)

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
