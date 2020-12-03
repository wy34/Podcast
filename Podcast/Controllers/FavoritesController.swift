//
//  FavoritesController.swift
//  Podcast
//
//  Created by William Yeung on 12/1/20.
//

import UIKit

class FavoritesController: UICollectionViewController {
    // MARK: - Properties
    var savedPodcasts = UserDefaults.standard.savedPodcasts()
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupCollectionView()
    }
    
    // MARK: - Helper
    func setupCollectionView() {
        collectionView.backgroundColor = UIColor(named: "DarkMode1")
        collectionView.register(FavoritePodcastCell.self, forCellWithReuseIdentifier: FavoritePodcastCell.cellId)
        collectionView.addGestureRecognizer(UILongPressGestureRecognizer(target: self, action: #selector(handleLongPress)))
    }
    
    // MARK: - Selector
    @objc func handleLongPress(gesture: UILongPressGestureRecognizer) {
        let locationOfPress = gesture.location(in: self.collectionView)
        
        if let indexOfPress = collectionView.indexPathForItem(at: locationOfPress) {
            let alertController = UIAlertController(title: "Remove Podcast?", message: nil, preferredStyle: .actionSheet)
            alertController.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
            alertController.addAction(UIAlertAction(title: "Yes", style: .destructive, handler: { (_) in
                self.savedPodcasts.remove(at: indexOfPress.item)
                self.collectionView.deleteItems(at: [indexOfPress])
                UserDefaults.standard.removeObject(forKey: UserDefaults.favoritedPodcastKey)
            }))
            present(alertController, animated: true)
        }
    }
}

// MARK: - UICollectionView Datasource/Delegate/FlowLayout
extension FavoritesController: UICollectionViewDelegateFlowLayout {
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return savedPodcasts.count
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: FavoritePodcastCell.cellId, for: indexPath) as! FavoritePodcastCell
        cell.podcast = savedPodcasts[indexPath.row]
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = (view.frame.width - (3 * 16)) / 2
        return CGSize(width: width, height: width * 1.25)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 16, left: 16, bottom: 16, right: 16)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 16
    }
}

// 1: 7896
// 2: 3135
