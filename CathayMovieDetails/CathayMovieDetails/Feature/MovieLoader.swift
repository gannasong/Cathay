//
//  MovieLoader.swift
//  CathayMovieDetails
//
//  Created by SUNG HAO LIN on 2021/8/30.
//

import Foundation

protocol MovieLoader {
  typealias Result = Swift.Result<Movie, Error>

  func load(id: String, completion: @escaping (Result) -> Void)
}
