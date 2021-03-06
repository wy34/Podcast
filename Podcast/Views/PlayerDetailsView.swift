//
//  PlayerDetailsView.swift
//  Podcast
//
//  Created by William Yeung on 11/8/20.
//

import UIKit
import SDWebImage
import AVKit
import MediaPlayer

class PlayerDetailsView: UIView {
    // MARK: - Properties
    var episode: Episode? {
        didSet {
            guard  let episode = episode else { return }
                 
            titleLabel.text = episode.title
            artistLabel.text = episode.artist
            miniTitleLabel.text = episode.title
            
            guard let imageUrl = episode.imageUrl, let url = URL(string: imageUrl) else { return }
            episodeImageView.sd_setImage(with: url, completed: nil)
            setupAudioSession()
            playEpisode()
            updatePlayPauseBtnImage(withImageName: "pause.fill")
            setupNowPlayingInfo()
            miniEpisodeImageView.sd_setImage(with: url) { (image, _, _, _) in
                guard let image = image else { return }
                var nowPlayingInfo = MPNowPlayingInfoCenter.default().nowPlayingInfo
                let artwork = MPMediaItemArtwork(boundsSize: image.size) { (_) -> UIImage in
                    return image
                }
                nowPlayingInfo?[MPMediaItemPropertyArtwork] = artwork
                MPNowPlayingInfoCenter.default().nowPlayingInfo = nowPlayingInfo
            }
        }
    }
    
    var playlistEpisodes = [Episode]()
    
    private var panGesture: UIPanGestureRecognizer!
    
    private let player: AVPlayer = {
        let avPlayer = AVPlayer()
        avPlayer.automaticallyWaitsToMinimizeStalling = true
        return avPlayer
    }()
    
