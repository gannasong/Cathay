//
//  NowPlayingCard.swift
//  CathayNowPlaying
//
//  Created by SUNG HAO LIN on 2021/8/29.
//

import Foundation

public struct NowPlayingCard {
  public let id: Int
  public let title: String
  public let imagePath: String

  public init(id: Int, title: String, imagePath: String) {
    self.id = id
    self.title = title
    self.imagePath = imagePath
  }
}
