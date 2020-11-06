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
    
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let label = UILabel()
        label.text = "Please enter a Search Term"
        label.textAlignment = .center
        label.font = UIFont.systemFont(ofSize: 18, weight: .semibold)
        return label
    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return podcasts.count == 0 ? 250 : 0
    }
}

// MARK: - SearchController Extension
extension PodcastsSearchController: UISearchBarDelegate {
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        APIService.shared.fetchPodcasts(searchText: searchText) { (podcasts) in
            self.podcasts = podcasts
            self.tableView.reloadData()
        }
    }
}
