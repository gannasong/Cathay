//
//  NowPlayingCardCellController.swift
//  CathayNowPlayingiOS
//
//  Created by SUNG HAO LIN on 2021/8/30.
//

import UIKit

protocol NowPlayingCardCellControllerDelegate {
  func didRequestLoadImage()
  func didCancelLoadImage()
}

final class NowPlayingCardCellController {
  private var cell: NowPlayingCardFeedCell?

  func view(in collectionView: UICollectionView, forItemAt indexPath: IndexPath) -> UICollectionViewCell {
    cell = collectionView.dequeueReusableCell(withReuseIdentifier: "NowPlayingCardFeedCell", for: indexPath) as? NowPlayingCardFeedCell
    return cell!
  }

  func cancel() {
    releaseCellForReuse()
  }

  private func releaseCellForReuse() {
    cell = nil
  }
}
