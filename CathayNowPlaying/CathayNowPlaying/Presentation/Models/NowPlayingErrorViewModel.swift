//
//  NowPlayingErrorViewModel.swift
//  CathayNowPlaying
//
//  Created by SUNG HAO LIN on 2021/8/30.
//

import Foundation

public struct NowPlayingErrorViewModel: Equatable {
  public let message: String?

  public static var noError: NowPlayingErrorViewModel {
    return NowPlayingErrorViewModel(message: nil)
  }

  public static func error(message: String) -> NowPlayingErrorViewModel {
    return NowPlayingErrorViewModel(message: message)
  }
}
