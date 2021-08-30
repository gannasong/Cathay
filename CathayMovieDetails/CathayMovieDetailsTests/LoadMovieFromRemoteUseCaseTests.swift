//
//  LoadMovieFromRemoteUseCaseTests.swift
//  CathayMovieDetailsTests
//
//  Created by SUNG HAO LIN on 2021/8/30.
//

import XCTest
import CathayNetworking
import CathayMovieDetails

class RemoteMovieLoader: MovieLoader {
  typealias Result = MovieLoader.Result

  enum Error: Swift.Error {
    case connectivity
    case invalidResponse
  }

  private let baseURL: URL
  private let client: HTTPClient

  init(baseURL: URL, client: HTTPClient) {
    self.baseURL = baseURL
    self.client = client
  }

  func load(id: Int, completion: @escaping (Result) -> Void) {
    client.dispatch(URLRequest(url: enrich(baseURL, with: id)), completion: { [weak self] result in
      guard self != nil else { return }

      switch result {
      case let .success((data, response)):
        completion(RemoteMovieLoader.map(data, from: response))
      case .failure:
        completion(.failure(Error.connectivity))
      }
    })
  }

  func enrich(_ url: URL, with movieID: Int) -> URL {
    return url
      .appendingPathComponent("3")
      .appendingPathComponent("movie")
      .appendingPathComponent("\(movieID)")
  }

  static func map(_ data: Data, from response: HTTPURLResponse) -> Result {
    do {
      let value = try MovieMapper.map(data, from: response)
      return .success(value.asMovie)
    } catch {
      return .failure(error)
    }
  }
}

struct RemoteMovie: Decodable {

  struct RemoteMovieGenre: Decodable {
    let name: String
  }

  let id: Int
  let original_title: String
  let vote_average: CGFloat
  let runtime: CGFloat
  let genres: [RemoteMovieGenre]
  let overview: String
  let backdrop_path: String

  var asMovie: Movie {
    return Movie(id: id,
                 title: original_title,
                 rating: vote_average,
                 length: runtime,
                 genres: genres.map { $0.name },
                 overview: overview,
                 backdropImagePath: backdrop_path)
  }
}

final class MovieMapper {

  private static var OK_200: Int { return 200 }

  static func map(_ data: Data, from response: HTTPURLResponse) throws -> RemoteMovie {
    guard response.statusCode == OK_200, let page = try? JSONDecoder().decode(RemoteMovie.self, from: data) else {
      throw RemoteMovieLoader.Error.invalidResponse
    }

    return page
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

  func test_load_deliversErrorOnSuccessResponseWithInvalidJson() {
    let (sut, client) = makeSUT()
    let invalidJSONData = Data("invalid json".utf8)

    expect(sut, toCompleteWith: failure(.invalidResponse)) {
      client.completes(withStatusCode: 200, data: invalidJSONData)
    }
  }

  func test_load_deliversMovieOnSuccessResponseWithValidJson() {
    let (sut, client) = makeSUT()
    let movie = makeMovie()
    let movieData = makeMovieJSONData(for: movie.json)

    expect(sut, toCompleteWith: .success(movie.model)) {
      client.completes(withStatusCode: 200, data: movieData)
    }
  }

  func test_load_doesNotDeliverResultAfterSUTInstanceHasBeenDeallocated() {
    let client = HTTPClientSpy()
    var sut: MovieLoader? = RemoteMovieLoader(baseURL: makeURL(), client: client)

    var captureResults = [RemoteMovieLoader.Result]()
    sut?.load(id: 1, completion: { captureResults.append($0) })
    sut = nil

    client.completes(withStatusCode: 200, data: makeData())

    XCTAssertTrue(captureResults.isEmpty)
  }

  // MARK: - Helpers

  func makeSUT(baseURL: URL? = nil, file: StaticString = #file, line: UInt = #line) -> (MovieLoader, HTTPClientSpy) {
    let client = HTTPClientSpy()
    let sut = RemoteMovieLoader(baseURL: baseURL ?? makeURL(), client: client)
    trackForMemoryLeaks(client, file: file, line: line)
    trackForMemoryLeaks(sut, file: file, line: line)
    return (sut, client)
  }

  func expect(_ sut: MovieLoader, toCompleteWith expectedResult: MovieLoader.Result, when action: () -> Void, file: StaticString = #file, line: UInt = #line) {
    let exp = expectation(description: "Wait for load completion")
    sut.load(id: 0, completion: { receivedResult in
      switch (receivedResult, expectedResult) {
      case let (.success(receivedMovie), .success(expectedMovie)):
        XCTAssertEqual(receivedMovie, expectedMovie, file: file, line: line)

      case let (.failure(receivedError as NSError?), .failure(expectedError as NSError?)):
        XCTAssertEqual(receivedError, expectedError, file: file, line: line)

      default:
        XCTFail("Expected result \(expectedResult) got \(receivedResult) instead", file: file, line: line)
      }

      exp.fulfill()
    })

    action()

    wait(for: [exp], timeout: 1.0)
  }

  func failure(_ error: RemoteMovieLoader.Error) -> MovieLoader.Result {
    return .failure(error)
  }

  func makeMovieJSONData(for items: [String: Any]) -> Data {
    let data = try! JSONSerialization.data(withJSONObject: items)
    return data
  }

  func makeMovie() -> (model: Movie, json: [String: Any]) {

    let model = Movie(
      id: 1,
      title: "thrilling action movie",
      rating: 8,
      length: 139,
      genres: ["action", "thriller"],
      overview: "a thrilling movie with lots of action",
      backdropImagePath: "some-cool-image.png"
    )

    let json = [
      "id": model.id,
      "original_title": model.title,
      "vote_average": model.rating,
      "runtime": model.length,
      "genres": model.genres.map { ["name": $0] },
      "overview": model.overview,
      "backdrop_path": model.backdropImagePath
    ] as [String: Any]

    return (model, json)
  }
}
