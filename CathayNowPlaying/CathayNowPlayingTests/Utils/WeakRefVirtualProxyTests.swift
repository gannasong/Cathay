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

  func test_reference_forObjectIsWeak() {
    var objectStub: ObjectStub? = ObjectStub()
    let sut = WeakRefVirtualProxy(objectStub!)

    objectStub = nil

    XCTAssertNil(sut.object)
  }

  // MARK: - Helpers

  class ObjectStub {

  }
}
