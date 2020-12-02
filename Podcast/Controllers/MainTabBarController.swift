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
    var maximizedBottomAnchorConstraint: NSLayoutConstraint!

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
            generateNavigationController(with: FavoritesController(collectionViewLayout: UICollectionViewFlowLayout()), title: "Favorites", image: "play.circle.fill", tag: 1),
            generateNavigationController(with: PodcastsSearchController(), title: "Search", image: "magnifyingglass", tag: 0),
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
        playerDetailView.anchor(right: view.rightAnchor, left: view.leftAnchor)
        
        maximizedTopAnchorConstraint = playerDetailView.topAnchor.constraint(equalTo: view.topAnchor, constant: view.frame.height)
        maximizedTopAnchorConstraint.isActive = true
        minimizedTopAnchorConstraint = playerDetailView.topAnchor.constraint(equalTo: tabBar.topAnchor, constant: -64)
        maximizedBottomAnchorConstraint = playerDetailView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: view.frame.height)
        maximizedBottomAnchorConstraint.isActive = true
    }

    func minimizePlayerDetails() {
        UIView.animate(withDuration: 0.25) {
            self.tabBar.isHidden = false
            self.maximizedTopAnchorConstraint.isActive = false
            self.maximizedBottomAnchorConstraint.constant = self.view.frame.height - (self.tabBar.frame.size.height + 64)
            self.minimizedTopAnchorConstraint.isActive = true
            self.view.layoutIfNeeded()
            
            self.playerDetailView.dismissButton.alpha = 0
            self.playerDetailView.episodeImageView.alpha = 0
            self.playerDetailView.miniPlayerView.alpha = 1
        }
    }
    
    func maximizePlayerDetails(artist: String?, episode: Episode?, playlistEpisodes: [Episode] = []) {
        var episode = episode
        episode?.artist = artist
        playerDetailView.episode = episode
        playerDetailView.playlistEpisodes = playlistEpisodes
        
        UIView.animate(withDuration: 0.25) {
            self.tabBar.isHidden = true
            self.minimizedTopAnchorConstraint.isActive = false
            self.maximizedTopAnchorConstraint.isActive = true
            self.maximizedTopAnchorConstraint.constant = 0
            self.maximizedBottomAnchorConstraint.constant = 0
            self.view.layoutIfNeeded()
            
            self.playerDetailView.dismissButton.alpha = 1
            self.playerDetailView.episodeImageView.alpha = 1
            self.playerDetailView.miniPlayerView.alpha = 0
        }
    }
}
