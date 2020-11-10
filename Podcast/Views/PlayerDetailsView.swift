//
//  PlayerDetailsView.swift
//  Podcast
//
//  Created by William Yeung on 11/8/20.
//

import UIKit
import SDWebImage

class PlayerDetailsView: UIView {
    // MARK: - Properties
    var episode: Episode? {
        didSet {
            guard  let episode = episode else { return }
            
            titleLabel.text = episode.title
            
            guard let imageUrl = episode.imageUrl, let url = URL(string: imageUrl) else { return }
            episodeImageView.sd_setImage(with: url, completed: nil)
        }
    }
    
    private lazy var dismissButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Dismiss", for: .normal)
        button.tintColor = .black
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 16)
        button.addTarget(self, action: #selector(handleDismiss), for: .touchUpInside)
        return button
    }()
    
    private let episodeImageView = UIImageView(image: #imageLiteral(resourceName: "appicon"))

    private let durationSlider: UISlider = {
        let slider = UISlider()
        slider.value = 0.5
        return slider
    }()
    
    let minTimeLabel: AlignedTextLabel = AlignedTextLabel(withText: "00:00:00", textColor: .lightGray)
    let maxTimeLabel: AlignedTextLabel = AlignedTextLabel(withText: "99:99:99", textColor: .lightGray, andAlignment: .right)
    
    private lazy var timeLabelStack: UIStackView = {
        let stack = UIStackView(arrangedSubviews: [minTimeLabel, maxTimeLabel])
        stack.distribution = .fillEqually
        return stack
    }()
    
    private let titleLabel = AlignedTextLabel(withText: "Episode Title", textColor: .black, isBolded: true, andAlignment: .center)
    private let artistLabel = AlignedTextLabel(withText: "Author", textColor: #colorLiteral(red: 0.7270483375, green: 0.4584427476, blue: 0.8369832635, alpha: 1), isBolded: true, andAlignment: .center)
    
    private let backwardsBtn = UIButton.createControlButton(withImage: "gobackward.15")
    private let forwardsBtn = UIButton.createControlButton(withImage: "goforward.15")
    private let playPause = UIButton.createControlButton(withImage: "play.fill")

    private lazy var buttonStack: UIStackView = {
        let stack = UIStackView(arrangedSubviews: [backwardsBtn, playPause, forwardsBtn])
        stack.distribution = .fillEqually
        return stack
    }()
    
    private lazy var detailStackView: UIStackView = {
        let stack = UIStackView(arrangedSubviews: [dismissButton, episodeImageView, durationSlider, timeLabelStack, titleLabel, artistLabel, buttonStack])
        stack.axis = .vertical
        stack.alignment = .center
        return stack
    }()
    
    // MARK: - Init
    override init(frame: CGRect) {
        super.init(frame: frame)
        configureUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Helpers
    func configureUI() {
        backgroundColor = .white
        addSubviews(detailStackView)
        detailStackView.anchor(top: safeAreaLayoutGuide.topAnchor, right: rightAnchor, bottom: safeAreaLayoutGuide.bottomAnchor, left: leftAnchor)
        
        dismissButton.setDimension(width: widthAnchor, height: heightAnchor, wMult: 0.25, hMult: 0.06)
        episodeImageView.setDimension(width: widthAnchor, height: widthAnchor, wMult: 0.9, hMult: 0.9)
        durationSlider.setDimension(width: episodeImageView.widthAnchor, height: heightAnchor, hMult: 0.05)
        timeLabelStack.anchor(right: durationSlider.rightAnchor, left: durationSlider.leftAnchor)
        titleLabel.anchor(right: durationSlider.rightAnchor, left: durationSlider.leftAnchor)
    }
    
    // MARK: - Selector
    @objc func handleDismiss() {
        self.removeFromSuperview()
    }
}
