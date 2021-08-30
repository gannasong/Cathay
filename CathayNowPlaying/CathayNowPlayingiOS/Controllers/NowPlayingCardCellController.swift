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

final class NowPlayingCardCellController {
  private var cell: NowPlayingCardFeedCell?
  private let delegate: NowPlayingCardCellControllerDelegate

  init(delegate: NowPlayingCardCellControllerDelegate) {
    self.delegate = delegate
  }

  func view(in collectionView: UICollectionView, forItemAt indexPath: IndexPath) -> UICollectionViewCell {
    cell = collectionView.dequeueReusableCell(withReuseIdentifier: "NowPlayingCardFeedCell", for: indexPath) as? NowPlayingCardFeedCell
    delegate.didRequestLoadImage()
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
}

extension NowPlayingCardCellController: NowPlayingImageView {
  func display(_ model: NowPlayingImageViewModel<UIImage>) {
    cell?.isShimmering = model.isLoading
    cell?.imageView.setImageAnimated(model.image)
  }
}
