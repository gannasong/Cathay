//
//  NowPlayingLoader.swift
//  CathayNowPlaying
//
//  Created by SUNG HAO LIN on 2021/8/29.
//

import Foundation

public struct PagedNowPlayingRequest {
  public let page: Int
  public let language: String

  public init(page: Int, language: String = "zh-TW") {
    self.page = page
    self.language = language
  }
}

protocol NowPlayingLoader {
  typealias Result = Swift.Result<[NowPlayingCard], Error>
  func execute(_ request: PagedNowPlayingRequest, completion: @escaping (Result) -> Void)
}
