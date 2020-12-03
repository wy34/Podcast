//
//  UserDefaults.swift
//  Podcast
//
//  Created by William Yeung on 12/2/20.
//

import Foundation

extension UserDefaults {
    static let favoritedPodcastKey = "favoritedPodcastKey"
    
    func savedPodcasts() -> [Podcast] {
        guard let data = UserDefaults.standard.data(forKey: UserDefaults.favoritedPodcastKey) else { return [] }
        guard let decoded = try? JSONDecoder().decode([Podcast].self, from: data) else { return [] }
        return decoded
    }
}
