//
//  MainTabBarController.swift
//  Podcast
//
//  Created by William Yeung on 11/1/20.
//

import UIKit

class MainTabBarController: UITabBarController {
    // MARK: - Properties
    let playerDetailView = PlayerDetailsView()
    var maximizedTopAnchorConstraint: NSLayoutConstraint!
    var minimizedTopAnchorConstraint: NSLayoutConstraint!

    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        configureUI()
        setupPlayerDetailsView()
    }
    
    // MARK: - Helper
    func configureUI() {
        tabBar.tintColor = .purple
        viewControllers = [
            generateNavigationController(with: PodcastsSearchController(), title: "Search", image: "magnifyingglass", tag: 0),
            generateNavigationController(with: ViewController(), title: "Favorites", image: "play.circle.fill", tag: 1),
            generateNavigationController(with: ViewController(), title: "Downloads", image: "square.stack.fill", tag: 2)
        ]
    }
    
    func generateNavigationController(with rootViewController: UIViewController, title: String, image: String, tag: Int) -> UIViewController {
        let navController = UINavigationController(rootViewController: rootViewController)
        rootViewController.navigationItem.title = title
        navController.tabBarItem = UITabBarItem(title: title, image: UIImage(systemName: image), tag: tag)
        return navController
    }
    
    func setupPlayerDetailsView() {
        view.insertSubview(playerDetailView, belowSubview: tabBar)
        playerDetailView.anchor(right: view.rightAnchor, bottom: view.bottomAnchor, left: view.leftAnchor)
        
        maximizedTopAnchorConstraint = playerDetailView.topAnchor.constraint(equalTo: view.topAnchor, constant: view.frame.height)
        maximizedTopAnchorConstraint.isActive = true
        minimizedTopAnchorConstraint = playerDetailView.topAnchor.constraint(equalTo: tabBar.topAnchor, constant: -64)
    }

    func minimizePlayerDetails() {
        UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 0.7, initialSpringVelocity: 1, options: .curveEaseOut) {
            self.tabBar.isHidden = false
            self.maximizedTopAnchorConstraint.isActive = false
            self.minimizedTopAnchorConstraint.isActive = true
            self.view.layoutIfNeeded()
        }
    }
    
    func maximizePlayerDetails(episode: Episode?) {
        playerDetailView.episode = episode
        UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 0.7, initialSpringVelocity: 1, options: .curveEaseOut) {
            self.tabBar.isHidden = true
            self.maximizedTopAnchorConstraint.isActive = true
            self.maximizedTopAnchorConstraint.constant = 0
            self.minimizedTopAnchorConstraint.isActive = false
            self.view.layoutIfNeeded()
        }
    }
}
