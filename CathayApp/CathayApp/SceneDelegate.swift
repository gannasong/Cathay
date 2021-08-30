//
//  SceneDelegate.swift
//  CathayApp
//
//  Created by SUNG HAO LIN on 2021/8/29.
//

import UIKit
import CathayNetworking
import CathayMedia
import CathayNowPlaying
import CathayNowPlayingiOS
import CathayMovieDetails
import CathayMovieDetailsiOS

class SceneDelegate: UIResponder, UIWindowSceneDelegate {
  private lazy var config: AuthConfig = getConfig(fromPlist: "AuthConfig")
  private lazy var baseURL: URL = URL(string: "https://api.themoviedb.org")!
  private lazy var navController = UINavigationController()

  var window: UIWindow?

  func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
    guard let windowScene = (scene as? UIWindowScene) else { return }
    window = UIWindow(windowScene: windowScene)
    navController.setViewControllers([makeNowPlayingScene()], animated: true)
    window?.rootViewController = navController
    window?.makeKeyAndVisible()
  }

  private func makeNowPlayingScene() -> NowPlayingViewController {
    let client = URLSessionHTTPClient(session: .init(configuration: .ephemeral))
    let authzClient = AuthenticatedHTTPClientDecorator(decoratee: client, config: config)

    let loader = RemoteNowPlayingLoader(baseURL: baseURL, client: authzClient)
    let imageLoader = RemoteImageDataLoader(client: client)

    let viewController = NowPlayingUIComposer.compose(loader: loader, imageLoader: imageLoader) { [weak self] movieID in
      guard let self = self else { return }

      let detailsViewController = self.makeMovieDetailScene(for: movieID)
      self.navController.pushViewController(detailsViewController, animated: true)
    }
    return viewController
  }

  private func makeMovieDetailScene(for id: Int) -> MovieDetailsViewController {
    let client = URLSessionHTTPClient(session: .init(configuration: .ephemeral))
    let authzClient = AuthenticatedHTTPClientDecorator(decoratee: client, config: config)

    let loader = RemoteMovieLoader(baseURL: baseURL, client: authzClient)
    let imageLoader = RemoteImageDataLoader(client: client)

    let viewController = MovieDetailsUIComposer.compose(id: id, loader: loader, imageLoader: imageLoader, onPurchaseCallback: { })
    return viewController
  }
}
