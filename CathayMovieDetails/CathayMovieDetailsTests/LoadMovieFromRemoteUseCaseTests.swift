//
//  LoadMovieFromRemoteUseCaseTests.swift
//  CathayMovieDetailsTests
//
//  Created by SUNG HAO LIN on 2021/8/30.
//

import XCTest
import CathayNetworking

class RemoteMovieLoader {
  typealias Result = Swift.Result<Void, Error>

  enum Error: Swift.Error {
    case connectivity
  }

  private let baseURL: URL
  private let client: HTTPClient

  init(baseURL: URL, client: HTTPClient) {
    self.baseURL = baseURL
    self.client = client
  }

  func load(id: Int, completion: @escaping (Result) -> Void) {
    client.dispatch(URLRequest(url: enrich(baseURL, with: id)), completion: { _ in
      completion(.failure(.connectivity))
    })
  }

  func enrich(_ url: URL, with movieID: Int) -> URL {
    return url
      .appendingPathComponent("3")
      .appendingPathComponent("movie")
      .appendingPathComponent("\(movieID)")
  }
}

class LoadMovieFromRemoteUseCaseTests: XCTestCase {

  func test_init_doesNotRequestDataFromRemote() {
    let (_, client) = makeSUT()

    XCTAssertTrue(client.requestedURLs.isEmpty)
  }

  func test_load_requestsDataFromRemote() {
    let movieID = 1
    let expectedURL = makeURL("https://some-remote-svc.com/3/movie/\(movieID)")
    let baseURL = makeURL("https://some-remote-svc.com")
    let (sut, client) = makeSUT(baseURL: baseURL)

    sut.load(id: movieID, completion: { _ in })

    XCTAssertEqual(client.requestedURLs, [expectedURL])
  }

  func test_load_requestsDataFromURLTwice() {
    let movieID = 1
    let expectedURL = makeURL("https://some-remote-svc.com/3/movie/\(movieID)")
    let baseURL = makeURL("https://some-remote-svc.com")
    let (sut, client) = makeSUT(baseURL: baseURL)

    sut.load(id: movieID, completion: { _ in })
    sut.load(id: movieID, completion: { _ in })

    XCTAssertEqual(client.requestedURLs, [expectedURL, expectedURL])
  }

  func test_load_deliversErrorOnClientError() {
    let (sut, client) = makeSUT()

    expect(sut, toCompleteWith: failure(.connectivity)) {
      let error = makeError()
      client.completes(with: error)
    }
  }

  // MARK: - Helpers

  func makeSUT(baseURL: URL? = nil, file: StaticString = #file, line: UInt = #line) -> (RemoteMovieLoader, HTTPClientSpy) {
    let client = HTTPClientSpy()
    let sut = RemoteMovieLoader(baseURL: baseURL ?? makeURL(), client: client)
    trackForMemoryLeaks(client, file: file, line: line)
    trackForMemoryLeaks(sut, file: file, line: line)
    return (sut, client)
  }

  func expect(_ sut: RemoteMovieLoader, toCompleteWith expectedResult: RemoteMovieLoader.Result, when action: () -> Void, file: StaticString = #file, line: UInt = #line) {
    let exp = expectation(description: "Wait for load completion")
    sut.load(id: 0, completion: { receivedResult in
      switch (receivedResult, expectedResult) {
        case let (.failure(receivedError as RemoteMovieLoader.Error), .failure(expectedError as RemoteMovieLoader.Error)):
          XCTAssertEqual(receivedError, expectedError, file: file, line: line)
        default:
          XCTFail("Expected result \(expectedResult) got \(receivedResult) instead", file: file, line: line)
      }
      exp.fulfill()
    })

    action()

    wait(for: [exp], timeout: 1.0)
  }

  func failure(_ error: RemoteMovieLoader.Error) -> RemoteMovieLoader.Result {
    return .failure(error)
  }
}
