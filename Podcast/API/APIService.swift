//
//  APIService.swift
//  Podcast
//
//  Created by William Yeung on 11/3/20.
//

import Foundation
import Alamofire

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
//        AF.request(url).responseData { (dataResponse) in
//            if let err = dataResponse.error {
//                print("Failed to contact yahoo", err)
//                return
//            }
//
//            guard let data = dataResponse.data else { return }
//
//            do {
//                let searchResult = try JSONDecoder().decode(SearchResults.self, from: data)
//                self.podcasts = searchResult.results
//                self.tableView.reloadData()
//            } catch let decodeErr {
//                print("Failed to decode:", decodeErr)
//            }
//        }
    }
}
