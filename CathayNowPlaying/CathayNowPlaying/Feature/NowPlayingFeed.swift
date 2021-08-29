//
//  NowPlayingFeed.swift
//  CathayNowPlaying
//
//  Created by SUNG HAO LIN on 2021/8/29.
//

import Foundation

public struct NowPlayingFeed: Equatable {
  public let items: [NowPlayingCard]
  public let page: Int
  public let totalPages: Int

  public init(items: [NowPlayingCard], page: Int, totalPages: Int) {
    self.items = items
    self.page = page
    self.totalPages = totalPages
  }
}
