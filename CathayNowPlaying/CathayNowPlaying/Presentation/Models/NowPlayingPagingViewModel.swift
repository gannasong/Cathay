//
//  NowPlayingPagingViewModel.swift
//  CathayNowPlaying
//
//  Created by SUNG HAO LIN on 2021/8/30.
//

import Foundation

public struct NowPlayingPagingViewModel: Equatable {
  public let isLoading: Bool
  public let isLast: Bool
  public let pageNumber: Int

  public var nextPage: Int? {
    return isLast ? nil : pageNumber + 1
  }

  public init(isLoading: Bool, isLast: Bool, pageNumber: Int) {
    self.isLoading = isLoading
    self.isLast = isLast
    self.pageNumber = pageNumber
  }
}
