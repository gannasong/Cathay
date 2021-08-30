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
  
  private(set) public lazy var customView = view as! MovieDetailsCustomView
  
  public convenience init(id: Int, loader: MovieLoader) {
    self.init(nibName: nil, bundle: nil)
    self.id = id
    self.loader = loader
  }
  
  public override func loadView() {
    view = MovieDetailsCustomView(frame: UIScreen.main.bounds)
  }
  
  public override func viewDidLoad() {
    super.viewDidLoad()
    configureUI()
    configureNavigation()
    
    loader?.load(id: id!, completion: { [weak self] result in
      
      if let movie = try? result.get() {
        self?.customView.titleLabel.text = movie.title
        
        let runTime = Double(movie.length * 60).asString(style: .short)
        let genres = movie.genres.map { $0.capitalizingFirstLetter() }.joined(separator: ", ")
        self?.customView.metaLabel.text = "\(runTime) | \(genres)"
        self?.customView.overviewLabel.text = movie.overview
      }
      
      self?.customView.isLoading = false
    })
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
