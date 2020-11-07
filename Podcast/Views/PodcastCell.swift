//
//  PodcastCell.swift
//  Podcast
//
//  Created by William Yeung on 11/5/20.
//

import UIKit
import SDWebImage

class PodcastCell: UITableViewCell {
    // MARK: - Properties
    static let reuseId = "PodcastCell"
    
    var podcast: Podcast? {
        didSet {
            guard let podcast = podcast else { return }
            trackNameLabel.text = podcast.trackName
            artistNameLabel.text = podcast.artistName
            episodeCountLabel.text = "\(podcast.trackCount ?? 0) Episodes"
            
            guard let url = URL(string: podcast.artworkUrl600 ?? "") else { return }
            podcastImageView.sd_setImage(with: url, completed: nil)
        }
    }
    
    private let podcastImageView: UIImageView = {
        let iv = UIImageView()
        return iv
    }()
    
    private let trackNameLabel = CustomLabel(withText:  "Track Name", isBolded: true, fontSize: 18, isMultiLine: true)
    private let artistNameLabel = CustomLabel(withText: "Artist Name")
    private let episodeCountLabel = CustomLabel(withText: "Episode Count")
    
    private lazy var infoStack: UIStackView = {
        let stack = UIStackView(arrangedSubviews: [trackNameLabel, artistNameLabel, episodeCountLabel])
        stack.axis = .vertical
        stack.spacing = 3
        return stack
    }()
    
    // MARK: - Init
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        configCell()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Helper
    func configCell() {
        addSubviews(podcastImageView, infoStack)
        
        podcastImageView.setDimension(width: heightAnchor, height: heightAnchor, wMult: 0.75, hMult: 0.75)
        podcastImageView.center(to: self, by: .centerX, withMultiplierOf: 0.35)
        podcastImageView.center(to: self, by: .centerY)
        
        infoStack.center(to: podcastImageView, by: .centerY)
        infoStack.anchor(right: rightAnchor, left: podcastImageView.rightAnchor, paddingRight: 15, paddingLeft: 15)
    }
}
