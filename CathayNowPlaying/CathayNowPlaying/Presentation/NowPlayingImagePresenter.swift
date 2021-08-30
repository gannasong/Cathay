//
//  NowPlayingImagePresenter.swift
//  CathayNowPlaying
//
//  Created by SUNG HAO LIN on 2021/8/30.
//

import Foundation

public protocol NowPlayingImageView {
  associatedtype Image

  func display(_ model: NowPlayingImageViewModel<Image>)
}

public final class NowPlayingImagePresenter<View: NowPlayingImageView, Image> where View.Image == Image {
  private let view: View
  private let imageTransformer: (Data) -> Image?

  public init(view: View, imageTransformer: @escaping (Data) -> Image?) {
    self.view = view
    self.imageTransformer = imageTransformer
  }

  public func didStartLoadingImageData(for model: NowPlayingCard) {
    view.display(NowPlayingImageViewModel<Image>(image: nil, title: model.title, isLoading: true))
  }

  public func didFinishLoadingImageData(with data: Data, for model: NowPlayingCard) {
    let image = imageTransformer(data)
    view.display(NowPlayingImageViewModel<Image>(image: image, title: model.title, isLoading: false))
  }

  public func didFinishLoadingImageData(with error: Error, for model: NowPlayingCard) {
    view.display(NowPlayingImageViewModel<Image>(image: nil, title: model.title, isLoading: false))
  }
}
