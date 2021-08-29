//
//  WeakRefVirtualProxyTests.swift
//  CathayNowPlayingTests
//
//  Created by SUNG HAO LIN on 2021/8/30.
//

import XCTest

final class WeakRefVirtualProxy<T: AnyObject> {
  private(set) weak var object: T?

  init(_ object: T) {
    self.object = object
  }
}

class WeakRefVirtualProxyTests: XCTestCase {

  func test_reference_isSetForObject() {
    let objectStub = ObjectStub()
    let sut = WeakRefVirtualProxy(objectStub)

    XCTAssertEqual(ObjectIdentifier(sut.object!), ObjectIdentifier(objectStub))
  }

  // MARK: - Helpers

  class ObjectStub {

  }
}
