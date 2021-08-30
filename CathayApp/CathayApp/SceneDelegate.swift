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

class SceneDelegate: UIResponder, UIWindowSceneDelegate {
  private lazy var config: AuthConfig = getConfig(fromPlist: "AuthConfig")
  private lazy var baseURL: URL = URL(string: "https://api.themoviedb.org")!

  var window: UIWindow?

  func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
    guard let windowScene = (scene as? UIWindowScene) else { return }
    window = UIWindow(windowScene: windowScene)
    window?.rootViewController = UINavigationController(rootViewController: makeNowPlayingScene())
    window?.makeKeyAndVisible()
  }

  private func makeNowPlayingScene() -> NowPlayingViewController {
    let client = URLSessionHTTPClient(session: .init(configuration: .ephemeral))
    let authzClient = AuthenticatedHTTPClientDecorator(decoratee: client, config: config)

    let loader = RemoteNowPlayingLoader(baseURL: baseURL, client: authzClient)
    let imageLoader = RemoteImageDataLoader(client: client)

    let viewController = NowPlayingUIComposer.compose(loader: loader, imageLoader: imageLoader, onSelectCallback: { _ in })
    return viewController
  }
}
