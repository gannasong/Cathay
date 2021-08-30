//
//  GetConfig.swift
//  CathayApp
//
//  Created by SUNG HAO LIN on 2021/8/30.
//

import Foundation

func getConfig<T: Decodable>(fromPlist resource: String) -> T {
  guard let path = Bundle.main.path(forResource: resource, ofType: "plist"),
        let xml = FileManager.default.contents(atPath: path),
        let config = try? PropertyListDecoder().decode(T.self, from: xml) else {
    fatalError("Expected to find \(resource).plist but got nil instead")
  }

  return config
}
