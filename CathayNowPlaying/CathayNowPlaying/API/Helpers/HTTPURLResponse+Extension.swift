//
//  HTTPURLResponse+Extension.swift
//  CathayNowPlaying
//
//  Created by SUNG HAO LIN on 2021/8/29.
//

import Foundation

extension HTTPURLResponse {
  private static var OK_200: Int { return 200 }

  var isOK: Bool {
    return statusCode == HTTPURLResponse.OK_200
  }
}
