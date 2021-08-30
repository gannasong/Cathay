//
//  WeakRefVirtualProxy.swift
//  CathayCommon
//
//  Created by SUNG HAO LIN on 2021/8/30.
//

import Foundation

public final class WeakRefVirtualProxy<T: AnyObject> {
  public private(set) weak var object: T?

  public init(_ object: T) {
    self.object = object
  }
}
