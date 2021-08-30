//
//  MovieLoader.swift
//  CathayMovieDetails
//
//  Created by SUNG HAO LIN on 2021/8/30.
//

import Foundation

public protocol MovieLoader {
  typealias Result = Swift.Result<Movie, Error>

  func load(id: Int, completion: @escaping (Result) -> Void)
}
