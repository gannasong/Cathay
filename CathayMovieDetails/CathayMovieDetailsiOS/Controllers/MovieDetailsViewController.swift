//
//  MovieDetailsViewController.swift
//  CathayMovieDetailsiOS
//
//  Created by SUNG HAO LIN on 2021/8/30.
//

import UIKit
import CathayMovieDetails

protocol MovieDetailsViewControllerDelegate {
  func didRequestLoad()
}

public final class MovieDetailsViewController: UIViewController {
  
  public var onBuyTicket: (() -> Void)?
  private var delegate: MovieDetailsViewControllerDelegate?
  
  private(set) public lazy var customView = view as! MovieDetailsCustomView
  
  convenience init(delegate: MovieDetailsViewControllerDelegate) {
    self.init(nibName: nil, bundle: nil)
    self.delegate = delegate
  }
  
  public override func loadView() {
    view = MovieDetailsCustomView(frame: UIScreen.main.bounds)
  }
  
  public override func viewDidLoad() {
    super.viewDidLoad()
    configureUI()
    configureNavigation()
    delegate?.didRequestLoad()
  }
  
  @objc private func didTapBuyTicket() {
    onBuyTicket?()
  }
  
  private func configureNavigation() {
    navigationController?.navigationBar.titleTextAttributes = [
      NSAttributedString.Key.foregroundColor: #colorLiteral(red: 0.8705882353, green: 0.8705882353, blue: 0.8784313725, alpha: 1),
      NSAttributedString.Key.font: UIFont.systemFont(ofSize: 20)
    ]
    
    navigationController?.navigationBar.tintColor = #colorLiteral(red: 0.8705882353, green: 0.8705882353, blue: 0.8784313725, alpha: 1)
    navigationController?.navigationBar.barTintColor = #colorLiteral(red: 0.1019607843, green: 0.1254901961, blue: 0.1882352941, alpha: 1)
  }
  
  private func configureUI() {
    customView.isLoading = true
    customView.buyTicketButton.addTarget(self, action: #selector(didTapBuyTicket), for: .touchUpInside)
  }
}

extension MovieDetailsViewController: MovieDetailsView {
  public func display(_ model: MovieDetailsViewModel<UIImage>) {
    customView.titleLabel.text = model.title
    customView.metaLabel.text = model.meta
    customView.overviewLabel.text = model.overview
    customView.bakcgroundImageView.image = model.image
    customView.isLoading = model.isLoading
  }
}
