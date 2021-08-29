//
//  HTTPClient.swift
//  CathayNowPlaying
//
//  Created by SUNG HAO LIN on 2021/8/29.
//

import Foundation

public protocol HTTPClientTask {
  func cancel()
}

public protocol HTTPClient {
  typealias Result = Swift.Result<(data: Data, response: HTTPURLResponse), Error>

  @discardableResult
  func dispatch(_ request: URLRequest, completion: @escaping (Result) -> Void) -> HTTPClientTask
}
