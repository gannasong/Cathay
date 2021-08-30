//
//  WeakRefVirtualProxyTests.swift
//  CathayCommonTests
//
//  Created by SUNG HAO LIN on 2021/8/30.
//

import XCTest
import CathayCommon

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

  class ObjectStub {}
}
