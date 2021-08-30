//
//  NowPlayingImageDataLoaderPresentationAdapter.swift
//  CathayNowPlayingiOS
//
//  Created by SUNG HAO LIN on 2021/8/30.
//

import Foundation
import CathayMedia
import CathayNowPlaying

final class NowPlayingImageDataLoaderPresentationAdapter<View: NowPlayingImageView, Image>: NowPlayingCardCellControllerDelegate where View.Image == Image {

  var presenter: NowPlayingImagePresenter<View, Image>?

  private let baseURL: URL
  private let model: NowPlayingCard
  private let imageLoader: ImageDataLoader

  init(baseURL: URL, model: NowPlayingCard, imageLoader: ImageDataLoader) {
    self.baseURL = baseURL
    self.model = model
    self.imageLoader = imageLoader
  }

  func didRequestLoadImage() {
    presenter?.didStartLoadingImageData(for: model)
    _ = imageLoader.load(from: makeImageURL(withPath: model.imagePath), completion: { _ in })
  }
  
  private func makeImageURL(withPath path: String) -> URL {
    return baseURL.appendingPathComponent(path)
  }
}
