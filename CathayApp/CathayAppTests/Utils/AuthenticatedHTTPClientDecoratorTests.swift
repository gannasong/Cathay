//
//  AuthenticatedHTTPClientDecoratorTests.swift
//  CathayAppTests
//
//  Created by SUNG HAO LIN on 2021/8/30.
//

import XCTest
import CathayNetworking
import CathayApp

class AuthenticatedHTTPClientDecoratorTests: XCTestCase {

  func test_init_doesNotMessageDecoratee() {
    let (_, decoratee) = makeSUT(config: testConfig)

    XCTAssertTrue(decoratee.requestedURLs.isEmpty)
  }

  func test_dispatch_invokesDecoratee() {
    let (sut, decoratee) = makeSUT(config: testConfig)

    sut.dispatch(URLRequest(url: makeURL()), completion: { _ in })

    XCTAssertFalse(decoratee.requestedURLs.isEmpty)
  }

  func test_dispatch_successDeliversToCompletionHandler() {
    let (sut, decoratee) = makeSUT(config: testConfig)
    let exp = expectation(description: "Wait for dispatch completion")

    var received = [HTTPClient.Result]()
    sut.dispatch(.init(url: makeURL()), completion: { result in
      received.append(result)
      exp.fulfill()
    })

    decoratee.completes(withStatusCode: 200, data: makeData())
    wait(for: [exp], timeout: 0.1)

    XCTAssertFalse(received.isEmpty)
  }

  func test_dispatch_failureDeliversToCompletionHandler() {
    let (sut, decoratee) = makeSUT(config: testConfig)
    let exp = expectation(description: "Wait for dispatch completion")

    var receivedError: Error? = nil
    sut.dispatch(.init(url: makeURL()), completion: { result in
      switch result {
      case let .failure(error):
        receivedError = error
      default:
        XCTFail("Expected error but got \(result) instead.")
      }

      exp.fulfill()
    })

    decoratee.completes(with: makeError())
    wait(for: [exp], timeout: 0.1)

    XCTAssertNotNil(receivedError)
  }

  func test_cancelTask_cancelFromRequest() {
    let decoratee = HTTPClientSpy()
    let client = AuthenticatedHTTPClientDecorator(decoratee: decoratee, config: testConfig)

    var receivedResult: HTTPClient.Result? = nil
    let task = client.dispatch(.init(url: makeURL()), completion: { result in
      receivedResult = result
    })

    task.cancel()

    XCTAssertNil(receivedResult)
  }

  func test_dispatch_enrichesRequestUrlWithApiKey() {
    let (sut, decoratee) = makeSUT(config: testConfig)
    let expectedURL = makeURL("https://some-given-url.com?api_key=\(testConfig.secret)")

    sut.dispatch(URLRequest(url: makeURL()), completion: { _ in })

    XCTAssertEqual(decoratee.requestedURLs, [expectedURL])
  }

  // MARK: - Helpers

  func makeSUT(config: AuthConfig, file: StaticString = #file, line: UInt = #line) -> (client: HTTPClient, decoratee: HTTPClientSpy) {
    let decoratee = HTTPClientSpy()
    let client = AuthenticatedHTTPClientDecorator(decoratee: decoratee, config: config)
    trackForMemoryLeaks(decoratee, file: file, line: line)
    trackForMemoryLeaks(client, file: file, line: line)
    return (client, decoratee)
  }

  var testConfig: AuthConfig {
    return .init(secret: "some-secret")
  }

  class HTTPClientSpy: HTTPClient {

    typealias Result = HTTPClient.Result

    private struct Task: HTTPClientTask {
      let callback: () -> Void
      func cancel() { callback() }
    }

    private var messages: [(requests: URLRequest, completion: (Result) -> Void)] = []
    private(set) var cancelledURLs: [URL] = []

    var requestedURLs: [URL] {
      return messages.compactMap { $0.requests.url }
    }

    func dispatch(_ request: URLRequest, completion: @escaping (Result) -> Void) -> HTTPClientTask {
      messages.append((request, completion))
      return Task { [weak self] in self?.cancelledURLs.append(request.url!) }
    }

    func completes(with error: Error, at index: Int = 0) {
      messages[index].completion(.failure(error))
    }

    func completes(withStatusCode code: Int, data: Data, at index: Int = 0) {
      let response = HTTPURLResponse(url: requestedURLs[index], statusCode: code, httpVersion: nil, headerFields: nil)!
      messages[index].completion(.success((data, response)))
    }
  }
}
