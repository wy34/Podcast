//
//  PlayerDetailsView.swift
//  Podcast
//
//  Created by William Yeung on 11/8/20.
//

import UIKit
import SDWebImage
import AVKit

class PlayerDetailsView: UIView {
    // MARK: - Properties
    var episode: Episode? {
        didSet {
            guard  let episode = episode else { return }
                 
            titleLabel.text = episode.title 
            
            guard let imageUrl = episode.imageUrl, let url = URL(string: imageUrl) else { return }
            episodeImageView.sd_setImage(with: url, completed: nil)
            playEpisode()
        }
    }
    
    private let player: AVPlayer = {
        let avPlayer = AVPlayer()
        avPlayer.automaticallyWaitsToMinimizeStalling = false
        return avPlayer
    }()
    
    private lazy var dismissButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Dismiss", for: .normal)
        button.tintColor = .black
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 16)
        button.addTarget(self, action: #selector(handleDismiss), for: .touchUpInside)
        return button
    }()
    
    private let episodeImageView: UIImageView = {
        let iv = UIImageView(image: #imageLiteral(resourceName: "appicon"))
        iv.transform = CGAffineTransform(scaleX: 0.75, y: 0.75)
        iv.layer.cornerRadius = 5
        iv.clipsToBounds = true
        return iv
    }()

    private let durationSlider: UISlider = {
        let slider = UISlider()
        slider.value = 0
        slider.tintColor = .lightGray
        let thumbImage = UIImage(systemName: "circlebadge.fill")?.withTintColor(.lightGray, renderingMode: .alwaysOriginal)
        slider.setThumbImage(thumbImage, for: .normal)
        slider.addTarget(self, action: #selector(handleTimeSliderChanged), for: .valueChanged)
        return slider
    }()
    
    let minTimeLabel: AlignedTextLabel = AlignedTextLabel(withText: "00:00:00", textColor: .lightGray, fontSize: 12)
    let maxTimeLabel: AlignedTextLabel = AlignedTextLabel(withText: "--:--:--", textColor: .lightGray, fontSize: 12, andAlignment: .right)
    
    private lazy var timeLabelStack: UIStackView = {
        let stack = UIStackView(arrangedSubviews: [minTimeLabel, maxTimeLabel])
        stack.distribution = .fillEqually
        return stack
    }()
    
    private let titleLabel = AlignedTextLabel(withText: "Episode Title", textColor: .black, isBolded: true, fontSize: 20, andAlignment: .center)
    let artistLabel = AlignedTextLabel(withText: "Author", textColor: #colorLiteral(red: 0.7270483375, green: 0.4584427476, blue: 0.8369832635, alpha: 1), isBolded: true, andAlignment: .center)
    
    private let backwardsBtn = UIButton.createControlButton(withImage: "gobackward.15")
    private let forwardsBtn = UIButton.createControlButton(withImage: "goforward.15")
    private let playPauseBtn = UIButton.createControlButton(withImage: "pause.fill", andSize: 35)

    private lazy var buttonStack: UIStackView = {
        playPauseBtn.addTarget(self, action: #selector(handlePlayPause), for: .touchUpInside)
        backwardsBtn.addTarget(self, action: #selector(handleBackwards), for: .touchUpInside)
        forwardsBtn.addTarget(self, action: #selector(handleForwards), for: .touchUpInside)
        let stack = UIStackView(arrangedSubviews: [backwardsBtn, playPauseBtn, forwardsBtn])
        stack.distribution = .fillEqually
        stack.spacing = 50
        return stack
    }()
    
    private lazy var buttonsContainerView: UIView = {
        let view = UIView()
        return view
    }()
    
    private lazy var volumeSlider: UISlider = {
        let slider = UISlider()
        slider.value = 0.1
        slider.tintColor = .lightGray
        slider.addTarget(self, action: #selector(didChangeVolume), for: .valueChanged)
        return slider
    }()
    
    private let volumeDown = UIButton.createControlButton(withImage: "speaker.fill", color: .gray, andSize: 12)
    private let volumeUp = UIButton.createControlButton(withImage: "speaker.wave.3.fill", color: .gray, andSize: 12)
    
    private lazy var volumeStack: UIStackView = {
        let stack = UIStackView(arrangedSubviews: [volumeDown, volumeSlider, volumeUp])
        stack.spacing = 10
        return stack
    }()
    
    // MARK: - Init
    override init(frame: CGRect) {
        super.init(frame: frame)
        configureUI()
        enlargeEpisodeImageView()
        updateEpisodeTime()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Helpers
    func updateEpisodeTime() {
        let interval = CMTime(value: 1, timescale: 2)
        player.addPeriodicTimeObserver(forInterval: interval, queue: .main) { (time) in
            guard let totalTime = self.player.currentItem?.duration else { return }
            self.maxTimeLabel.text = totalTime.toDisplayString()
            self.minTimeLabel.text = time.toDisplayString()
            self.updateDurationSlider()
        }
    }
    
    func updateDurationSlider() {
        let currentTimeInSeconds = CMTimeGetSeconds(player.currentTime())
        let totalDurationInSeconds = CMTimeGetSeconds(player.currentItem?.duration ?? CMTime(value: 1, timescale: 1))
        durationSlider.value = Float(currentTimeInSeconds / totalDurationInSeconds)
    }
    
    func scaleEpisodeImageView() {
        let scale: CGFloat = 0.75
        UIView.animate(withDuration: 0.75, delay: 0, usingSpringWithDamping: 0.5, initialSpringVelocity: 1, options: .curveEaseOut) {
            self.episodeImageView.transform = self.player.timeControlStatus == .playing ? .identity : CGAffineTransform(scaleX: scale, y: scale)
        }
    }
    
    func enlargeEpisodeImageView() {
        let time = CMTime(value: 1, timescale: 3)
        let times = [NSValue(time: time)]
        player.addBoundaryTimeObserver(forTimes: times, queue: .main) {
            self.scaleEpisodeImageView()
        }
    }
    
    func configureUI() {
        backgroundColor = .white
        
        addSubviews(dismissButton, episodeImageView, durationSlider, timeLabelStack, titleLabel, artistLabel, buttonsContainerView, volumeStack)
        
        dismissButton.center(to: self, by: .centerX)
        dismissButton.anchor(top: safeAreaLayoutGuide.topAnchor, paddingTop: 15)
        
        episodeImageView.setDimension(width: widthAnchor, height: widthAnchor, wMult: 0.8, hMult: 0.8)
        episodeImageView.center(to: self, by: .centerX)
        episodeImageView.anchor(top: dismissButton.bottomAnchor, paddingTop: 10)
        
        durationSlider.anchor(top: episodeImageView.bottomAnchor, right: episodeImageView.rightAnchor, left: episodeImageView.leftAnchor, paddingTop: 10)
        timeLabelStack.anchor(top: durationSlider.bottomAnchor, right: durationSlider.rightAnchor, left: durationSlider.leftAnchor, paddingTop: 2.5)
        
        titleLabel.anchor(top: timeLabelStack.bottomAnchor, right: episodeImageView.rightAnchor, left: episodeImageView.leftAnchor, paddingTop: 15)
        
        artistLabel.anchor(top: titleLabel.bottomAnchor, right: episodeImageView.rightAnchor, left: episodeImageView.leftAnchor, paddingTop: 5)
        
        volumeStack.anchor(right: episodeImageView.rightAnchor, bottom: safeAreaLayoutGuide.bottomAnchor, left: episodeImageView.leftAnchor, paddingBottom: 15)
        volumeStack.anchor(bottom: safeAreaLayoutGuide.bottomAnchor, paddingBottom: 25)
        
        buttonsContainerView.anchor(top: artistLabel.bottomAnchor, right: episodeImageView.rightAnchor, bottom: volumeStack.topAnchor, left: episodeImageView.leftAnchor)
        buttonsContainerView.addSubview(buttonStack)
        buttonStack.center(x: buttonsContainerView.centerXAnchor, y: buttonsContainerView.centerYAnchor)
    }
    
    func playEpisode() {
        guard let url = URL(string: episode?.streamUrl ?? "") else { return }
        let playerItem = AVPlayerItem(url: url)
        player.replaceCurrentItem(with: playerItem)
        player.volume = volumeSlider.value
        player.play()
    }
    
    func skip(amountOfTime time: Float64) {
        let currentEpisodeTime = player.currentTime()
        let skipTime = CMTimeMakeWithSeconds(time, preferredTimescale: 1)
        player.seek(to: CMTimeAdd(currentEpisodeTime, skipTime))
    }

    // MARK: - Selector
    @objc func handleDismiss() {
        player.pause()
        self.removeFromSuperview()
    }
    
    @objc func handleTimeSliderChanged() {
        let sliderPercentage = durationSlider.value
        guard let duration = player.currentItem?.duration else { return }
        let durationInSeconds = CMTimeGetSeconds(duration)
        let seekTimeInSeconds = Float64(sliderPercentage) * durationInSeconds
        let seekTime = CMTimeMakeWithSeconds(seekTimeInSeconds, preferredTimescale: 1)
        player.seek(to: seekTime)
    }
    
    @objc func handleBackwards() {
        skip(amountOfTime: -15)
    }
    
    @objc func handleForwards() {
        skip(amountOfTime: 15)
    }
    
    @objc func handlePlayPause() {
        let largeButton = UIImage.SymbolConfiguration(font: UIFont.systemFont(ofSize: 35))
        
        if player.timeControlStatus == .paused {
            player.play()
            playPauseBtn.setImage(UIImage(systemName: "pause.fill", withConfiguration: largeButton), for: .normal)
        } else {
            player.pause()
            playPauseBtn.setImage(UIImage(systemName: "play.fill",  withConfiguration: largeButton), for: .normal)
        }
        
        scaleEpisodeImageView()
    }
    
    @objc func didChangeVolume() {
        player.volume = volumeSlider.value
    }
}
