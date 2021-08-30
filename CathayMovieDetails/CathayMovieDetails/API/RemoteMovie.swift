//
//  RemoteMovie.swift
//  CathayMovieDetails
//
//  Created by SUNG HAO LIN on 2021/8/30.
//

import Foundation

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
