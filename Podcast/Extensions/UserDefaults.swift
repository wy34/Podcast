//
//  UserDefaults.swift
//  Podcast
//
//  Created by William Yeung on 12/2/20.
//

import Foundation

extension UserDefaults {
    static let favoritedPodcastKey = "favoritedPodcastKey"
    static let downloadedEpisodeKey = "downloadedEpisodeKey"
    
    func savedPodcasts() -> [Podcast] {
        guard let data = UserDefaults.standard.data(forKey: UserDefaults.favoritedPodcastKey) else { return [] }
        guard let decoded = try? JSONDecoder().decode([Podcast].self, from: data) else { return [] }
        return decoded
    }
    
    func downloadEpisode(episode: Episode) {
        var episodes = downloadedEpisodes()
        
        if !episodes.contains(where: { episode.artist == $0.artist && episode.title == $0.title }) {
            episodes.append(episode)
            
            if let encoded = try? JSONEncoder().encode(episodes) {
                UserDefaults.standard.setValue(encoded, forKey: UserDefaults.downloadedEpisodeKey)
            }
        }
    }
    
    func downloadedEpisodes() -> [Episode] {
        if let data = UserDefaults.standard.data(forKey: UserDefaults.downloadedEpisodeKey) {
            if let decoded = try? JSONDecoder().decode([Episode].self, from: data) {
                return decoded
            }
        }
        return []
    }
}
