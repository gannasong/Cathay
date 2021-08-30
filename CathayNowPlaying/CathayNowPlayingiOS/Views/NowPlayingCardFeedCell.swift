//
//  NowPlayingCardFeedCell.swift
//  CathayNowPlayingiOS
//
//  Created by SUNG HAO LIN on 2021/8/29.
//

import UIKit

public final class NowPlayingCardFeedCell: UICollectionViewCell {
  public let imageContainer: UIView = {
    let view = UIView(frame: .zero)
    view.translatesAutoresizingMaskIntoConstraints = false
    return view
  }()

  public let imageView: UIImageView = {
    let view = UIImageView(frame: .zero)
    view.translatesAutoresizingMaskIntoConstraints = false
    return view
  }()
  
  public override init(frame: CGRect) {
    super.init(frame: frame)
    configureUI()
  }

  public required init?(coder: NSCoder) {
    return nil
  }

  private func configureUI() {
    backgroundColor = .darkGray
  }
}
