//
//  MainTabBarController.swift
//  Podcast
//
//  Created by William Yeung on 11/1/20.
//

import UIKit

class MainTabBarController: UITabBarController {

    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        configureUI()
    }
    
    // MARK: - Helper
    func configureUI() {
        viewControllers = [
            generateNavigationController(with: ViewController(), title: "Favorites", image: "play.circle.fill", tag: 0),
            generateNavigationController(with: ViewController(), title: "Search", image: "magnifyingglass", tag: 1),
            generateNavigationController(with: ViewController(), title: "Downloads", image: "square.stack.fill", tag: 2)
        ]
    }
    
    func generateNavigationController(with rootViewController: UIViewController, title: String, image: String, tag: Int) -> UIViewController {
        let navController = UINavigationController(rootViewController: rootViewController)
        rootViewController.navigationItem.title = title
        navController.tabBarItem = UITabBarItem(title: title, image: UIImage(systemName: image), tag: tag)
        return navController
    }
}
