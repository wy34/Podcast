//
//  RSSFeed.swift
//  Podcast
//
//  Created by William Yeung on 11/6/20.
//

import Foundation
import FeedKit

extension RSSFeed {
    func toEpisodes() -> [Episode] {
        var episodes = [Episode]()
        let imageUrl = iTunes?.iTunesImage?.attributes?.href
        
        items?.forEach({ (feedItem) in
            var episode = Episode(feedItem: feedItem)
            
            if episode.imageUrl == nil {
                episode.imageUrl = imageUrl
            }
            
            episodes.append(episode)
        })
        
        return episodes
    }
}
