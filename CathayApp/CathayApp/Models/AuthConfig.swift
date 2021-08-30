//
//  AuthConfig.swift
//  CathayApp
//
//  Created by SUNG HAO LIN on 2021/8/30.
//

import Foundation

public struct AuthConfig: Decodable {
  public let secret: String

  public init(secret: String) {
    self.secret = secret
  }
}
