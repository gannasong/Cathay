//
//  NowPlayingLoader.swift
//  CathayNowPlaying
//
//  Created by SUNG HAO LIN on 2021/8/29.
//

import Foundation

public struct PagedNowPlayingRequest: Equatable {
  public let page: Int
  public let language: String

  public init(page: Int, language: String = "zh-TW") {
    self.page = page
    self.language = language
  }
}

public protocol NowPlayingLoader {
  typealias Result = Swift.Result<NowPlayingFeed, Error>
  func execute(_ request: PagedNowPlayingRequest, completion: @escaping (Result) -> Void)
}
