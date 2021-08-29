//
//  NowPlayingLoader.swift
//  CathayNowPlaying
//
//  Created by SUNG HAO LIN on 2021/8/29.
//

import Foundation

struct PagedNowPlayingRequest {
  let page: Int
  let language: String
}

protocol NowPlayingLoader {
  typealias Result = Swift.Result<[NowPlayingCard], Error>
  func execute(_ request: PagedNowPlayingRequest, completion: @escaping (Result) -> Void)
}
