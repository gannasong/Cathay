//
//  NowPlayingImageViewModel.swift
//  CathayNowPlaying
//
//  Created by SUNG HAO LIN on 2021/8/30.
//

import Foundation

public struct NowPlayingImageViewModel<Image> {
  public let image: Image?
  public let title: String
  public let isLoading: Bool
  
  public init(image: Image?, title: String, isLoading: Bool) {
    self.image = image
    self.title = title
    self.isLoading = isLoading
  }
}
