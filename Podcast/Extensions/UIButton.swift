//
//  UIButton.swift
//  Podcast
//
//  Created by William Yeung on 11/10/20.
//

import UIKit

extension UIButton {
    static func createControlButton(withImage image: String, color: UIColor = UIColor(named: "DarkMode2")!, andSize size: CGFloat = 20) -> UIButton {
        let button = UIButton(type: .system)
        let largeImage = UIImage.SymbolConfiguration(font: UIFont.systemFont(ofSize: size))
        button.setImage(UIImage(systemName: image, withConfiguration: largeImage), for: .normal)
        button.tintColor = color
        return button
    }
}
