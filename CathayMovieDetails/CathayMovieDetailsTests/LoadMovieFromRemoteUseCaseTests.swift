//
//  LoadMovieFromRemoteUseCaseTests.swift
//  CathayMovieDetailsTests
//
//  Created by SUNG HAO LIN on 2021/8/30.
//

import XCTest
import CathayNetworking

class RemoteMovieLoader {
  private let baseURL: URL
  private let client: HTTPClient

  init(baseURL: URL, client: HTTPClient) {
    self.baseURL = baseURL
    self.client = client
  }

}

class LoadMovieFromRemoteUseCaseTests: XCTestCase {

  func test_init_doesNotRequestDataFromRemote() {
    let (_, client) = makeSUT()

    XCTAssertTrue(client.requestedURLs.isEmpty)
  }

  // MARK: - Helpers

  func makeSUT(baseURL: URL? = nil, file: StaticString = #file, line: UInt = #line) -> (RemoteMovieLoader, HTTPClientSpy) {
    let client = HTTPClientSpy()
    let sut = RemoteMovieLoader(baseURL: baseURL ?? makeURL(), client: client)
    trackForMemoryLeaks(client, file: file, line: line)
    trackForMemoryLeaks(sut, file: file, line: line)
    return (sut, client)
  }
}