    lazy var dismissButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Dismiss", for: .normal)
        button.tintColor = UIColor(named: "DarkMode2")
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 16)
        button.addTarget(self, action: #selector(handleDismiss), for: .touchUpInside)
        return button
    }()
    
    let episodeImageView: UIImageView = {
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
    
    private let titleLabel = AlignedTextLabel(withText: "Episode Title", textColor: UIColor(named: "DarkMode2")!, isBolded: true, fontSize: 20, andAlignment: .center)
    let artistLabel = AlignedTextLabel(withText: "Author", textColor: .systemPurple, isBolded: true, andAlignment: .center)
    
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
    
    let miniPlayerView = UIView()
    let miniPlayerSeparatorView = UIView()
    
    private let miniEpisodeImageView: UIImageView = {
        let iv = UIImageView()
        iv.image = #imageLiteral(resourceName: "appicon")
        iv.layer.cornerRadius = 5
        iv.clipsToBounds = true
        return iv
    }()
    
    private let miniTitleLabel = CustomLabel(withText: "Episode Title", isBolded: true, fontSize: 20, isMultiLine: false)
    private let miniPlayPauseBtn = UIButton.createControlButton(withImage: "pause.fill", andSize: 18)
    private let miniForwardBtn = UIButton.createControlButton(withImage: "goforward.15", andSize: 18)
    
    private lazy var miniPlayerViewStack: UIStackView = {
        miniPlayPauseBtn.addTarget(self, action: #selector(handlePlayPause), for: .touchUpInside)
        miniForwardBtn.addTarget(self, action: #selector(handleForwards), for: .touchUpInside)
        let stack = UIStackView(arrangedSubviews: [miniEpisodeImageView, miniTitleLabel, miniPlayPauseBtn, miniForwardBtn])
        stack.alignment = .center
        stack.spacing = 8
        return stack
    }()
    
    // MARK: - Init
    override init(frame: CGRect) {
        super.init(frame: frame)
        configureUI()
        enlargeEpisodeImageView()
        updateEpisodeTime()
        addGestureToMaximizeView()
//        setupAudioSession()
        setupRemoteControl()
        setupInterruptionObserver()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Helpers
    fileprivate func setupAudioSession() {
        do {
            try AVAudioSession.sharedInstance().setCategory(.playback)
            try AVAudioSession.sharedInstance().setActive(true)
        } catch let sessionError {
            print(sessionError.localizedDescription)
        }
    }
    
    fileprivate func setupRemoteControl() {
        UIApplication.shared.beginReceivingRemoteControlEvents()
        
        let commandCenter = MPRemoteCommandCenter.shared()
        
        commandCenter.playCommand.isEnabled = true
        commandCenter.playCommand.addTarget { (_) -> MPRemoteCommandHandlerStatus in
            self.player.play()
            self.scaleEpisodeImageView()
            self.updatePlayPauseBtnImage(withImageName: "pause.fill")
            
            MPNowPlayingInfoCenter.default().nowPlayingInfo?[MPNowPlayingInfoPropertyPlaybackRate] = 1
            
            return .success
        }
        
        commandCenter.pauseCommand.isEnabled = true
        commandCenter.pauseCommand.addTarget { (_) -> MPRemoteCommandHandlerStatus in
            self.player.pause()
            self.scaleEpisodeImageView()
            self.updatePlayPauseBtnImage(withImageName: "play.fill")
            
            MPNowPlayingInfoCenter.default().nowPlayingInfo?[MPNowPlayingInfoPropertyPlaybackRate] = 0
            
            return .success
        }
        
        commandCenter.togglePlayPauseCommand.isEnabled = true
        commandCenter.togglePlayPauseCommand.addTarget { (_) -> MPRemoteCommandHandlerStatus in
            self.handlePlayPause()
            return .success
        }
        
        commandCenter.nextTrackCommand.isEnabled = true
        commandCenter.nextTrackCommand.addTarget { (_) -> MPRemoteCommandHandlerStatus in
            self.handlePreviousNextTrack(previous: false)
        }
        
        commandCenter.previousTrackCommand.isEnabled = true
        commandCenter.previousTrackCommand.addTarget { (_) -> MPRemoteCommandHandlerStatus in
            self.handlePreviousNextTrack(previous: true)
        }
    }
    
    fileprivate func handlePreviousNextTrack(previous: Bool) -> MPRemoteCommandHandlerStatus {
        if let indexOfCurrentEpisode = self.playlistEpisodes.firstIndex(where: { self.episode?.title == $0.title }) {
            if indexOfCurrentEpisode != (previous ? 0 :  self.playlistEpisodes.count - 1) {
                self.episode = self.playlistEpisodes[previous ? indexOfCurrentEpisode - 1 : indexOfCurrentEpisode + 1]
            } else {
                self.episode = self.playlistEpisodes[previous ? self.playlistEpisodes.count - 1 : 0]
            }
        } else {
            return .noActionableNowPlayingItem
        }
        return .success
    }
    
    fileprivate func setupNowPlayingInfo() {
        var nowPlayingInfo = [String: Any]()
        nowPlayingInfo[MPMediaItemPropertyTitle] = episode?.title
        nowPlayingInfo[MPMediaItemPropertyArtist] = episode?.artist
        MPNowPlayingInfoCenter.default().nowPlayingInfo = nowPlayingInfo
    }
    
    fileprivate func setupInterruptionObserver() {
        NotificationCenter.default.addObserver(self, selector: #selector(handleInterruption), name: AVAudioSession.interruptionNotification, object: nil)
    }
    
    func updateEpisodeTime() {
        let interval = CMTime(value: 1, timescale: 2)
        player.addPeriodicTimeObserver(forInterval: interval, queue: .main) { [weak self] (time) in
            guard let totalTime = self?.player.currentItem?.duration else { return }
            self?.maxTimeLabel.text = totalTime.toDisplayString()
            self?.minTimeLabel.text = time.toDisplayString()
            self?.updateDurationSlider()
            self?.setupLockScreenCurrentTime()
        }
    }
    
    fileprivate func setupLockScreenCurrentTime() {
        guard let duration = player.currentItem?.duration else { return }
        let durationInSeconds = CMTimeGetSeconds(duration)
        let elapsedTimeInSeconds = CMTimeGetSeconds(player.currentTime())
        var nowPlayingInfo = MPNowPlayingInfoCenter.default().nowPlayingInfo
        nowPlayingInfo?[MPMediaItemPropertyPlaybackDuration] = durationInSeconds
        nowPlayingInfo?[MPNowPlayingInfoPropertyElapsedPlaybackTime] = elapsedTimeInSeconds
        MPNowPlayingInfoCenter.default().nowPlayingInfo = nowPlayingInfo
    }
    
    func updateDurationSlider() {
        let currentTimeInSeconds = CMTimeGetSeconds(player.currentTime())
        let totalDurationInSeconds = CMTimeGetSeconds(player.currentItem?.duration ?? CMTime(value: 1, timescale: 1))
        durationSlider.value = Float(currentTimeInSeconds / totalDurationInSeconds)
    }
    
    func scaleEpisodeImageView() {
        let scale: CGFloat = 0.75
        UIView.animate(withDuration: 0.75, delay: 0, usingSpringWithDamping: 0.5, initialSpringVelocity: 1, options: .curveEaseOut) {
            let isPreparingToPlayOrPlaying = self.player.timeControlStatus == .waitingToPlayAtSpecifiedRate || self.player.timeControlStatus == .playing
            self.episodeImageView.transform = isPreparingToPlayOrPlaying ? .identity : CGAffineTransform(scaleX: scale, y: scale)
        }
    }
    
    func enlargeEpisodeImageView() {
        let time = CMTime(value: 1, timescale: 3)
        let times = [NSValue(time: time)]
        player.addBoundaryTimeObserver(forTimes: times, queue: .main) { [weak self] in
            self?.scaleEpisodeImageView()
        }
    }
    
    func configureUI() {
        backgroundColor = UIColor(named: "DarkMode1")
        
        addSubviews(miniPlayerView, dismissButton, episodeImageView, durationSlider, timeLabelStack, titleLabel, artistLabel, buttonsContainerView, volumeStack)
        
        miniPlayerView.anchor(top: topAnchor, right: rightAnchor, left: leftAnchor)
        miniPlayerView.setDimension(hConst: 64)
        
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
        
        miniPlayerView.addSubviews(miniPlayerSeparatorView, miniPlayerViewStack)
        
        miniPlayerSeparatorView.setDimension(hConst: 1)
        miniPlayerSeparatorView.anchor(top: miniPlayerView.topAnchor, right: miniPlayerView.rightAnchor, left: miniPlayerView.leftAnchor)
        miniPlayerSeparatorView.backgroundColor = #colorLiteral(red: 0.8547367454, green: 0.8496564031, blue: 0.8586423993, alpha: 1)
        
        miniPlayerViewStack.anchor(top: miniPlayerView.topAnchor, right: miniPlayerView.rightAnchor, bottom: miniPlayerView.bottomAnchor, left: miniPlayerView.leftAnchor)

        miniEpisodeImageView.setDimension(width: miniPlayerView.heightAnchor, height: miniPlayerView.heightAnchor, wMult: 0.8, hMult: 0.8)
        miniEpisodeImageView.anchor(left: miniPlayerView.leftAnchor, paddingLeft: 15)
        miniEpisodeImageView.center(to: miniPlayerView, by: .centerY)

        miniForwardBtn.setDimension(width: miniPlayerView.heightAnchor, height: miniPlayerView.heightAnchor, wMult: 0.5, hMult: 0.5)
        miniForwardBtn.anchor(right: miniPlayerView.rightAnchor, paddingRight: 15)
        miniPlayPauseBtn.setDimension(width: miniPlayerView.heightAnchor, height: miniPlayerView.heightAnchor, wMult: 0.5, hMult: 0.5)
    }
    
    func addGestureToMaximizeView() {
        self.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleTapMaximize)))
        self.addGestureRecognizer(UIPanGestureRecognizer(target: self, action: #selector(handleDismissalPan)))
        panGesture = UIPanGestureRecognizer(target: self, action: #selector(handlePan))
        miniPlayerView.addGestureRecognizer(panGesture)
    }
    
    func playEpisode() {
        var audioURL: URL!
        
        if let fileURLString = episode?.fileURL {
            guard let url = URL(string: fileURLString) else { return }
            let fileName = url.lastPathComponent
            guard let trueLocation = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first else { return }
            audioURL = trueLocation.appendingPathComponent(fileName)
        } else {
            guard let streamUrl = URL(string: episode?.streamUrl ?? "") else { return }
            audioURL = streamUrl
        }
        
        let playerItem = AVPlayerItem(url: audioURL)
        player.replaceCurrentItem(with: playerItem)
        player.volume = volumeSlider.value
        player.play()
    }
    
    func skip(amountOfTime time: Float64) {
        let currentEpisodeTime = player.currentTime()
        let skipTime = CMTimeMakeWithSeconds(time, preferredTimescale: 1)
        player.seek(to: CMTimeAdd(currentEpisodeTime, skipTime))
    }
    
    func updatePlayPauseBtnImage(withImageName name: String) {
        let largeButton = UIImage.SymbolConfiguration(font: UIFont.systemFont(ofSize: 35))
        let miniLargeButton = UIImage.SymbolConfiguration(font: UIFont.systemFont(ofSize: 18))
        playPauseBtn.setImage(UIImage(systemName: name, withConfiguration: largeButton), for: .normal)
        miniPlayPauseBtn.setImage(UIImage(systemName: name, withConfiguration: miniLargeButton), for: .normal)
    }
    
    func handlePanChanged(gesture: UIPanGestureRecognizer) {
        let translation = gesture.translation(in: self.superview)
        self.transform = CGAffineTransform(translationX: 0, y: translation.y)
        self.miniPlayerView.alpha = 1 + translation.y / 200
        self.episodeImageView.alpha = 0 - translation.y / 200
        self.dismissButton.alpha = 0 - translation.y / 200
    }
    
    func handlePanEnded(gesture: UIPanGestureRecognizer) {
        let translation = gesture.translation(in: self.superview)
        let velocity = gesture.velocity(in: self.superview)
        
        UIView.animate(withDuration: 0.25) {
            self.transform = .identity
            if translation.y < -200 || velocity.y < -500 {
                UIApplication.mainTabBarController()?.maximizePlayerDetails(episode: nil)
            } else {
                self.miniPlayerView.alpha = 1
                self.episodeImageView.alpha = 0
                self.dismissButton.alpha = 0
            }
        }
    }

    // MARK: - Selector
    @objc func handleDismiss() {
        UIApplication.mainTabBarController()?.minimizePlayerDetails()
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
        if player.timeControlStatus == .paused {
            player.play()
            updatePlayPauseBtnImage(withImageName: "pause.fill")
        } else {
            player.pause()
            updatePlayPauseBtnImage(withImageName: "play.fill")
        }
        
        scaleEpisodeImageView()
    }
    
    @objc func didChangeVolume() {
        player.volume = volumeSlider.value
    }
    
    @objc func handleTapMaximize() {
        UIApplication.mainTabBarController()?.maximizePlayerDetails(episode: nil)
    }
    
    @objc func handlePan(gesture: UIPanGestureRecognizer) {
        if gesture.state == .began {
            print("began")
        } else if gesture.state == .changed {
            handlePanChanged(gesture: gesture)
        } else if gesture.state == .ended {
            handlePanEnded(gesture: gesture)
        }
    }
    
    @objc func handleDismissalPan(gesture: UIPanGestureRecognizer) {
        let translation = gesture.translation(in: self.superview)
        
        if gesture.state == .changed && translation.y > 0 {
            self.transform = CGAffineTransform(translationX: 0, y: translation.y)
        } else if gesture.state == .ended {
            UIView.animate(withDuration: 0.25) {
                self.transform = .identity
                
                if translation.y > 50 {
                    UIApplication.mainTabBarController()?.minimizePlayerDetails()
                }
            }
        }
    }
    
    @objc func handleInterruption(notification: Notification) {
        print("interruption observed")
        guard let userInfo = notification.userInfo else { return }
        guard let type = userInfo[AVAudioSessionInterruptionTypeKey] as? UInt else { return }

        if type == AVAudioSession.InterruptionType.began.rawValue {
            print("interruption began")
            updatePlayPauseBtnImage(withImageName: "play.fill")
        } else {
            print("Interruption ended")

            guard let optionsValue = userInfo[AVAudioSessionInterruptionOptionKey] as? UInt else { return }
            let options = AVAudioSession.InterruptionOptions(rawValue: optionsValue)

            if options.contains(.shouldResume) {
                player.play()
                updatePlayPauseBtnImage(withImageName: "pause.fill")
            } 
        }
    }
}
