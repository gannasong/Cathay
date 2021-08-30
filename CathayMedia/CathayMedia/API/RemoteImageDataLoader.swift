//
//  RemoteImageDataLoader.swift
//  CathayMedia
//
//  Created by SUNG HAO LIN on 2021/8/30.
//

import Foundation
import CathayNetworking

public final class RemoteImageDataLoader: ImageDataLoader {
  public enum Error: Swift.Error {
    case connectivity
    case invalidResponse
  }

  public typealias Result = ImageDataLoader.Result

  private let client: HTTPClient

  public init(client: HTTPClient) {
    self.client = client
  }

  public func load(from imageURL: URL, completion: @escaping (Result) -> Void) -> ImageDataLoaderTask {
    let task = HTTPClientTaskWrapper(completion)
    task.wrapped = client.dispatch(URLRequest(url: imageURL), completion: { [weak self] result in
      guard self != nil else { return }

      task.complete(with: result
        .mapError { _ in Error.connectivity }
        .flatMap { (data, response) in
          let isValidResponse = response.statusCode == 200 && !data.isEmpty
          return isValidResponse ? .success(data) : .failure(Error.invalidResponse)
      })
    })

    return task
  }
}

private final class HTTPClientTaskWrapper: ImageDataLoaderTask {

  private var completion: ((ImageDataLoader.Result) -> Void)?

  var wrapped: HTTPClientTask?

  init(_ completion: @escaping (ImageDataLoader.Result) -> Void) {
    self.completion = completion
  }

  func complete(with result: ImageDataLoader.Result) {
    completion?(result)
  }

  func cancel() {
    preventFurtherCompletions()
    wrapped?.cancel()
  }

  private func preventFurtherCompletions() {
    completion = nil
  }
}
