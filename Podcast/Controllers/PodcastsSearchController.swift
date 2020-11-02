//
//  PodcastSearchController.swift
//  Podcast
//
//  Created by William Yeung on 11/2/20.
//

import UIKit

class PodcastsSearchController: UITableViewController {
    // MARK: - Properties
    let podcasts = [
        Podcast(name: "Lets Build That App", artist: "Brian Voong"),
        Podcast(name: "Some Podcast", artist: "Some Author")
    ]
    
    let cellId = "cellId"
    
    private lazy var searchController = UISearchController(searchResultsController: nil)
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupSearchBar()
        configureTableView()
    }
    
    // MARK: - Helpers
    func configureTableView() {
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: cellId)
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
        let cell = tableView.dequeueReusableCell(withIdentifier: cellId, for: indexPath)
        
        let podcast =  podcasts[indexPath.row]
        cell.textLabel?.text = "\(podcast.name)\n\(podcast.artist)"
        cell.textLabel?.numberOfLines = -1
        cell.imageView?.image = #imageLiteral(resourceName: "appicon")
        
        return cell
    }
}


// MARK: - SearchController Extension
extension PodcastsSearchController: UISearchBarDelegate {
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        print("changed")
    }
}
