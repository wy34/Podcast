//
//  PodcastSearchController.swift
//  Podcast
//
//  Created by William Yeung on 11/2/20.
//

import UIKit

class PodcastsSearchController: UITableViewController {
    // MARK: - Properties
    var podcasts = [Podcast]()
    
    private lazy var searchController = UISearchController(searchResultsController: nil)
    
    var timer: Timer?
    
    private let searchingLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        label.font = UIFont.systemFont(ofSize: 18, weight: .semibold)
        return label
    }()
    
    private let searchingIndicator: UIActivityIndicatorView = {
        let ai = UIActivityIndicatorView(style: .large)
        ai.color = .gray
        return ai
    }()

    private lazy var searchingStack: UIStackView = {
        let stack = UIStackView(arrangedSubviews: [searchingIndicator, searchingLabel])
        stack.axis = .vertical
        stack.spacing = -175
        stack.distribution = .fillEqually
        return stack
    }()
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupSearchBar()
        configureTableView()
    }
    
    // MARK: - Helpers
    func configureTableView() {
        tableView.register(PodcastCell.self, forCellReuseIdentifier: PodcastCell.reuseId)
        tableView.rowHeight = 132
        tableView.tableFooterView = UIView()
    }
    
    func setupSearchBar() {
        navigationItem.searchController = searchController
        navigationItem.hidesSearchBarWhenScrolling = false
        searchController.searchBar.delegate = self
        searchController.obscuresBackgroundDuringPresentation = false
    }
}

// MARK: - TableView Extension
extension PodcastsSearchController {
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return podcasts.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: PodcastCell.reuseId, for: indexPath) as! PodcastCell
        let podcast =  podcasts[indexPath.row]
        cell.podcast = podcast
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let episodesController = EpisodesController()
        let podcast = podcasts[indexPath.row]
        episodesController.podcast = podcast
        navigationController?.pushViewController(episodesController, animated: true)
    }
    
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let label = UILabel()
        label.text = "No results, please enter a search query."
        label.textAlignment = .center
        label.font = UIFont.systemFont(ofSize: 18, weight: .semibold)
        return label
    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return podcasts.count == 0 && searchController.searchBar.text == "" ? 250 : 0
    }
    
    override func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        return searchingStack
    }
    
    override func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return podcasts.count == 0 && searchController.searchBar.text != "" ? 250 : 0
    }
}

// MARK: - SearchController Extension
extension PodcastsSearchController: UISearchBarDelegate {
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        searchingLabel.text = "Currently Searching..."
        searchingIndicator.startAnimating()
        podcasts.removeAll()
        tableView.reloadData()
        
        timer?.invalidate()
        timer = Timer.scheduledTimer(withTimeInterval: 0.5, repeats: false) { (timer) in
            APIService.shared.fetchPodcasts(searchText: searchText) { (podcasts) in
                if podcasts.isEmpty {
                    self.searchingLabel.text = "Cannot Find Podcast"
                } else {
                    self.podcasts = podcasts
                    self.tableView.reloadData()
                }
                self.searchingIndicator.stopAnimating()
            }
        }
    }
}
