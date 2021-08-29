//
//  LoadNowPlayingFromRemoteUseCaseTests.swift
//  CathayNowPlayingTests
//
//  Created by SUNG HAO LIN on 2021/8/29.
//

import XCTest
import CathayNowPlaying

class RemoteNowPlayingLoader: NowPlayingLoader {
  private let baseURL: URL
  private let client: LoadNowPlayingFromRemoteUseCaseTests.HTTPClientSpy

  public typealias Result = NowPlayingLoader.Result

  public enum Error: Swift.Error {
    case connectivity
    case invalidResponse
  }

  init(baseURL: URL, client: LoadNowPlayingFromRemoteUseCaseTests.HTTPClientSpy) {
    self.baseURL = baseURL
    self.client = client
  }

  func execute(_ request: PagedNowPlayingRequest, completion: @escaping (Result) -> Void) {
    let request = URLRequest(url: enrich(baseURL, with: request))
    client.dispatch(request) { result in
      switch result {
      case .success:
        completion(.failure(Error.invalidResponse))
      case .failure:
        completion(.failure(Error.connectivity))
      }
    }
  }
}

private extension RemoteNowPlayingLoader {
  func enrich(_ url: URL, with req: PagedNowPlayingRequest) -> URL {

    let requestURL = url
      .appendingPathComponent("3")
      .appendingPathComponent("discover")
      .appendingPathComponent("movie")

    var urlComponents = URLComponents(url: requestURL, resolvingAgainstBaseURL: false)
    urlComponents?.queryItems = [
      URLQueryItem(name: "language", value: req.language),
      URLQueryItem(name: "page", value: "\(req.page)")
    ]
    return urlComponents?.url ?? requestURL
  }
}

class LoadNowPlayingFromRemoteUseCaseTests: XCTestCase {

  func test_init_doesNotRequestDataFromURL() {
    let (_, client) = makeSUT()

    XCTAssertTrue(client.requestedURLs.isEmpty)
  }

  func test_load_requestsDataFromURL() {
    let request = PagedNowPlayingRequest(page: 1, language: "some-language")
    let expectedURL = makeURL("https://some-remote-svc.com/3/discover/movie?language=\(request.language)&page=\(request.page)")
    let baseURL = makeURL("https://some-remote-svc.com")
    let (sut, client) = makeSUT(baseURL: baseURL)

    sut.execute(request) { _ in }

    XCTAssertEqual(client.requestedURLs, [expectedURL])
  }

  func test_loadTwice_requestsDataFromURLTwice() {
    let request = PagedNowPlayingRequest(page: 1, language: "some-language")
    let expectedURL = makeURL("https://some-remote-svc.com/3/discover/movie?language=\(request.language)&page=\(request.page)")
    let baseURL = makeURL("https://some-remote-svc.com")
    let (sut, client) = makeSUT(baseURL: baseURL)

    sut.execute(request) { _ in }
    sut.execute(request) { _ in }

    XCTAssertEqual(client.requestedURLs, [expectedURL, expectedURL])
  }

  func test_load_deliversErrorOnClientError() {
    let (sut, client) = makeSUT()

    expect(sut, toCompleteWith: failure(.connectivity)) {
      let clientError = makeError()
      client.completes(with: .failure(clientError))
    }
  }

  func test_load_deliversErrorOnNon200HTTPResponse() {
    let (sut, client) = makeSUT()

    let samples = [299, 300, 399, 400, 418, 499, 500]

    samples.enumerated().forEach { index, code in
      expect(sut, toCompleteWith: failure(.invalidResponse)) {
        let data = makeData()
        client.completes(withStatusCode: code, data: data, at: index)
      }
    }
  }

  func test_load_deliversErrorOn200HTTPResponseWithInvalidJSON() {
    let (sut, client) = makeSUT()

    expect(sut, toCompleteWith: failure(.invalidResponse)) {
      let invalidJSONData = Data("invalid json".utf8)
      client.completes(withStatusCode: 200, data: invalidJSONData)
    }
  }

  // MARK: - Helpers

  func makeSUT(baseURL: URL? = nil, file: StaticString = #file, line: UInt = #line) -> (NowPlayingLoader, HTTPClientSpy) {
    let client = HTTPClientSpy()
    let sut = RemoteNowPlayingLoader(baseURL: baseURL ?? makeURL(), client: client)

    trackForMemoryLeaks(client, file: file, line: line)
    trackForMemoryLeaks(sut, file: file, line: line)

    return (sut, client)
  }

  func expect(_ sut: NowPlayingLoader, toCompleteWith expectedResult: NowPlayingLoader.Result, when action: () -> Void, file: StaticString = #file, line: UInt = #line) {
    let exp = expectation(description: "Wait for load completion")
    let request = PagedNowPlayingRequest(page: 1)

    sut.execute(request, completion: { receivedResult in
      switch (receivedResult, expectedResult) {
      case let (.failure(receivedError as RemoteNowPlayingLoader.Error), .failure(expectedError as RemoteNowPlayingLoader.Error)):
        XCTAssertEqual(receivedError, expectedError, file: file, line: line)
      default:
        XCTFail("Expected result \(expectedResult) got \(receivedResult) instead", file: file, line: line)
      }
      exp.fulfill()
    })

    action()

    wait(for: [exp], timeout: 1.0)
  }

  func failure(_ error: RemoteNowPlayingLoader.Error) -> NowPlayingLoader.Result {
    return .failure(error)
  }

  class HTTPClientSpy {
    private var messages = [(request: URLRequest, completion: (Result<(data: Data, response: HTTPURLResponse), Error>) -> Void)]()

    var requestedURLs: [URL] {
      return messages.compactMap { $0.request.url }
    }

    func dispatch(_ request: URLRequest, completion: @escaping (Result<(data: Data, response: HTTPURLResponse), Error>) -> Void) {
      messages.append((request, completion))
    }

    func completes(with result: Result<(data: Data, response: HTTPURLResponse), Error>, at index: Int = 0) {
      messages[index].completion(result)
    }

    func completes(withStatusCode code: Int, data: Data, at index: Int = 0) {
      let response = HTTPURLResponse(url: requestedURLs[index], statusCode: code, httpVersion: nil, headerFields: nil)!
      messages[index].completion(.success((data, response)))
    }
  }
}
