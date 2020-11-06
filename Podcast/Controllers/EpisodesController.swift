//
//  EpisodesController.swift
//  Podcast
//
//  Created by William Yeung on 11/6/20.
//

import UIKit

class EpisodesController: UITableViewController {
    // MARK: - Properties
    var podcast: Podcast? {
        didSet {
            guard let podcast = podcast else { return }
            navigationItem.title = podcast.trackName
        }
    }
    
    var episodes = [Episode(title: "First Episode"), Episode(title: "Second Episode"), Episode(title: "Third Episode")]
    
    fileprivate let cellId = "cellId"

    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        configureTableView()
    }
    
    // MARK: - Helper
    func configureTableView() {
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: cellId)
        tableView.tableFooterView = UIView()
    }
}

// MARK: - UITableView
extension EpisodesController {
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return episodes.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellId, for: indexPath)
        let episode = episodes[indexPath.row]
        cell.textLabel?.text = "\(episode.title)"
        return cell
    }
}
