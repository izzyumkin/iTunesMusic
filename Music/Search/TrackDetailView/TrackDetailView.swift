//
//  TrackDetailView.swift
//  Music
//
//  Created by Иван Изюмкин on 21.03.2021.
//

import UIKit
import AVKit
import SDWebImage

protocol TrackMovingDelegate: class {
    
    func nextTrack() -> SearchViewModel.Cell?
    func previousTrack() -> SearchViewModel.Cell?
    
}

class TrackDetailView: UIView {
    
    
    @IBOutlet weak var trackImageView: UIImageView!
    @IBOutlet weak var currentTimeSlider: UISlider!
    @IBOutlet weak var currentTimeLabel: UILabel!
    @IBOutlet weak var durationLabel: UILabel!
    @IBOutlet weak var trackTitleLabel: UILabel!
    @IBOutlet weak var authorLabel: UILabel!
    @IBOutlet weak var playPauseButton: UIButton!
    @IBOutlet weak var volumeSlider: UISlider!
    
    @IBOutlet weak var detailStack: UIStackView!
    @IBOutlet weak var miniDetailView: UIView!
    @IBOutlet weak var miniGoForwardButton: UIButton!
    @IBOutlet weak var miniPlauPauseButton: UIButton!
    @IBOutlet weak var miniTrackTitleLabel: UILabel!
    @IBOutlet weak var miniTrackImageView: UIImageView!
    
    private let player: AVPlayer = {
       
        let avPlayer = AVPlayer()
        avPlayer.automaticallyWaitsToMinimizeStalling = false
        return avPlayer
        
    }()
    
    weak var delegate: TrackMovingDelegate?
    weak var tabBarDelegate: MainTabBarControllerDelegate?
    
