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
  private var task: ImageDataLoaderTask?

  init(baseURL: URL, model: NowPlayingCard, imageLoader: ImageDataLoader) {
    self.baseURL = baseURL
    self.model = model
    self.imageLoader = imageLoader
  }

  func didRequestLoadImage() {
    presenter?.didStartLoadingImageData(for: model)
    task = imageLoader.load(from: makeImageURL(withPath: model.imagePath), completion: { _ in })
  }

  func didRequestCancelLoadImage() {
    task?.cancel()
    task = nil
  }
  
  private func makeImageURL(withPath path: String) -> URL {
    return baseURL.appendingPathComponent(path)
  }
}
