//
//  LoadNowPlayingFromRemoteUseCaseTests.swift
//  CathayNowPlayingTests
//
//  Created by SUNG HAO LIN on 2021/8/29.
//

import XCTest
import CathayNowPlaying

class RemoteNowPlayingLoader: NowPlayingLoader {
  public typealias Result = NowPlayingLoader.Result

  private let baseURL: URL
  private let client: LoadNowPlayingFromRemoteUseCaseTests.HTTPClientSpy

  init(baseURL: URL, client: LoadNowPlayingFromRemoteUseCaseTests.HTTPClientSpy) {
    self.baseURL = baseURL
    self.client = client
  }

  func execute(_ request: PagedNowPlayingRequest, completion: @escaping (Result) -> Void) {
    let request = URLRequest(url: enrich(baseURL, with: request))
    client.dispatch(request)
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

  // MARK: - Helpers

  func makeSUT(baseURL: URL? = nil, file: StaticString = #file, line: UInt = #line) -> (NowPlayingLoader, HTTPClientSpy) {
    let client = HTTPClientSpy()
    let sut = RemoteNowPlayingLoader(baseURL: baseURL ?? makeURL(), client: client)

    trackForMemoryLeaks(client, file: file, line: line)
    trackForMemoryLeaks(sut, file: file, line: line)

    return (sut, client)
  }

  class HTTPClientSpy {
    private var messages = [URLRequest]()

    var requestedURLs: [URL] {
      return messages.compactMap { $0.url }
    }

    func dispatch(_ request: URLRequest) {
      messages.append(request)
    }
  }
}
