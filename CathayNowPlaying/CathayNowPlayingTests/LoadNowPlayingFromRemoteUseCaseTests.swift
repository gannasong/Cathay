//
//  LoadNowPlayingFromRemoteUseCaseTests.swift
//  CathayNowPlayingTests
//
//  Created by SUNG HAO LIN on 2021/8/29.
//

import XCTest

class RemoteNowPlayingLoader {

}

class LoadNowPlayingFromRemoteUseCaseTests: XCTestCase {

  func test_init_doesNotRequestDataFromURL() {
    let (_, client) = makeSUT()

    XCTAssertTrue(client.requestedURLs.isEmpty)
  }

  // MARK: - Helpers

  func makeSUT(file: StaticString = #file, line: UInt = #line) -> (RemoteNowPlayingLoader, HTTPClientSpy) {
    let client = HTTPClientSpy()
    let sut = RemoteNowPlayingLoader()

    trackForMemoryLeaks(client, file: file, line: line)
    trackForMemoryLeaks(sut, file: file, line: line)

    return (sut, client)
  }

  class HTTPClientSpy {
    private(set) var requestedURLs = [URL]()
  }
}
