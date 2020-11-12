//
//  CustomLabel.swift
//  Podcast
//
//  Created by William Yeung on 11/5/20.
//

import UIKit

class CustomLabel: UILabel {
    // MARK: - Init
    init(withText t: String, isBolded bold: Bool = false, fontSize: CGFloat = 16, isMultiLine multiLine: Bool = false) {
        super.init(frame: .zero)
        text = t
        
        if multiLine {
            numberOfLines = 2
        }
        
        if bold {
            font = UIFont.boldSystemFont(ofSize: fontSize)
        } else {
            font = UIFont.systemFont(ofSize: fontSize)
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
