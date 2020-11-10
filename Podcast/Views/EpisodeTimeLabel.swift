//
//  EpisodeTimeLabel.swift
//  Podcast
//
//  Created by William Yeung on 11/9/20.
//

import UIKit

class EpisodeTimeLabel: CustomLabel {
    // MARK: - Init
    init(withText t: String, andAlignment alignment: NSTextAlignment = .left) {
        super.init(withText: t)
        textColor = .lightGray
        textAlignment = alignment
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
