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
        setupObservers()
    }

    // MARK: - Helper
    func setupTableView() {
        tableView.backgroundColor = UIColor(named: "DarkMode1")
        tableView.register(EpisodeCell.self, forCellReuseIdentifier: cellId)
        tableView.rowHeight = 134
    }
    
    func setupObservers() {
        NotificationCenter.default.addObserver(self, selector: #selector(handleDownloadProgress), name: .downloadProgress, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(handleDownloadComplete), name: .downloadComplete, object: nil)
    }
    
    // MARK: - Selectors
    @objc func handleDownloadProgress(notification: Notification) {
        guard let userInfo = notification.userInfo as? [String: Any] else { return }
        guard let progress = userInfo["progress"] as? Double else { return }
        guard let title = userInfo["title"] as? String else { return }
        
        guard let index = Array(downloadedEpisodes).firstIndex(where: { $0.title == title }) else { return }
        
        guard let cell = tableView.cellForRow(at: IndexPath(row: index, section: 0)) as? EpisodeCell else { return }
        cell.progressLabel.isHidden = false
        cell.progressLabel.text = "\(Int(progress * 100))%"
        
        if progress == 1 {
            cell.progressLabel.isHidden = true
        }
    }
    
    @objc func handleDownloadComplete(notification: Notification) {
        guard let episodeDownloadComplete = notification.object as? (String, String) else { return }
        guard let index = downloadedEpisodes.firstIndex(where: { $0.title == episodeDownloadComplete.1 }) else { return }
        downloadedEpisodes[index].fileURL = episodeDownloadComplete.0
    }
}

// MARK: - UITableView Delegate/Datesource
extension DownloadsController {
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return downloadedEpisodes.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellId, for: indexPath) as! EpisodeCell
        cell.episode = downloadedEpisodes[indexPath.row]
        return cell
    }
    
    override func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let deleteAction = UIContextualAction(style: .normal, title: "Delete") { (action, view, completion) in
            self.downloadedEpisodes.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .fade)
            if let encoded = try? JSONEncoder().encode(self.downloadedEpisodes) {
                UserDefaults.standard.setValue(encoded, forKey: UserDefaults.downloadedEpisodeKey)
            }
        }
        deleteAction.backgroundColor = .red
        return UISwipeActionsConfiguration(actions: [deleteAction])
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let episode = self.downloadedEpisodes[indexPath.row]
        print(episode.fileURL)
        
        if episode.fileURL != nil {
            UIApplication.mainTabBarController()?.maximizePlayerDetails(episode: episode, playlistEpisodes: self.downloadedEpisodes)
        } else {
            let alert = UIAlertController(title: "File URL not found", message: "Cannot find local file, play using stream url instead", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Yes", style: .default, handler: { (_) in
                UIApplication.mainTabBarController()?.maximizePlayerDetails(episode: episode, playlistEpisodes: self.downloadedEpisodes)
            }))
            alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
            present(alert, animated: true, completion: nil)
        }
    }
}
