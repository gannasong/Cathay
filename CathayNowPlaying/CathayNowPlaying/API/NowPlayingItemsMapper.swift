//
//  NowPlayingItemsMapper.swift
//  CathayNowPlaying
//
//  Created by SUNG HAO LIN on 2021/8/29.
//

import Foundation

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
  let page: Int
  let total_pages: Int

  struct RemoteNowPlayingCard: Decodable {
    let id: Int
    let original_title: String
    let poster_path: String
  }
}
