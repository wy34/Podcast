//
//  UIButton.swift
//  Podcast
//
//  Created by William Yeung on 11/10/20.
//

import UIKit

extension UIButton {
    static func createControlButton(withImage image: String) -> UIButton {
        let button = UIButton(type: .system)
        button.setImage(UIImage(systemName: image), for: .normal)
        button.tintColor = .black
        return button
    }
}
