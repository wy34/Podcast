//
//  EpisodeCell.swift
//  Podcast
//
//  Created by William Yeung on 11/6/20.
//

import UIKit
import SDWebImage

class EpisodeCell: UITableViewCell {
    // MARK: - Properties
    static let reuseId = "EpisodeCell"
    
    var episode: Episode? {
        didSet {
            guard let episode = episode else { return }
            episodeTitleLabel.text = episode.title
            episodeDescriptionLabel.text = episode.description
            
            let formatter = DateFormatter()
            formatter.dateFormat = "MMM dd, yyyy"
            pubDateLabel.text = formatter.string(from: episode.pubDate)
            
            guard let url = URL(string: episode.imageUrl ?? "") else { return }
            episodeImageView.sd_setImage(with: url, completed: nil)
        }
    }
    
    private let episodeImageView: UIImageView = {
        let iv = UIImageView()
        iv.image = #imageLiteral(resourceName: "appicon")
        return iv
    }()
    
    private let pubDateLabel = CustomLabel(withText:  "pubDate")
    private let episodeTitleLabel = CustomLabel(withText: "title", isBolded: true, fontSize: 18, isMultiLine: true)
    private let episodeDescriptionLabel = CustomLabel(withText: "description", fontSize: 14, isMultiLine: true)
    
    private lazy var infoStack: UIStackView = {
        let stack = UIStackView(arrangedSubviews: [pubDateLabel, episodeTitleLabel, episodeDescriptionLabel])
        stack.axis = .vertical
        stack.spacing = 3
        return stack
    }()
    
    // MARK: - Lifecycle
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        configCell()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Helper
    func configCell() {
        backgroundColor = UIColor(named: "DarkMode1")
        pubDateLabel.textColor = #colorLiteral(red: 0.6888955235, green: 0.3042449951, blue: 0.8343331814, alpha: 1)
        episodeDescriptionLabel.textColor = #colorLiteral(red: 0.6936373115, green: 0.6968496442, blue: 0.7046937346, alpha: 1)
        
        addSubviews(episodeImageView, infoStack)
        
        episodeImageView.setDimension(width: heightAnchor, height: heightAnchor, wMult: 0.75, hMult: 0.75)
        episodeImageView.center(to: self, by: .centerX, withMultiplierOf: 0.35)
        episodeImageView.center(to: self, by: .centerY)
        
        infoStack.center(to: episodeImageView, by: .centerY)
        infoStack.anchor(right: rightAnchor, left: episodeImageView.rightAnchor, paddingRight: 15, paddingLeft: 15)
    }
}
