//
//  URLSessionHTTPClient.swift
//  CathayNetworking
//
//  Created by SUNG HAO LIN on 2021/8/29.
//

import Foundation

public final class URLSessionHTTPClient: HTTPClient {

  public typealias Result = HTTPClient.Result

  private let session: URLSession

  private struct UnexpectedValuesRepresentation: Error { }

  private struct URLSessionTaskWrapper: HTTPClientTask {
    let wrapped: URLSessionTask
    func cancel() {
      wrapped.cancel()
    }
  }

  public init(session: URLSession = .shared) {
    self.session = session
  }

  public func dispatch(_ request: URLRequest, completion: @escaping (Result) -> Void) -> HTTPClientTask {
    let task = session.dataTask(with: request) { data, response, error in
      completion(Result {
        if let error = error {
          throw error
        } else if let data = data, let response = response as? HTTPURLResponse {
          return (data, response)
        } else {
          throw UnexpectedValuesRepresentation()
        }
      })
    }

    task.resume()
    return URLSessionTaskWrapper(wrapped: task)
  }
}
