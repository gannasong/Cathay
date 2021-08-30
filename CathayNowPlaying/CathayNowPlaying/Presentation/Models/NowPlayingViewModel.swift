//
//  NowPlayingViewModel.swift
//  CathayNowPlaying
//
//  Created by SUNG HAO LIN on 2021/8/30.
//

import Foundation

public struct NowPlayingViewModel: Equatable {
  public let pageNumber: Int
  public let items: [NowPlayingCard]
}
