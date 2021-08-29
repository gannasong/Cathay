//
//  RemoteNowPlayingLoader.swift
//  CathayNowPlaying
//
//  Created by SUNG HAO LIN on 2021/8/29.
//

import Foundation

public final class RemoteNowPlayingLoader: NowPlayingLoader {
  private let baseURL: URL
  private let client: HTTPClient

  public typealias Result = NowPlayingLoader.Result

  public enum Error: Swift.Error {
    case connectivity
    case invalidResponse
  }

  public init(baseURL: URL, client: HTTPClient) {
    self.baseURL = baseURL
    self.client = client
  }

  public func execute(_ request: PagedNowPlayingRequest, completion: @escaping (Result) -> Void) {
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
