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
        guard let url = URL(string: feedUrl) else { return }
        let parser = FeedParser(URL: url)
        parser.parseAsync(result: {(result) in
            switch result {
                case .success(let feed):
                    var episodes = [Episode]()
                    
                    let rssFeed = feed.rssFeed
                    rssFeed?.items?.forEach({ (feedItem) in
                        let episode = Episode(feedItem: feedItem)
                        episodes.append(episode)
                    })
                
                    DispatchQueue.main.async {
                        self.episodes = episodes
                        self.tableView.reloadData()
                    }
                case .failure(let error):
                    print(error.localizedDescription)
                    break
            }
        })
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
}