    // MARK: - awakeFromNib
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        trackImageView.layer.cornerRadius = 5
        
    }
    
    // MARK: - Setup
    
    public func set(viewModel: SearchViewModel.Cell) {
        
        let scale: CGFloat = 0.8
        trackImageView.transform = CGAffineTransform(scaleX: scale, y: scale)
        
        trackTitleLabel.text = viewModel.trackName
        miniTrackTitleLabel.text = viewModel.trackName
        authorLabel.text = viewModel.artistName
        
        playPauseButton.setImage(#imageLiteral(resourceName: "pause"), for: .normal)
        miniPlauPauseButton.setImage(#imageLiteral(resourceName: "pause"), for: .normal)
        
        monitorStartTime()
        observePlayerCurrentTime()
        playMusic(previewUrl: viewModel.previewUrl)
        setupGestures()
        
        let string600 = viewModel.imageUrlString?.replacingOccurrences(of: "100x100", with: "600x600")
        guard let url = URL(string: string600 ?? "") else { return }
        trackImageView.sd_setImage(with: url, completed: nil)
        miniTrackImageView.sd_setImage(with: url, completed: nil)
        
    }
    
    private func playMusic(previewUrl: String?) {
        
        guard let url = URL(string: previewUrl ?? "") else { return }
        let playerItem = AVPlayerItem(url: url)
        player.replaceCurrentItem(with: playerItem)
        player.play()
        
    }
    
    // MARK: - Drag and drop gestures
    
    private func setupGestures() {
        
        miniDetailView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleTapMaximized)))
        miniDetailView.addGestureRecognizer(UIPanGestureRecognizer(target: self, action: #selector(handlePanMaximized)))
        addGestureRecognizer(UIPanGestureRecognizer(target: self, action: #selector(handlePanDissmis)))
        
    }
    
    @objc private func handleTapMaximized() {
        self.tabBarDelegate?.maximizedTrackDetailController(viewModel: nil)
    }
    
    @objc private func handlePanMaximized(gesture: UIPanGestureRecognizer) {
        switch gesture.state {
        case .changed:
            handlePanChanged(gesture: gesture)
        case .ended:
            handlePanEnded(gesture: gesture)
        @unknown default:
            print("@unknown default")
        }
    }
    
    private func handlePanChanged(gesture: UIPanGestureRecognizer) {
        
        let translation = gesture.translation(in: self.superview)
        self.transform = CGAffineTransform(translationX: 0, y: translation.y)
        
        let newAlpha = 1 + translation.y / 200
        self.miniDetailView.alpha = newAlpha < 0 ? 0 : newAlpha
        self.detailStack.alpha = -translation.y / 200
        
    }
    
    private func handlePanEnded(gesture: UIPanGestureRecognizer) {
        
        let translation = gesture.translation(in: self.superview)
        let velocity = gesture.velocity(in: self.superview)
        
        UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 0.7, initialSpringVelocity: 1, options: .curveEaseInOut, animations: {
            self.transform = .identity
            if translation.y < -200 || velocity.y < -500 {
                self.tabBarDelegate?.maximizedTrackDetailController(viewModel: nil)
            } else {
                self.miniDetailView.alpha = 1
                self.detailStack.alpha = 0
            }
        }, completion: nil)
        
    }
    
    @objc private func handlePanDissmis(gesture: UIPanGestureRecognizer) {
        
        switch gesture.state {
        case .changed:
            let translation = gesture.translation(in: self.superview)
            detailStack.transform = CGAffineTransform(translationX: 0, y: translation.y)
        case .ended:
            let translation = gesture.translation(in: self.superview)
            UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 0.7, initialSpringVelocity: 1, options: .curveEaseInOut, animations: {
                self.detailStack.transform = .identity
                if translation.y > 50 {
                    self.tabBarDelegate?.minimizedTrackDetailController()
                }
            }, completion: nil)
        @unknown default:
            print("@unknown default")
        }
        
    }
    
    // MARK: - Time setup
    
    private func monitorStartTime() {
        
        let time = CMTimeMake(value: 1, timescale: 3)
        let times = [NSValue(time: time)]
        player.addBoundaryTimeObserver(forTimes: times, queue: .main) { [weak self] in
            self?.enlargeTrackImageView()
        }
        
    }
    
    private func observePlayerCurrentTime() {
        
        let interval = CMTimeMake(value: 1, timescale: 2)
        player.addPeriodicTimeObserver(forInterval: interval, queue: .main) { [weak self] (time) in
            
            self?.currentTimeLabel.text = time.toDisplayString()
            
            let durationTime = self?.player.currentItem?.duration
            let currentDurationText = ((durationTime ?? CMTimeMake(value: 1, timescale: 1)) - time).toDisplayString()
            self?.durationLabel.text = "-\(currentDurationText)"
            
            self?.updateCurrentTimeSlider()
            
        }
        
    }
    
    private func updateCurrentTimeSlider() {
        
        let currentTimeSeconds = CMTimeGetSeconds(player.currentTime())
        let durationSeconds = CMTimeGetSeconds(player.currentItem?.duration ?? CMTimeMake(value: 1, timescale: 1))
        let percentage = currentTimeSeconds / durationSeconds
        self.currentTimeSlider.value = Float(percentage)
        
    }
    
    // MARK: - Animations
    
    private func enlargeTrackImageView() {
        
        UIView.animate(withDuration: 1, delay: 0, usingSpringWithDamping: 0.5, initialSpringVelocity: 1, options: .curveEaseInOut, animations: {
            self.trackImageView.transform = .identity
        }, completion: nil)
        
    }
    
    private func reduceTrackImageView() {
        
        UIView.animate(withDuration: 1, delay: 0, usingSpringWithDamping: 0.5, initialSpringVelocity: 1, options: .curveEaseInOut, animations: {
            let scale: CGFloat = 0.8
            self.trackImageView.transform = CGAffineTransform(scaleX: scale, y: scale)
        }, completion: nil)
        
    }
    
    
    // MARK: - Actions
    
    @IBAction func handleCurrentTimeSlider(_ sender: Any) {

        let percentage = currentTimeSlider.value
        guard let duration = player.currentItem?.duration else { return }
        let durationInSeconds = CMTimeGetSeconds(duration)
        let seekTimeInSeconds = Float64(percentage) * durationInSeconds
        let seekTime = CMTimeMakeWithSeconds(seekTimeInSeconds, preferredTimescale: 1)
        player.seek(to: seekTime)
    }
    
    @IBAction func handleVolumeSlider(_ sender: Any) {
        player.volume = volumeSlider.value
    }
    
    @IBAction func dragDownButtonTapped(_ sender: Any) {
        self.tabBarDelegate?.minimizedTrackDetailController()
//        self.removeFromSuperview()
    }
    
    @IBAction func previousTrack(_ sender: Any) {
        
        guard let cellViewModel = delegate?.previousTrack() else { return }
        set(viewModel: cellViewModel)
        
    }
    
    @IBAction func playPauseAction(_ sender: Any) {
        
        if player.timeControlStatus == .paused {
            
            player.play()
            playPauseButton.setImage(#imageLiteral(resourceName: "pause"), for: .normal)
            miniPlauPauseButton.setImage(#imageLiteral(resourceName: "pause"), for: .normal)
            enlargeTrackImageView()
            
        } else {
            
            player.pause()
            playPauseButton.setImage(#imageLiteral(resourceName: "play"), for: .normal)
            miniPlauPauseButton.setImage(#imageLiteral(resourceName: "play"), for: .normal)
            reduceTrackImageView()
            
        }
        
    }
    
    @IBAction func nextTrack(_ sender: Any) {
        
        guard let cellViewModel = delegate?.nextTrack() else { return }
        set(viewModel: cellViewModel)
        
    }
    
}
