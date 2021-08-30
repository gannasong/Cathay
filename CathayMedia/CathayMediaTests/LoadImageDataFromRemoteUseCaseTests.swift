//
//  LoadImageDataFromRemoteUseCaseTests.swift
//  CathayMediaTests
//
//  Created by SUNG HAO LIN on 2021/8/30.
//

import XCTest

class RemoteImageDataLoader {

}

class LoadImageDataFromRemoteUseCaseTests: XCTestCase {

  func test_init_doesNotRequestDataFromRemote() {
    let (_, client) = makeSUT()

    XCTAssertTrue(client.requestedURLs.isEmpty)
  }

  // MARK: - Helpers

  func makeSUT(file: StaticString = #file, line: UInt = #line) -> (sut: RemoteImageDataLoader, client: HTTPClientSpy) {
    let client = HTTPClientSpy()
    let sut = RemoteImageDataLoader()
    trackForMemoryLeaks(sut, file: file, line: line)
    trackForMemoryLeaks(client, file: file, line: line)
    return (sut, client)
  }
}
