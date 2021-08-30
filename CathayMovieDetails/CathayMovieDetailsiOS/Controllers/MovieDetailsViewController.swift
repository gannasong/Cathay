//
//  MovieDetailsViewController.swift
//  CathayMovieDetailsiOS
//
//  Created by SUNG HAO LIN on 2021/8/30.
//

import UIKit
import CathayMovieDetails

public final class MovieDetailsViewController: UIViewController {

  public var onBuyTicket: (() -> Void)?

  private var id: Int?
  private var loader: MovieLoader?

  private(set) public var loadingIndicator: UIActivityIndicatorView = {
    let view = UIActivityIndicatorView(style: .large)
    view.translatesAutoresizingMaskIntoConstraints = false
    return view
  }()

  private(set) public var titleLabel: UILabel = {
    let view = UILabel(frame: .zero)
    return view
  }()

  private(set) public var metaLabel: UILabel = {
    let view = UILabel(frame: .zero)
    return view
  }()

  private(set) public var overviewLabel: UILabel = {
    let view = UILabel(frame: .zero)
    return view
  }()

  private(set) public var buyTicketButton: UIButton = {
    let button = UIButton(type: .system)
    button.setTitle("Buy ticket", for: .normal)
    return button
  }()

  public  convenience init(id: Int, loader: MovieLoader) {
    self.init(nibName: nil, bundle: nil)
    self.id = id
    self.loader = loader
  }

  public override func viewDidLoad() {
    super.viewDidLoad()
    buyTicketButton.addTarget(self, action: #selector(didTapBuyTicket), for: .touchUpInside)

    loadingIndicator.startAnimating()
    loader?.load(id: id!, completion: { [weak self] result in

      if let movie = try? result.get() {
        self?.titleLabel.text = movie.title

        let runTime = Double(movie.length * 60).asString(style: .short)
        let genres = movie.genres.map { $0.capitalizingFirstLetter() }.joined(separator: ", ")
        self?.metaLabel.text = "\(runTime) | \(genres)"
        self?.overviewLabel.text = movie.overview
      }

      self?.loadingIndicator.stopAnimating()
    })
  }

  @objc private func didTapBuyTicket() {
    onBuyTicket?()
  }
}
