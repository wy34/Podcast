//
//  EpisodesController.swift
//  Podcast
//
//  Created by William Yeung on 11/6/20.
//

import UIKit
import FeedKit

class EpisodesController: UITableViewController {
    // MARK: - Properties
    var podcast: Podcast? {
        didSet {
            guard let podcast = podcast else { return }
            navigationItem.title = podcast.trackName
            fetchEpisodes()
        }
    }

    var episodes = [Episode]()

    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        configureTableView()
        setupNavigationBarButtons()
    }
    
    // MARK: - Helper
    func configureTableView() {
        tableView.register(EpisodeCell.self, forCellReuseIdentifier: EpisodeCell.reuseId)
        tableView.tableFooterView = UIView()
        tableView.rowHeight = 132
        tableView.backgroundColor = UIColor(named: "DarkMode1")
    }
    
    func fetchEpisodes() {
        guard let feedUrl = podcast?.feedUrl else { return }
        APIService.shared.fetchEpisodes(feedUrl: feedUrl) { (episodes) in
            DispatchQueue.main.async {
                self.episodes = episodes
                self.tableView.reloadData()
            }
        }
    }
    
    fileprivate func setupNavigationBarButtons() {
        let savedPodcasts = UserDefaults.standard.savedPodcasts()

        if let _ = savedPodcasts.firstIndex(where: {$0.trackName == self.podcast?.trackName && $0.artistName == self.podcast?.artistName }) {
            navigationItem.rightBarButtonItem = UIBarButtonItem(image: UIImage(systemName: "suit.heart.fill"), style: .plain, target: self, action: #selector(handleSaveFavorite))
        } else {
            navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Favorite", style: .plain, target: self, action: #selector(handleSaveFavorite))
        }
    }
    
    fileprivate func showBadgeHighlight() {
        UIApplication.mainTabBarController()?.viewControllers?[0].tabBarItem.badgeValue = "New"
    }
    
    // MARK: - Selectors
    @objc func handleSaveFavorite() {
        guard let podcast = self.podcast else { return }
        
        var listOfPodcasts = UserDefaults.standard.savedPodcasts()
        
        if !listOfPodcasts.contains(where: {$0.trackName == podcast.trackName && $0.artistName == podcast.artistName }) {
            listOfPodcasts.append(podcast)
            
            if let encoded = try? JSONEncoder().encode(listOfPodcasts) {
                UserDefaults.standard.setValue(encoded, forKey: UserDefaults.favoritedPodcastKey)
            }
            
            showBadgeHighlight()
            navigationItem.rightBarButtonItem = UIBarButtonItem(image: UIImage(systemName: "suit.heart.fill"), style: .plain, target: self, action: #selector(handleSaveFavorite))
        }
    }
}

// MARK: - UITableView
extension EpisodesController {
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return episodes.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: EpisodeCell.reuseId, for: indexPath) as! EpisodeCell
        let episode = episodes[indexPath.row]
        cell.episode = episode
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let episode = self.episodes[indexPath.row]
        tableView.deselectRow(at: indexPath, animated: true)
        
        let mainTabBarController = UIApplication.shared.windows.filter({ $0.isKeyWindow }).first?.rootViewController as? MainTabBarController
        mainTabBarController?.maximizePlayerDetails(artist: podcast?.artistName, episode: episode, playlistEpisodes: self.episodes)
    }
    
    override func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        let activityIndicator = UIActivityIndicatorView(style: .large)
        activityIndicator.color = .darkGray
        activityIndicator.startAnimating()
        return activityIndicator
    }
    
    override func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return episodes.isEmpty ? 200: 0
    }
}

