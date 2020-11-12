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
    }
    
    // MARK: - Helper
    func configureTableView() {
        tableView.register(EpisodeCell.self, forCellReuseIdentifier: EpisodeCell.reuseId)
        tableView.tableFooterView = UIView()
        tableView.rowHeight = 132
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
        
        if let keyWindow = UIApplication.shared.windows.filter({ $0.isKeyWindow }).first {
            let playerDetailsView = PlayerDetailsView()
            playerDetailsView.episode = episode
            playerDetailsView.artistLabel.text = podcast?.artistName
            playerDetailsView.frame = self.view.frame
            keyWindow.addSubview(playerDetailsView)
        }
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

