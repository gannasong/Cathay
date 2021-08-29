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
  private let client: HTTPClient

  public typealias Result = NowPlayingLoader.Result

  public enum Error: Swift.Error {
    case connectivity
    case invalidResponse
  }

  init(baseURL: URL, client: HTTPClient) {
    self.baseURL = baseURL
    self.client = client
  }

  func execute(_ request: PagedNowPlayingRequest, completion: @escaping (Result) -> Void) {
    let request = URLRequest(url: enrich(baseURL, with: request))
    client.dispatch(request) { [weak self] result in
      guard self != nil else { return }

      switch result {
      case let .success((data, response)):
        completion(RemoteNowPlayingLoader.map(data, from: response))
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

  static func map(_ data: Data, from response: HTTPURLResponse) -> Result {
    do {
      let items = try NowPlayingItemsMapper.map(data, from: response)
      return .success(items.asPageDTO)
    } catch {
      return .failure(error)
    }
  }
}

private extension RemoteNowPlayingFeed {
  var asPageDTO: NowPlayingFeed {
    return NowPlayingFeed(items: results.asCardDTO, page: number, totalPages: total_pages)
  }
}

private extension Array where Element == RemoteNowPlayingFeed.RemoteNowPlayingCard {
  var asCardDTO: [NowPlayingCard] {
    return map { item in NowPlayingCard(id: item.id, title: item.original_title, imagePath: item.poster_path) }
  }
}

final class NowPlayingItemsMapper {
  private static var OK_200: Int { return 200 }

  static func map(_ data: Data, from response: HTTPURLResponse) throws -> RemoteNowPlayingFeed {
    guard response.statusCode == OK_200, let page = try? JSONDecoder().decode(RemoteNowPlayingFeed.self, from: data) else {
      throw RemoteNowPlayingLoader.Error.invalidResponse
    }

    return page
  }
}

struct RemoteNowPlayingFeed: Decodable {
  let results: [RemoteNowPlayingCard]
  let number: Int
  let total_pages: Int

  struct RemoteNowPlayingCard: Decodable {
    let id: Int
    let original_title: String
    let poster_path: String
  }
}

extension HTTPURLResponse {
  private static var OK_200: Int { return 200 }

  var isOK: Bool {
    return statusCode == HTTPURLResponse.OK_200
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
      client.completes(with: clientError)
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

  func test_load_deliversNoItemsOn200HTTPResponseWithEmptyJSONList() {
    let (sut, client) = makeSUT()
    let emptyPage = makeNowPlayingFeed(items: [], pageNumber: 1, totalPages: 1)

    expect(sut, toCompleteWith: .success(emptyPage.model)) {
      let emptyPageData = makeItemsJSONData(for: emptyPage.json)
      client.completes(withStatusCode: 200, data: emptyPageData)
    }
  }

  func test_load_deliversItemsOn200HTTPResponseWithJSONItems() {
    let (sut, client) = makeSUT()
    let items = Array(0..<5).map { index in makeNowPlayingCard(id: index) }
    let page = makeNowPlayingFeed(items: items, pageNumber: 1, totalPages: 1)

    expect(sut, toCompleteWith: .success(page.model)) {
      let pageData = makeItemsJSONData(for: page.json)
      client.completes(withStatusCode: 200, data: pageData)
    }
  }

  func test_load_doesNotDeliverResultAfterSUTInstanceHasBeenDeallocated() {
    let client = HTTPClientSpy()
    var sut: NowPlayingLoader? = RemoteNowPlayingLoader(baseURL: makeURL(), client: client)

    var captureResults = [NowPlayingLoader.Result]()
    sut?.execute(.init(page: 1)) { captureResults.append($0) }

    sut = nil
    client.completes(withStatusCode: 200, data: makeData())

    XCTAssertTrue(captureResults.isEmpty)
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

    sut.execute(request) { receivedResult in
      switch (receivedResult, expectedResult) {
      case let (.success(receivedItems), .success(expectedItems)):
        XCTAssertEqual(receivedItems, expectedItems, file: file, line: line)

      case let (.failure(receivedError as RemoteNowPlayingLoader.Error), .failure(expectedError as RemoteNowPlayingLoader.Error)):
        XCTAssertEqual(receivedError, expectedError, file: file, line: line)

      default:
        XCTFail("Expected result \(expectedResult) got \(receivedResult) instead", file: file, line: line)
      }

      exp.fulfill()
    }

    action()

    wait(for: [exp], timeout: 1.0)
  }

  func failure(_ error: RemoteNowPlayingLoader.Error) -> NowPlayingLoader.Result {
    return .failure(error)
  }

  private func makeItemsJSONData(for items: [String: Any]) -> Data {
    let data = try! JSONSerialization.data(withJSONObject: items)
    return data
  }

  func makeNowPlayingFeed(items: [(model: NowPlayingCard, json: [String : Any])] = [], pageNumber: Int = 0, totalPages: Int = 1) -> (model: NowPlayingFeed, json: [String: Any]) {
    let model = NowPlayingFeed(items: items.map { $0.model },
                               page: pageNumber,
                               totalPages: totalPages)

    let json: [String: Any] = [
      "results": items.map { $0.json },
      "number": pageNumber,
      "total_pages": totalPages
    ].compactMapValues { $0 }

    return (model, json)
  }

  func makeNowPlayingCard(id: Int, title: String? = nil, imagePath: String? = nil ) -> (model: NowPlayingCard, json: [String: Any]) {
    let model = NowPlayingCard(id: id,
                               title: title ?? UUID().uuidString,
                               imagePath: imagePath ?? "\(UUID().uuidString).jpg")

    let json: [String: Any] = [
      "id": model.id,
      "original_title": model.title,
      "poster_path": model.imagePath
    ]

    return (model, json)
  }
}
