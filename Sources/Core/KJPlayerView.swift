//
//  KJPlayerView.swift
//  KJPlayer
//
//  Created by abas on 2021/12/14.
//

import Foundation
import UIKit

@IBDesignable
@objc public class KJPlayerView: UIImageView {
    
    @IBOutlet weak var delegate: KJPlayerBaseViewDelegate?
    
    /// Placeholder image
    var placeholder: UIImage? = nil
    /// background color
    var background: CGColor = UIColor.black.cgColor
    /// Video display mode
    var videoGravity: KJPlayerVideoGravity = .resizeAspect
}
