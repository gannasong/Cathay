//
//  NowPlayingCardCellController.swift
//  CathayNowPlayingiOS
//
//  Created by SUNG HAO LIN on 2021/8/30.
//

import UIKit
import CathayNowPlaying

protocol NowPlayingCardCellControllerDelegate {
  func didRequestLoadImage()
  func didRequestCancelLoadImage()
}

final class NowPlayingCardCellController: Hashable {
  private let id: Int

  static func == (lhs: NowPlayingCardCellController, rhs: NowPlayingCardCellController) -> Bool {
    lhs.id == rhs.id
  }

  func hash(into hasher: inout Hasher) {
    hasher.combine(id)
  }

  var didSelect: (() -> Void)?

  private var cell: NowPlayingCardFeedCell?
  private let delegate: NowPlayingCardCellControllerDelegate

  init(id: Int, delegate: NowPlayingCardCellControllerDelegate) {
    self.id = id
    self.delegate = delegate
  }

  func view(in collectionView: UICollectionView, forItemAt indexPath: IndexPath) -> UICollectionViewCell {
    cell = collectionView.dequeueReusableCell(withReuseIdentifier: "NowPlayingCardFeedCell", for: indexPath) as? NowPlayingCardFeedCell
    return cell!
  }

  func cancelLoad() {
    delegate.didRequestCancelLoadImage()
    relaseCellForReuse()
  }

  func prefetch() {
    delegate.didRequestLoadImage()
  }

  func relaseCellForReuse() {
    cell = nil
  }

  func select() {
    didSelect?()
  }
}

extension NowPlayingCardCellController: NowPlayingImageView {
  func display(_ model: NowPlayingImageViewModel<UIImage>) {
    cell?.isShimmering = model.isLoading
    cell?.imageView.setImageAnimated(model.image)
  }
}
