//
//  FavoritePodcastCell.swift
//  Podcast
//
//  Created by William Yeung on 12/2/20.
//

import UIKit
import SDWebImage

class FavoritePodcastCell: UICollectionViewCell {
    // MARK: - Properties
    var podcast: Podcast? {
        didSet {
            guard let podcast = podcast else { return }
            nameLabel.text = podcast.trackName
            artistNameLabel.text = podcast.artistName
            
            let url = URL(string: podcast.artworkUrl600 ?? "")
            imageView.sd_setImage(with: url, completed: nil)
        }
    }
    
    static let cellId = "FavoritePodcastCell"
    
    private let imageView: UIImageView = {
        let iv = UIImageView(image: #imageLiteral(resourceName: "appicon"))
        return iv
    }()
    
    private let nameLabel: UILabel = {
        let label = UILabel()
        label.text = "Lets Build That App"
        label.font = UIFont.systemFont(ofSize: 15, weight: .semibold)
        return label
    }()
    
    private let artistNameLabel: UILabel = {
        let label = UILabel()
        label.text = "Brian Voong"
        label.font = UIFont.systemFont(ofSize: 13)
        label.textColor = .lightGray
        return label
    }()
    
    private lazy var favoritePodcastStack: UIStackView = {
        let stack = UIStackView(arrangedSubviews: [imageView, nameLabel, artistNameLabel])
        stack.axis = .vertical
        stack.alignment = .leading
        return stack
    }()
    
    // MARK: - Init
    override init(frame: CGRect) {
        super.init(frame: frame)
        configureCell()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Helper
    func configureCell() {
        addSubviews(favoritePodcastStack)
        favoritePodcastStack.anchor(top: topAnchor, right: rightAnchor, bottom: bottomAnchor, left: leftAnchor)
        imageView.setDimension(width: widthAnchor, height: widthAnchor)
    }
}
