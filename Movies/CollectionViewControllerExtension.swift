//
//  CollectionViewControllerExtension.swift
//  Movies
//
//  Created by Ronnie Voss on 9/29/19.
//  Copyright © 2019 Ronnie Voss. All rights reserved.
//

extension UICollectionViewController {
    func getScreenWidth() -> CGFloat {

        let device = traitCollection.userInterfaceIdiom
        let orientation = UIDevice.current.orientation
        let screenWidth = view.bounds.size.width
        var width: CGFloat!

        if screenWidth == 678.0 || screenWidth == 639.0 {
            width = screenWidth / 3.5
        } else if screenWidth == 981.0 || screenWidth == 694.0 {
            width = screenWidth / 4.5
        } else if screenWidth == 507.0 {
            width = screenWidth / 3.6
        } else if screenWidth == 694.0 {
            width = screenWidth / 4.5
        } else if screenWidth == 438.0 {
            width = screenWidth / 2.3
        } else if screenWidth == 320.0 {
            width = screenWidth / 2.4
        } else if screenWidth == 480.0 {
            width = screenWidth / 3.5
        } else if screenWidth == 414.0 {
            width = screenWidth / 2.3
        } else if screenWidth == 768.0 {
            width = screenWidth / 4.5
        } else if screenWidth == 1366.0 {
            width = screenWidth / 6.2
        } else if orientation.isLandscape && screenWidth == 1024.0 {
            width = screenWidth / 5.3
        } else if screenWidth == 1024.0 {
            width = screenWidth / 4.2
        } else if orientation.isLandscape && device == .phone {
            width = screenWidth / 4.4
        } else {
            width = screenWidth / 2.5
        }
        return width
    }
}
