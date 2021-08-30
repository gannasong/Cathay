//
//  ImageDataLoader.swift
//  CathayMedia
//
//  Created by SUNG HAO LIN on 2021/8/30.
//

import Foundation

public protocol ImageDataLoaderTask {
  func cancel()
}

public protocol ImageDataLoader {
  typealias Result = Swift.Result<Data, Error>

  func load(from imageURL: URL, completion: @escaping (Result) -> Void) -> ImageDataLoaderTask
}
