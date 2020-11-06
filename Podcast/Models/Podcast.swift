//
//  Podcast.swift
//  Podcast
//
//  Created by William Yeung on 11/2/20.
//

import Foundation

struct Podcast: Decodable {
    var trackName: String?
    var artistName: String?
    var artworkUrl600: String?
    var trackCount: Int?
    var feedUrl: String?
}
