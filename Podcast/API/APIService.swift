//
//  APIService.swift
//  Podcast
//
//  Created by William Yeung on 11/3/20.
//

import Foundation
import Alamofire
import FeedKit

class APIService {
    static let shared = APIService()
    
    func fetchPodcasts(searchText: String, completion: @escaping ([Podcast]) -> Void) {
        let url = "https://itunes.apple.com/search"
        let parameters = ["term": searchText, "media": "podcast"]
        
        AF.request(url, method: .get, parameters: parameters, encoding: URLEncoding.default, headers: nil).responseData { (dataResponse) in
            if let err = dataResponse.error {
                print("Failed to contact yahoo", err)
                completion([])
            }
            
            guard let data = dataResponse.data else { completion([]); return }
            
            do {
                let searchResult = try JSONDecoder().decode(SearchResults.self, from: data)
                completion(searchResult.results)
            } catch let decodeErr {
                print("Failed to decode:", decodeErr)
            }
        }
    }
    
    func fetchEpisodes(feedUrl: String, completion: @escaping ([Episode]) -> Void) {
        guard let url = URL(string: feedUrl) else { return }
        let parser = FeedParser(URL: url)
        parser.parseAsync(result: {(result) in
            switch result {
                case .success(let feed):
                    let rssFeed = feed.rssFeed
                    completion(rssFeed?.toEpisodes() ?? [])
                case .failure(_):
                    completion([])
            }
        })
    }
}
