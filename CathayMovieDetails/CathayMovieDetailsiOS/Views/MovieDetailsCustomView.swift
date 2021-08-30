//
//  MovieDetailsCustomView.swift
//  CathayMovieDetailsiOS
//
//  Created by SUNG HAO LIN on 2021/8/30.
//

import UIKit

public final class MovieDetailsCustomView: UIView {

  var isLoading: Bool = false {
    didSet {
      UIView.transition(with: self, duration: 0.33, options: .transitionCrossDissolve, animations: {
        self.isLoading ? self.loadingIndicator.startAnimating() : self.loadingIndicator.stopAnimating()
        self.vStack.isHidden = self.isLoading
        self.buyTicketButton.isHidden = self.isLoading
      })
    }
  }

  private(set) public var loadingIndicator: UIActivityIndicatorView = {
    let view = UIActivityIndicatorView(style: .large)
    view.translatesAutoresizingMaskIntoConstraints = false
    view.color = #colorLiteral(red: 0.6039215686, green: 0.6588235294, blue: 0.8039215686, alpha: 1)
    return view
  }()

  private(set) public var titleLabel: UILabel = {
    let view = UILabel(frame: .zero)
    view.font = .boldSystemFont(ofSize: 34)
    view.textColor = #colorLiteral(red: 0.8705882353, green: 0.8705882353, blue: 0.8784313725, alpha: 1)
    view.numberOfLines = 0
    return view
  }()

  private(set) public var metaLabel: UILabel = {
    let view = UILabel(frame: .zero)
    view.font = .systemFont(ofSize: 18)
    view.textColor = #colorLiteral(red: 0.662745098, green: 0.6666666667, blue: 0.6784313725, alpha: 1)
    view.numberOfLines = 0
    return view
  }()

  private(set) public var overviewHeaderLabel: UILabel = {
    let view = UILabel(frame: .zero)
    view.font = .systemFont(ofSize: 26)
    view.textColor = #colorLiteral(red: 0.8705882353, green: 0.8705882353, blue: 0.8784313725, alpha: 1)
    view.text = "Storyline"
    return view
  }()

  private(set) public var overviewLabel: UILabel = {
    let view = UILabel(frame: .zero)
    view.font = .systemFont(ofSize: 17)
    view.textColor = #colorLiteral(red: 0.662745098, green: 0.6666666667, blue: 0.6784313725, alpha: 1)
    view.numberOfLines = 0
    return view
  }()

  private(set) public var buyTicketButton: UIButton = {
    let button = UIButton(type: .system)
    button.translatesAutoresizingMaskIntoConstraints = false
    button.setTitle("Buy ticket", for: .normal)
    button.backgroundColor = #colorLiteral(red: 1, green: 0.8392156863, blue: 0.007843137255, alpha: 1)
    button.titleLabel?.font = .systemFont(ofSize: 19)
    button.setTitleColor(#colorLiteral(red: 0.07843137255, green: 0.0862745098, blue: 0.1019607843, alpha: 1), for: .normal)
    button.layer.cornerRadius = 12
    button.clipsToBounds = true
    button.isHidden = true
    return button
  }()

  private let vStack: UIStackView = {
    let view = UIStackView(frame: .zero)
    view.translatesAutoresizingMaskIntoConstraints = false
    view.axis = .vertical
    view.spacing = 8
    view.distribution = .fill
    view.isHidden = true
    return view
  }()

  override init(frame: CGRect) {
    super.init(frame: frame)
    configureUI()
  }

  required init?(coder: NSCoder) {
    return nil
  }

  private func configureUI() {
    backgroundColor = #colorLiteral(red: 0.1019607843, green: 0.1254901961, blue: 0.1882352941, alpha: 1)

    [titleLabel, metaLabel, overviewHeaderLabel, overviewLabel].forEach(vStack.addArrangedSubview)
    vStack.setCustomSpacing(64, after: metaLabel)

    [loadingIndicator, vStack, buyTicketButton].forEach(addSubview)
    NSLayoutConstraint.activate([
      loadingIndicator.centerXAnchor.constraint(equalTo: centerXAnchor),
      loadingIndicator.centerYAnchor.constraint(equalTo: centerYAnchor),

      vStack.leadingAnchor.constraint(equalTo: layoutMarginsGuide.leadingAnchor),
      vStack.trailingAnchor.constraint(equalTo: layoutMarginsGuide.trailingAnchor),
      vStack.bottomAnchor.constraint(equalTo: buyTicketButton.topAnchor, constant: -64),

      buyTicketButton.bottomAnchor.constraint(equalTo: safeAreaLayoutGuide.bottomAnchor, constant: -64),
      buyTicketButton.centerXAnchor.constraint(equalTo: centerXAnchor),
      buyTicketButton.heightAnchor.constraint(equalToConstant: 44),
      buyTicketButton.widthAnchor.constraint(equalToConstant: 148)
    ])
  }
}
