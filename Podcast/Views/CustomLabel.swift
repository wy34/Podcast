//
//  CustomLabel.swift
//  Podcast
//
//  Created by William Yeung on 11/5/20.
//

import UIKit

class CustomLabel: UILabel {
    // MARK: - Init
    init(withText t: String, isBolded: Bool = false, fontSize: CGFloat = 16, isTrackName: Bool = false) {
        super.init(frame: .zero)
        text = t
        
        if isTrackName {
            numberOfLines = 2
        }
        
        if isBolded {
            font = UIFont.boldSystemFont(ofSize: fontSize)
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
