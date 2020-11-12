//
//  EpisodeTimeLabel.swift
//  Podcast
//
//  Created by William Yeung on 11/9/20.
//

import UIKit

class AlignedTextLabel: CustomLabel {
    // MARK: - Init
    init(withText t: String, textColor color: UIColor, isBolded: Bool = false, fontSize: CGFloat = 16, andAlignment alignment: NSTextAlignment = .left) {
        super.init(withText: t, isBolded: isBolded, fontSize: fontSize)
        textAlignment = alignment
        textColor = color
        numberOfLines = 2
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
