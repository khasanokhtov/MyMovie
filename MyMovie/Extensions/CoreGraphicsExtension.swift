//
//  CoreGraphicsExtension.swift
//  MyMovie
//
//  Created by Alex Okhtov on 12.05.2023.
//

import UIKit

extension CALayer {
    
    func removeLayerIfExists(_ view: UIView) {
        if let lastLayer = view.layer.sublayers?.last {
            let isPresent = lastLayer is ShimmerLayer
            if isPresent {
                self.removeFromSuperlayer()
            }
        }
    }
}
