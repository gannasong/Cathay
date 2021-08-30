//
//  AuthenticatedHTTPClientDecorator.swift
//  CathayApp
//
//  Created by SUNG HAO LIN on 2021/8/30.
//

import Foundation
import CathayNetworking

public class AuthenticatedHTTPClientDecorator: HTTPClient {

  public typealias Result = HTTPClient.Result

  private let decoratee: HTTPClient
  private let config: AuthConfig

  public init(decoratee: HTTPClient, config: AuthConfig) {
    self.decoratee = decoratee
    self.config = config
  }

  public func dispatch(_ request: URLRequest, completion: @escaping (Result) -> Void) -> HTTPClientTask {
    return decoratee.dispatch(enrich(request, with: config), completion: { [weak self] result in
      guard self != nil else { return }
      switch result {
        case let .success(body): completion(.success(body))
        case let .failure(error): completion(.failure(error))
      }
    })
  }

  private func enrich(_ request: URLRequest, with config: AuthConfig) -> URLRequest {
    guard let requestURL = request.url,
          var urlComponents = URLComponents(string: requestURL.absoluteString) else { return request }

    var queryItems: [URLQueryItem] = urlComponents.queryItems ?? []
    queryItems.append(.init(name: "api_key", value: config.secret))

    urlComponents.queryItems = queryItems

    guard let authenticatedRequestURL = urlComponents.url else { return request }

    var signedRequest = request
    signedRequest.url = authenticatedRequestURL
    return signedRequest
  }
}
