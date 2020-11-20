//
//  UIApplication.swift
//  Podcast
//
//  Created by William Yeung on 11/20/20.
//

import UIKit

extension UIApplication {
    static func mainTabBarController() -> MainTabBarController? {
        return shared.windows.filter({ $0.isKeyWindow }).first?.rootViewController as? MainTabBarController
    }
}
