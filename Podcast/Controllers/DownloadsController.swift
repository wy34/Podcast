//
//  DownloadsController.swift
//  Podcast
//
//  Created by William Yeung on 12/4/20.
//

import UIKit

class DownloadsController: UITableViewController {
    // MARK: - Properties
    fileprivate let cellId = "cellId"
    
    private var downloadedEpisodes = UserDefaults.standard.downloadedEpisodes()
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupTableView()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        downloadedEpisodes = UserDefaults.standard.downloadedEpisodes()
        tableView.reloadData()
    }

    // MARK: - Helper
    func setupTableView() {
        tableView.backgroundColor = UIColor(named: "DarkMode1")
        tableView.register(EpisodeCell.self, forCellReuseIdentifier: cellId)
        tableView.rowHeight = 134
    }
}

// MARK: - UITableView Delegate/Datesource
extension DownloadsController {
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return downloadedEpisodes.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellId, for: indexPath) as! EpisodeCell
        cell.episode = downloadedEpisodes.reversed()[indexPath.row]
        return cell
    }
    
    override func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let deleteAction = UIContextualAction(style: .normal, title: "Delete") { (action, view, completion) in
            self.downloadedEpisodes.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .fade)
            if let encoded = try? JSONEncoder().encode(self.downloadedEpisodes) {
                UserDefaults.standard.setValue(encoded, forKey: UserDefaults.downloadedEpisodeKey)
            }
            completion(true)
        }
        deleteAction.backgroundColor = .red
        return UISwipeActionsConfiguration(actions: [deleteAction])
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let episode = self.downloadedEpisodes.reversed()[indexPath.row]
        UIApplication.mainTabBarController()?.maximizePlayerDetails(episode: episode, playlistEpisodes: self.downloadedEpisodes)
    }
}
