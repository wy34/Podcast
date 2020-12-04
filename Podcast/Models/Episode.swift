//
//  Episode.swift
//  Podcast
//
//  Created by William Yeung on 11/6/20.
//

import Foundation
import FeedKit

struct Episode: Codable {
    let title: String
    var artist: String?
    let pubDate: Date
    let description: String
    var imageUrl: String?
    var streamUrl: String
    
    init(feedItem: RSSFeedItem) {
        self.title = feedItem.title ?? ""
        self.pubDate = feedItem.pubDate ?? Date()
        self.description = feedItem.iTunes?.iTunesSubtitle ?? feedItem.description ?? ""
        self.imageUrl = feedItem.iTunes?.iTunesImage?.attributes?.href
        self.streamUrl = feedItem.enclosure?.attributes?.url ?? ""
    }
}
