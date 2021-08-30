//
//  RemoteImageDataLoader.swift
//  CathayMedia
//
//  Created by SUNG HAO LIN on 2021/8/30.
//

import Foundation
import CathayNetworking

public final class RemoteImageDataLoader {
  public enum Error: Swift.Error {
    case connectivity
    case invalidResponse
  }

  public typealias Result = Swift.Result<Data, Error>

  private let client: HTTPClient

  public init(client: HTTPClient) {
    self.client = client
  }

  public func load(from imageURL: URL, completion: @escaping (Result) -> Void = { _ in }) {
    client.dispatch(URLRequest(url: imageURL), completion: { result in
      switch result {
      case let .success(body):
        if body.data.count > 0 && body.response.statusCode == 200 {
          completion(.success(body.data))
        } else {
          completion(.failure(Error.invalidResponse))
        }
      case .failure:
        completion(.failure(Error.connectivity))
      }
    })
  }
}
