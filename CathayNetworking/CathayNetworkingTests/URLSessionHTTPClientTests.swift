//
//  URLSessionHTTPClientTests.swift
//  CathayNetworkingTests
//
//  Created by SUNG HAO LIN on 2021/8/29.
//

import XCTest
import CathayNetworking

class URLSessionHTTPClientTests: XCTestCase {

  override func tearDown() {
    URLProtocolStub.removeStub()
  }

  func test_dispatch_failsOnRequestError() {
    let error = makeError()

    let receivedError = resultErrorFor(data: nil, response: nil, error: error)

    XCTAssertNotNil(receivedError)
  }

  func test_dispatch_failsOnAllNilValues() {
    let receivedError = resultErrorFor(data: nil, response: nil, error: nil)

    XCTAssertNotNil(receivedError)
  }

  func test_dispatch_failsOnAllInvalidRepresentationCases() {
    let nonHTTPURLResponse = URLResponse(url: makeURL(), mimeType: nil, expectedContentLength: 0, textEncodingName: nil)
    let httpResponse = HTTPURLResponse(url: makeURL(), statusCode: 200, httpVersion: nil, headerFields: nil)
    let data = makeData()
    let error = makeError()

    XCTAssertNotNil(resultErrorFor(data: nil, response: nil, error: nil))
    XCTAssertNotNil(resultErrorFor(data: nil, response: nonHTTPURLResponse, error: nil))
    XCTAssertNotNil(resultErrorFor(data: data, response: nil, error: nil))
    XCTAssertNotNil(resultErrorFor(data: data, response: nil, error: error))
    XCTAssertNotNil(resultErrorFor(data: nil, response: nonHTTPURLResponse, error: error))
    XCTAssertNotNil(resultErrorFor(data: nil, response: httpResponse, error: error))
    XCTAssertNotNil(resultErrorFor(data: data, response: nonHTTPURLResponse, error: error))
    XCTAssertNotNil(resultErrorFor(data: data, response: httpResponse, error: error))
    XCTAssertNotNil(resultErrorFor(data: data, response: nonHTTPURLResponse, error: nil))
  }

  func test_dispatch_succeedsOnHTTPURLResponseWithData() {
    let data = makeData()
    let httpResponse = HTTPURLResponse(url: makeURL(), statusCode: 200, httpVersion: nil, headerFields: nil)
    let output = resultValuesFor(data: data, response: httpResponse, error: nil)

    XCTAssertEqual(output?.data, data)
    XCTAssertEqual(output?.response.url, httpResponse?.url)
    XCTAssertEqual(output?.response.statusCode, httpResponse?.statusCode)
  }

  func test_dispatch_succeedsWithEmptyDataOnHTTPURLResponseWithNilData() {
     let emptyData = makeData(isEmpty: true)
     let httpResponse = HTTPURLResponse(url: makeURL(), statusCode: 200, httpVersion: nil, headerFields: nil)
     let output = resultValuesFor(data: nil, response: httpResponse, error: nil)

     XCTAssertEqual(output?.data, emptyData)
     XCTAssertEqual(output?.response.url, httpResponse?.url)
     XCTAssertEqual(output?.response.statusCode, httpResponse?.statusCode)
   }

  func test_cancelTask_cancelsRequest() {
    let sut = makeSUT()
    let exp = expectation(description: "Wait for completion")

    let task = sut.dispatch(URLRequest(url: makeURL()), completion: { result in
      switch result {
        case let .failure(error as NSError) where error.code == URLError.cancelled.rawValue:
          break
        default:
          XCTFail("Expected cancelled result, got \(result) instead")
      }
      exp.fulfill()
    })

    task.cancel()
    wait(for: [exp], timeout: 0.1)
  }

  // MARK: - Helpers

  func makeSUT(file: StaticString = #file, line: UInt = #line) -> HTTPClient {
    let configuration = URLSessionConfiguration.ephemeral
    configuration.protocolClasses = [URLProtocolStub.self]
    let session = URLSession(configuration: configuration)

    let sut = URLSessionHTTPClient(session: session)
    trackForMemoryLeaks(sut, file: file, line: line)
    return sut
  }

  func resultErrorFor(data: Data?, response: URLResponse?, error: Error?, file: StaticString = #file, line: UInt = #line) -> Error? {
    URLProtocolStub.stub(data: data, response: response, error: error)
    var receivedError: Error? = nil
    let exp = expectation(description: "await completion")
    let sut = makeSUT(file: file, line: line)

    sut.dispatch(URLRequest(url: makeURL()), completion: { result in
      switch result {
      case let .failure(error):
        receivedError = error
      default:
        XCTFail("Expected failure but got \(result) instead", file: file, line: line)
      }

      exp.fulfill()
    })

    wait(for: [exp], timeout: 1)
    return receivedError
  }

  func resultValuesFor(data: Data?, response: URLResponse?, error: Error?, file: StaticString = #file, line: UInt = #line) -> (data: Data, response: HTTPURLResponse)? {
    URLProtocolStub.stub(data: data, response: response, error: error)
    var receivedValues: (Data, HTTPURLResponse)? = nil
    let exp = expectation(description: "await completion")
    let sut = makeSUT(file: file, line: line)

    sut.dispatch(URLRequest(url: makeURL()), completion: { result in
      switch result {
      case let .success(values):
        receivedValues = values
      default:
        XCTFail("Expected success but got \(result) instead", file: file, line: line)
      }

      exp.fulfill()
    })

    wait(for: [exp], timeout: 0.1)
    return receivedValues
  }
}
