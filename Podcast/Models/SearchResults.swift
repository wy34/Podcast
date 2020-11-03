//
//  SearchResults.swift
//  Podcast
//
//  Created by William Yeung on 11/3/20.
//

import UIKit

struct SearchResults: Decodable {
    let resultCount: Int
    let results: [Podcast]
}
