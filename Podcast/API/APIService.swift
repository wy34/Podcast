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
    
    func downloadEpisode(episode: Episode) {
        let downloadRequest = DownloadRequest.suggestedDownloadDestination()
        AF.download(episode.streamUrl, to: downloadRequest).downloadProgress { (progress) in
            NotificationCenter.default.post(name: .downloadProgress, object: nil, userInfo: ["title": episode.title, "progress": progress.fractionCompleted])
        }.response { (resp) in
            print(FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first?.absoluteString)
            if let fileURL = resp.fileURL?.absoluteString {
                var downloadedEpisodes = UserDefaults.standard.downloadedEpisodes()
                guard let index = downloadedEpisodes.firstIndex(where: { $0.title == episode.title && $0.artist == episode.artist }) else { return }
                downloadedEpisodes[index].fileURL = fileURL

                if let encoded = try? JSONEncoder().encode(downloadedEpisodes) {
                    UserDefaults.standard.setValue(encoded, forKey: UserDefaults.downloadedEpisodeKey)
                }
                
                let episodeDownloadCompleteTuple = (resp.fileURL?.absoluteString, episode.title)
                NotificationCenter.default.post(name: .downloadComplete, object: episodeDownloadCompleteTuple, userInfo: nil)
            } 
        }
    }
}

extension Notification.Name {
    static let downloadProgress = Notification.Name("downloadProgress")
    static let downloadComplete = Notification.Name("downloadComplete")
}
